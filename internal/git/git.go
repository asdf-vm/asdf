// Package git contains all the Git operations that can be applied to asdf
// Git repositories like the plugin index repo and individual asdf plugins.
package git

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"regexp"
	"strings"

	"github.com/asdf-vm/asdf/internal/execute"
)

// DefaultRemoteName for Git repositories in asdf
const DefaultRemoteName = "origin"

// isSHA returns true if the ref looks like a SHA commit hash
func isSHA(ref string) bool {
	// Match 7-40 hex characters (common range for git SHAs)
	matched, _ := regexp.MatchString("^[0-9a-f]{7,40}$", ref)
	return matched
}

// IsURL determines if a string is a Git URL based on Git's supported protocols
// Reference: https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols
func IsURL(s string) bool {
	// Special case: "." and ".." are directory references, not git repository URLs
	if s == "." || s == ".." {
		return false
	}
	
	// HTTP/HTTPS protocols - must have proper :// format
	if strings.HasPrefix(s, "http://") || strings.HasPrefix(s, "https://") {
		return strings.Contains(s, "://") // Double check for proper format
	}
	
	// Git protocol
	if strings.HasPrefix(s, "git://") {
		return true
	}
	
	// SSH protocol variants
	if strings.HasPrefix(s, "ssh://") {
		return true
	}
	
	// SSH shorthand (user@host:path) - must not contain spaces
	if strings.Contains(s, "@") && strings.Contains(s, ":") && !strings.Contains(s, " ") {
		parts := strings.Split(s, "@")
		if len(parts) == 2 {
			hostPath := parts[1]
			// Must have : after the host part and before path
			return strings.Contains(hostPath, ":") && len(strings.Split(hostPath, ":")) >= 2
		}
	}
	
	// File protocol
	if strings.HasPrefix(s, "file://") {
		return true
	}
	
	// Absolute paths are always URLs (Git branch names cannot start with /)
	if strings.HasPrefix(s, "/") {
		return true
	}
	
	// Explicit relative paths are always URLs (Git branch names cannot start with ./ or ../)
	if strings.HasPrefix(s, "./") || strings.HasPrefix(s, "../") {
		return true
	}
	
	// Windows-style paths are always URLs (Git branch names cannot contain \)
	if len(s) >= 3 && s[1] == ':' && (s[2] == '\\' || s[2] == '/') {
		return true
	}
	
	// For anything else, check if it exists as a file or directory
	// If it exists, it's more likely a file path (URL), otherwise it's likely a git ref
	if _, err := os.Stat(s); err == nil {
		return true
	}
	
	// If it doesn't exist, it's more likely a git ref (branch, tag, commit)
	return false
}

// Repoer is an interface for operations that can be applied to asdf plugins.
// Right now we only support Git, but in the future we might have other
// mechanisms to install and upgrade plugins. asdf doesn't require a plugin
// to be a Git repository when asdf uses it, but Git is the only way to install
// and upgrade plugins. If other approaches are supported this will be
// extracted into the `plugins` module.
type Repoer interface {
	Clone(pluginURL, ref string) error
	Head() (string, error)
	RemoteURL() (string, error)
	Update(ref string) (string, string, string, error)
}

// Repo is a struct to contain the Git repository details
type Repo struct {
	Directory string
	URL       string
}

// NewRepo builds a new Repo instance
func NewRepo(directory string) Repo {
	return Repo{Directory: directory}
}

// Clone installs a plugin via Git
func (r Repo) Clone(pluginURL, ref string) error {
	var cmdStr []string

	if ref != "" && isSHA(ref) {
		// For SHA commits, we need to clone first and then checkout the specific commit
		cmdStr = []string{"git", "clone", pluginURL, r.Directory}
		_, stderr, err := exec(cmdStr)
		if err != nil {
			return fmt.Errorf("unable to clone plugin: %s", stdErrToErrMsg(stderr))
		}

		// Now checkout the specific commit
		checkoutCmd := []string{"git", "-C", r.Directory, "-c", "advice.detachedHead=false", "checkout", ref}
		_, stderr, err = exec(checkoutCmd)
		if err != nil {
			return fmt.Errorf("unable to checkout commit %s: %s", ref, stdErrToErrMsg(stderr))
		}
	} else {
		// For branches and tags, use --branch flag
		cmdStr = []string{"git", "clone", pluginURL, r.Directory}
		if ref != "" {
			cmdStr = []string{"git", "clone", pluginURL, r.Directory, "--branch", ref}
		}

		_, stderr, err := exec(cmdStr)
		if err != nil {
			return fmt.Errorf("unable to clone plugin: %s", stdErrToErrMsg(stderr))
		}
	}

	return nil
}

// Head returns the current HEAD ref of the plugin's Git repository
func (r Repo) Head() (string, error) {
	err := repositoryExists(r.Directory)
	if err != nil {
		return "", err
	}

	stdout, stderr, err := exec([]string{"git", "-C", r.Directory, "rev-parse", "HEAD"})
	if err != nil {
		return "", errors.New(stdErrToErrMsg(stderr))
	}

	return strings.TrimSpace(stdout), nil
}

// RemoteURL returns the URL of the default remote for the plugin's Git repository
func (r Repo) RemoteURL() (string, error) {
	err := repositoryExists(r.Directory)
	if err != nil {
		return "", err
	}

	remote, err := r.defaultRemote()
	if err != nil {
		return "", err
	}

	stdout, _, err := exec([]string{"git", "-C", r.Directory, "remote", "get-url", remote})
	return stdout, err
}

// Update updates the plugin's Git repository to the ref if provided, or the
// latest commit on the current branch
func (r Repo) Update(ref string) (string, string, string, error) {
	shortRef := ref

	oldHash, err := r.Head()
	if err != nil {
		return "", "", "", err
	}

	remoteName, err := r.defaultRemote()
	if err != nil {
		return "", "", "", err
	}

	// If no ref is provided we take the default branch of the remote
	if strings.TrimSpace(ref) == "" {
		ref, err = r.remoteDefaultBranch()
		if err != nil {
			return "", "", "", err
		}

		shortRef = strings.SplitN(ref, "/", 3)[2]
	}

	commonOpts := []string{"git", "-C", r.Directory}

	if isSHA(shortRef) {
		// For SHA commits, fetch all refs and then checkout the specific commit
		fetchCmd := append(commonOpts, []string{"fetch", "--prune", "--update-head-ok", remoteName}...)
		_, stderr, err := exec(fetchCmd)
		if err != nil {
			return "", "", "", errors.New(stdErrToErrMsg(stderr))
		}
	} else {
		// For branches and tags, use refspec to create local tracking branch
		refSpec := fmt.Sprintf("%s:%s", shortRef, shortRef)
		fetchCmd := append(commonOpts, []string{"fetch", "--prune", "--update-head-ok", remoteName, refSpec}...)
		_, stderr, err := exec(fetchCmd)
		if err != nil {
			return "", "", "", errors.New(stdErrToErrMsg(stderr))
		}
	}

	cmdStr := append(commonOpts, []string{"-c", "advice.detachedHead=false", "checkout", "--force", shortRef}...)
	_, stderr, err := exec(cmdStr)
	if err != nil {
		return "", "", "", errors.New(stdErrToErrMsg(stderr))
	}

	newHash, err := r.Head()
	if err != nil {
		return ref, oldHash, newHash, fmt.Errorf("unable to resolve plugin new Git HEAD: %w", err)
	}
	return ref, oldHash, newHash, nil
}

func (r Repo) defaultRemote() (string, error) {
	stdout, _, err := exec([]string{"git", "-C", r.Directory, "remote"})
	if err != nil {
		return "", err
	}

	return strings.SplitN(stdout, "\n", 2)[0], nil
}

func (r Repo) remoteDefaultBranch() (string, error) {
	remote, err := r.defaultRemote()
	if err != nil {
		return "", err
	}

	stdout, stderr, err := exec([]string{"git", "-C", r.Directory, "ls-remote", "--symref", remote, "HEAD"})
	if err != nil {
		return "", errors.New(stdErrToErrMsg(stderr))
	}
	return strings.Fields(strings.Split(stdout, "\n")[0])[1], nil
}

func stdErrToErrMsg(stdErr string) string {
	lines := strings.Split(strings.TrimSuffix(stdErr, "\n"), "\n")
	return lines[len(lines)-1]
}

func exec(command []string) (string, string, error) {
	cmd := execute.New(command[0], command[1:])

	var stdOut strings.Builder
	var stdErr strings.Builder
	cmd.Stdout = &stdOut
	cmd.Stderr = &stdErr
	err := cmd.Run()

	return stdOut.String(), stdErr.String(), err
}

func repositoryExists(directory string) error {
	stat, err := os.Stat(directory)
	if err != nil {
		err, _ := err.(*fs.PathError)
		return err.Err
	}

	if stat.IsDir() {
		// directory exists
		stdout, _, _ := exec([]string{"git", "-C", directory, "rev-parse", "--is-inside-work-tree"})
		if strings.TrimSpace(stdout) == "true" {
			return nil
		}

		return errors.New("not a git repository")
	}

	return errors.New("not a directory")
}

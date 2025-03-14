// Package git contains all the Git operations that can be applied to asdf
// Git repositories like the plugin index repo and individual asdf plugins.
package git

import (
	"errors"
	"fmt"
	"path/filepath"
	"strings"

	"github.com/asdf-vm/asdf/internal/execute"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
)

// DefaultRemoteName for Git repositories in asdf
const DefaultRemoteName = "origin"

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
	cmdStr := []string{"clone", pluginURL, r.Directory}

	if ref != "" {
		cmdStr = []string{"clone", pluginURL, r.Directory, "--branch", ref}
	}

	cmd := execute.New("git", cmdStr)
	var stdOut strings.Builder
	var stdErr strings.Builder
	cmd.Stdout = &stdOut
	cmd.Stderr = &stdErr
	err := cmd.Run()

	if err != nil {
		return fmt.Errorf("unable to clone plugin: %s", stdErrToErrMsg(stdErr.String()))
	}

	return nil
}

// Head returns the current HEAD ref of the plugin's Git repository
func (r Repo) Head() (string, error) {
	repo, err := gitOpen(r.Directory)
	if err != nil {
		return "", err
	}

	ref, err := repo.Head()
	if err != nil {
		return "", err
	}

	return ref.Hash().String(), nil
}

// RemoteURL returns the URL of the default remote for the plugin's Git repository
func (r Repo) RemoteURL() (string, error) {
	repo, err := gitOpen(r.Directory)
	if err != nil {
		return "", err
	}

	remotes, err := repo.Remotes()
	if err != nil {
		return "", err
	}

	return remotes[0].Config().URLs[0], nil
}

func (r Repo) RemoteDefaultBranch() (string, error) {
	// @jiminychris - https://github.com/go-git/go-git/issues/510#issuecomment-2560116147
	repo, err := gitOpen(r.Directory)
	if err != nil {
		return "", err
	}

	// Get the remote you want to find the default for
	remote, err := repo.Remote("origin")
	if err != nil {
		return "", err
	}

	references, _ := remote.List(&git.ListOptions{})
	// Search through the list of references in that remote for a symbolic reference named HEAD;
	// Its target should be the default branch name.
	for _, reference := range references {
		if reference.Name() == "HEAD" && reference.Type() == plumbing.SymbolicReference {
			return reference.Target().String(), nil
		}
	}
	return "", fmt.Errorf("unable to find default branch for git directory %s", r.Directory)
}

// Update updates the plugin's Git repository to the ref if provided, or the
// latest commit on the current branch
func (r Repo) Update(ref string) (string, string, string, error) {
	repo, err := gitOpen(r.Directory)
	if err != nil {
		return "", "", "", err
	}

	oldHash, err := repo.Head()
	if err != nil {
		return "", "", "", err
	}

	// If no ref is provided we take the default branch of the remote
	if strings.TrimSpace(ref) == "" {
		ref, err = r.RemoteDefaultBranch()
		if err != nil {
			return "", "", "", err
		}
	}

	commonOpts := []string{"--git-dir", filepath.Join(r.Directory, ".git"), "--work-tree", r.Directory}

	refSpec := fmt.Sprintf("%s:%s", ref, ref)
	cmdStr := append(commonOpts, []string{"fetch", "--prune", "--update-head-ok", "origin", refSpec}...)

	cmd := execute.New("git", cmdStr)
	var stdErr strings.Builder
	cmd.Stderr = &stdErr
	err = cmd.Run()

	if err != nil && err != git.NoErrAlreadyUpToDate {
		return "", "", "", errors.New(stdErrToErrMsg(stdErr.String()))
	}

	cmdStr = append(commonOpts, []string{"-c", "advice.detachedHead=false", "checkout", "--force", ref}...)
	cmd = execute.New("git", cmdStr)
	var stdErr2 strings.Builder
	cmd.Stderr = &stdErr2
	err = cmd.Run()
	if err != nil {
		return "", "", "", errors.New(stdErrToErrMsg(stdErr2.String()))
	}

	newHash, err := repo.Head()
	if err != nil {
		return ref, oldHash.String(), newHash.Hash().String(), fmt.Errorf("unable to resolve plugin new Git HEAD: %w", err)
	}
	return ref, oldHash.String(), newHash.Hash().String(), nil
}

func stdErrToErrMsg(stdErr string) string {
	lines := strings.Split(strings.TrimSuffix(stdErr, "\n"), "\n")
	return lines[len(lines)-1]
}

func gitOpen(directory string) (*git.Repository, error) {
	repo, err := git.PlainOpen(directory)
	if err != nil {
		return repo, fmt.Errorf("unable to open plugin Git repository: %w", err)
	}

	return repo, nil
}

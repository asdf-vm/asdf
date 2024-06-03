// Package pluginindex is a package that handles fetching plugin repo URLs by
// name for user convenience.
package pluginindex

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
	"github.com/go-git/go-git/v5/plumbing"
	"gopkg.in/ini.v1"
)

const (
	pluginIndexDir      = "plugin-index"
	repoUpdatedFilename = "repo-updated"
)

type repoer interface {
	Install() error
	Update() error
}

type gitRepoIndex struct {
	directory string
	URL       string
}

func (g *gitRepoIndex) Install() error {
	opts := git.CloneOptions{
		URL: g.URL,
	}

	if _, err := git.PlainClone(g.directory, false, &opts); err != nil {
		return fmt.Errorf("unable to clone: %w", err)
	}

	return nil
}

func (g *gitRepoIndex) Update() error {
	repo, err := git.PlainOpen(g.directory)
	if err != nil {
		return fmt.Errorf("unable to open plugin Git repository: %w", err)
	}

	var checkoutOptions git.CheckoutOptions

	// If no ref is provided checkout latest commit on current branch
	head, err := repo.Head()
	if err != nil {
		return fmt.Errorf("unable to get repo HEAD: %w", err)
	}

	if !head.Name().IsBranch() {
		return fmt.Errorf("not on a branch, unable to update")
	}

	// If on a branch checkout the latest version of it from the remote
	branch := head.Name()
	ref := branch.String()
	checkoutOptions = git.CheckoutOptions{Branch: branch, Force: true}

	fetchOptions := git.FetchOptions{RemoteName: "origin", Force: true, RefSpecs: []config.RefSpec{
		config.RefSpec(ref + ":" + ref),
	}}

	if err = repo.Fetch(&fetchOptions); err != nil && !errors.Is(err, git.NoErrAlreadyUpToDate) {
		return fmt.Errorf("unable to fetch from remote: %w", err)
	}

	worktree, err := repo.Worktree()
	if err != nil {
		return fmt.Errorf("unable to open worktree: %w", err)
	}

	err = worktree.Checkout(&checkoutOptions)
	if err != nil {
		return fmt.Errorf("unable to checkout commit: %w", err)
	}

	_, err = repo.ResolveRevision(plumbing.Revision("HEAD"))
	if err != nil {
		return fmt.Errorf("unable to get new HEAD: %w", err)
	}
	return nil
}

// PluginIndex is a struct representing the user's preferences for plugin index
// and the plugin index on disk.
type PluginIndex struct {
	repo                  repoer
	directory             string
	disableUpdate         bool
	updateDurationMinutes int
}

// New initializes a new PluginIndex instance with the options passed in.
func New(directory string, disableUpdate bool, updateDurationMinutes int, repo repoer) PluginIndex {
	return PluginIndex{
		repo:                  repo,
		directory:             directory,
		disableUpdate:         disableUpdate,
		updateDurationMinutes: updateDurationMinutes,
	}
}

// Refresh may update the plugin repo if it hasn't been updated in longer
// than updateDurationMinutes. If the plugin repo needs to be updated the
// repo will be invoked to perform the actual Git pull.
func (p PluginIndex) Refresh() (bool, error) {
	err := os.MkdirAll(p.directory, os.ModePerm)
	if err != nil {
		return false, err
	}

	files, err := os.ReadDir(p.directory)
	if err != nil {
		return false, err
	}

	if len(files) == 0 {
		// directory empty, clone down repo
		err := p.repo.Install()
		if err != nil {
			return false, err
		}

		return touchFS(p.directory)
	}

	// directory must not be empty, repo must be present, maybe update
	updated, err := lastUpdated(p.directory)
	if err != nil {
		return p.doUpdate()
	}

	// Convert minutes to nanoseconds
	updateDurationNs := int64(p.updateDurationMinutes) * (6e10)

	if updated > updateDurationNs && !p.disableUpdate {
		return p.doUpdate()
	}

	return false, nil
}

func (p PluginIndex) doUpdate() (bool, error) {
	err := p.repo.Update()
	if err != nil {
		return false, err
	}

	// Touch update file
	return touchFS(p.directory)
}

// GetPluginSourceURL looks up a plugin by name and returns the repository URL
// for easy install by the user.
func (p PluginIndex) GetPluginSourceURL(name string) (string, error) {
	_, err := p.Refresh()
	if err != nil {
		return "", err
	}

	url, err := readPlugin(p.directory, name)
	if err != nil {
		return "", err
	}

	return url, nil
}

func touchFS(directory string) (bool, error) {
	filename := filepath.Join(directory, repoUpdatedFilename)
	file, err := os.OpenFile(filename, os.O_RDONLY|os.O_CREATE, 0o666)
	if err != nil {
		return false, fmt.Errorf("unable to create file plugin index touch file: %w", err)
	}

	file.Close()
	return true, nil
}

func lastUpdated(dir string) (int64, error) {
	info, err := os.Stat(filepath.Join(dir, repoUpdatedFilename))
	if err != nil {
		return 0, fmt.Errorf("unable to read last updated file: %w", err)
	}

	// info.Atime_ns now contains the last access time
	updated := time.Now().UnixNano() - info.ModTime().UnixNano()
	return updated, nil
}

func readPlugin(dir, name string) (string, error) {
	filename := filepath.Join(dir, "plugins", name)

	pluginInfo, err := ini.Load(filename)
	if err != nil {
		return "", fmt.Errorf("no such plugin found in plugin index: %s", name)
	}

	return pluginInfo.Section("").Key("repository").String(), nil
}

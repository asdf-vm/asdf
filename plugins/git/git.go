// Package git contains all the Git operations that can be applied to asdf
// plugins
package git

import (
	"fmt"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
	"github.com/go-git/go-git/v5/plumbing"
)

const remoteName = "origin"

// Plugin is a struct to contain the plugin Git details
type Plugin struct {
	directory string
}

// PluginOps is an interface for operations that can be applied to asdf plugins.
// Right now we only support Git, but in the future we might have other
// mechanisms to install and upgrade plugins. asdf doesn't require a plugin
// to be a Git repository when asdf uses it, but Git is the only way to install
// and upgrade plugins. If other approaches are supported this will be
// extracted into the `plugins` module.
type PluginOps interface {
	Clone(pluginURL string) error
	Head() (string, error)
	RemoteURL() (string, error)
	Update(ref string) (string, error)
}

// NewPlugin builds a new Plugin instance
func NewPlugin(directory string) Plugin {
	return Plugin{directory: directory}
}

// Clone installs a plugin via Git
func (g Plugin) Clone(pluginURL string) error {
	_, err := git.PlainClone(g.directory, false, &git.CloneOptions{
		URL: pluginURL,
	})
	if err != nil {
		return fmt.Errorf("unable to clone plugin: %w", err)
	}

	return nil
}

// Head returns the current HEAD ref of the plugin's Git repository
func (g Plugin) Head() (string, error) {
	repo, err := gitOpen(g.directory)
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
func (g Plugin) RemoteURL() (string, error) {
	repo, err := gitOpen(g.directory)
	if err != nil {
		return "", err
	}

	remotes, err := repo.Remotes()
	if err != nil {
		return "", err
	}

	return remotes[0].Config().URLs[0], nil
}

// Update updates the plugin's Git repository to the ref if provided, or the
// latest commit on the current branch
func (g Plugin) Update(ref string) (string, error) {
	repo, err := gitOpen(g.directory)
	if err != nil {
		return "", err
	}

	var checkoutOptions git.CheckoutOptions

	if ref == "" {
		// If no ref is provided checkout latest commit on current branch
		head, err := repo.Head()
		if err != nil {
			return "", err
		}

		if !head.Name().IsBranch() {
			return "", fmt.Errorf("not on a branch, unable to update")
		}

		// If on a branch checkout the latest version of it from the remote
		branch := head.Name()
		ref = branch.String()
		checkoutOptions = git.CheckoutOptions{Branch: branch, Force: true}
	} else {
		// Checkout ref if provided
		checkoutOptions = git.CheckoutOptions{Hash: plumbing.NewHash(ref), Force: true}
	}

	fetchOptions := git.FetchOptions{RemoteName: remoteName, Force: true, RefSpecs: []config.RefSpec{
		config.RefSpec(ref + ":" + ref),
	}}

	err = repo.Fetch(&fetchOptions)

	if err != nil && err != git.NoErrAlreadyUpToDate {
		return "", err
	}

	worktree, err := repo.Worktree()
	if err != nil {
		return "", err
	}

	err = worktree.Checkout(&checkoutOptions)
	if err != nil {
		return "", err
	}

	hash, err := repo.ResolveRevision(plumbing.Revision("HEAD"))
	return hash.String(), err
}

func gitOpen(directory string) (*git.Repository, error) {
	repo, err := git.PlainOpen(directory)
	if err != nil {
		return repo, fmt.Errorf("unable to open plugin Git repository: %w", err)
	}

	return repo, nil
}

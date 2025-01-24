// Package git contains all the Git operations that can be applied to asdf
// Git repositories like the plugin index repo and individual asdf plugins.
package git

import (
	"fmt"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
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
	options := git.CloneOptions{
		URL: pluginURL,
	}

	// if ref is provided set it on CloneOptions
	if ref != "" {
		options.ReferenceName = plumbing.NewBranchReferenceName(ref)
	}

	_, err := git.PlainClone(r.Directory, false, &options)
	if err != nil {
		return fmt.Errorf("unable to clone plugin: %w", err)
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

// Update updates the plugin's Git repository to the ref if provided, or the
// latest commit on the current branch
func (r Repo) Update(ref string) (string, string, string, error) {
	repo, err := gitOpen(r.Directory)
	if err != nil {
		return "", "", "", err
	}

	oldHash, err := repo.ResolveRevision(plumbing.Revision("HEAD"))
	if err != nil {
		return "", "", "", err
	}

	var checkoutOptions git.CheckoutOptions

	if ref == "" {
		// If no ref is provided checkout latest commit on current branch
		head, err := repo.Head()
		if err != nil {
			return "", "", "", err
		}

		if !head.Name().IsBranch() {
			return "", "", "", fmt.Errorf("not on a branch, unable to update")
		}

		// If on a branch checkout the latest version of it from the remote
		branch := head.Name()
		ref = branch.String()
		checkoutOptions = git.CheckoutOptions{Branch: branch, Force: true}
	} else {
		// Checkout ref if provided
		checkoutOptions = git.CheckoutOptions{Hash: plumbing.NewHash(ref), Force: true}
	}

	fetchOptions := git.FetchOptions{RemoteName: DefaultRemoteName, Force: true, RefSpecs: []config.RefSpec{
		config.RefSpec(ref + ":" + ref),
	}}

	err = repo.Fetch(&fetchOptions)

	if err != nil && err != git.NoErrAlreadyUpToDate {
		return "", "", "", err
	}

	worktree, err := repo.Worktree()
	if err != nil {
		return "", "", "", err
	}

	err = worktree.Checkout(&checkoutOptions)
	if err != nil {
		return "", "", "", err
	}

	newHash, err := repo.ResolveRevision(plumbing.Revision("HEAD"))
	return ref, oldHash.String(), newHash.String(), err
}

func gitOpen(directory string) (*git.Repository, error) {
	repo, err := git.PlainOpen(directory)
	if err != nil {
		return repo, fmt.Errorf("unable to open plugin Git repository: %w", err)
	}

	return repo, nil
}

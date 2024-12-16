package git

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/asdf-vm/asdf/repotest"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/stretchr/testify/assert"
)

func TestRepoClone(t *testing.T) {
	t.Run("when repo name is valid but URL is invalid prints an error", func(t *testing.T) {
		repo := NewRepo(t.TempDir())
		err := repo.Clone("foobar", "")

		assert.ErrorContains(t, err, "unable to clone plugin: repository not found")
	})

	t.Run("clones provided Git URL to repo directory when URL is valid", func(t *testing.T) {
		repoDir := generateRepo(t)
		directory := t.TempDir()
		repo := NewRepo(directory)

		err := repo.Clone(repoDir, "")
		assert.Nil(t, err)

		// Assert repo directory contains Git repo with bin directory
		_, err = os.ReadDir(directory + "/.git")
		assert.Nil(t, err)

		entries, err := os.ReadDir(directory + "/bin")
		assert.Nil(t, err)
		assert.Equal(t, 12, len(entries))
	})

	t.Run("when repo name and URL are valid but ref is invalid prints an error", func(t *testing.T) {
		repoDir := generateRepo(t)
		directory := t.TempDir()
		repo := NewRepo(directory)

		err := repo.Clone(repoDir, "non-existent")

		assert.ErrorContains(t, err, "unable to clone plugin: reference not found")
	})

	t.Run("clones a provided Git URL and checks out a specific ref when URL is valid and ref is provided", func(t *testing.T) {
		repoDir := generateRepo(t)
		directory := t.TempDir()
		repo := NewRepo(directory)

		err := repo.Clone(repoDir, "master")
		assert.Nil(t, err)

		// Assert repo directory contains Git repo with bin directory
		_, err = os.ReadDir(directory + "/.git")
		assert.Nil(t, err)

		entries, err := os.ReadDir(directory + "/bin")
		assert.Nil(t, err)
		assert.Equal(t, 12, len(entries))
	})
}

func TestRepoHead(t *testing.T) {
	repoDir := generateRepo(t)
	directory := t.TempDir()

	repo := NewRepo(directory)

	err := repo.Clone(repoDir, "")
	assert.Nil(t, err)

	head, err := repo.Head()
	assert.Nil(t, err)
	assert.NotZero(t, head)
}

func TestRepoRemoteURL(t *testing.T) {
	repoDir := generateRepo(t)
	directory := t.TempDir()

	repo := NewRepo(directory)

	err := repo.Clone(repoDir, "")
	assert.Nil(t, err)

	url, err := repo.RemoteURL()
	assert.Nil(t, err)
	assert.NotZero(t, url)
}

func TestRepoUpdate(t *testing.T) {
	repoDir := generateRepo(t)
	directory := t.TempDir()

	repo := NewRepo(directory)

	err := repo.Clone(repoDir, "")
	assert.Nil(t, err)

	t.Run("returns error when repo with name does not exist", func(t *testing.T) {
		nonexistantPath := filepath.Join(directory, "nonexistant")
		nonexistantRepo := NewRepo(nonexistantPath)
		updatedToRef, _, _, err := nonexistantRepo.Update("")

		assert.NotNil(t, err)
		assert.Equal(t, updatedToRef, "")
		expectedErrMsg := "unable to open plugin Git repository: repository does not exist"
		assert.ErrorContains(t, err, expectedErrMsg)
	})

	t.Run("returns error when repo repo does not exist", func(t *testing.T) {
		badRepoName := "badrepo"
		badRepoDir := filepath.Join(directory, badRepoName)
		err := os.MkdirAll(badRepoDir, 0o777)
		assert.Nil(t, err)

		badRepo := NewRepo(badRepoDir)

		updatedToRef, _, _, err := badRepo.Update("")

		assert.NotNil(t, err)
		assert.Equal(t, updatedToRef, "")
		expectedErrMsg := "unable to open plugin Git repository: repository does not exist"
		assert.ErrorContains(t, err, expectedErrMsg)
	})

	t.Run("does not return error when repo is already updated", func(t *testing.T) {
		// update repo twice to test already updated case
		updatedToRef, _, _, err := repo.Update("")
		assert.Nil(t, err)
		updatedToRef2, _, _, err := repo.Update("")
		assert.Nil(t, err)
		assert.Equal(t, updatedToRef, updatedToRef2)
	})

	t.Run("updates repo when repo when repo exists", func(t *testing.T) {
		latestHash, err := getCurrentCommit(directory)
		assert.Nil(t, err)

		_, err = checkoutPreviousCommit(directory)
		assert.Nil(t, err)

		updatedToRef, _, _, err := repo.Update("")
		assert.Nil(t, err)
		assert.Equal(t, "refs/heads/master", updatedToRef)

		currentHash, err := getCurrentCommit(directory)
		assert.Nil(t, err)
		assert.Equal(t, latestHash, currentHash)
	})

	t.Run("Returns error when specified ref does not exist", func(t *testing.T) {
		ref := "non-existant"
		updatedToRef, _, _, err := repo.Update(ref)
		assert.Equal(t, updatedToRef, "")
		expectedErrMsg := "couldn't find remote ref \"non-existant\""
		assert.ErrorContains(t, err, expectedErrMsg)
	})

	t.Run("updates repo to ref when repo with name and ref exist", func(t *testing.T) {
		ref := "master"

		hash, err := getCommit(directory, ref)
		assert.Nil(t, err)

		updatedToRef, _, newHash, err := repo.Update(ref)
		assert.Nil(t, err)
		assert.Equal(t, "master", updatedToRef)

		// Check that repo was updated to ref
		latestHash, err := getCurrentCommit(directory)
		assert.Nil(t, err)
		assert.Equal(t, hash, latestHash)
		assert.Equal(t, newHash, latestHash)
	})
}

func getCurrentCommit(path string) (string, error) {
	return getCommit(path, "HEAD")
}

func getCommit(path, revision string) (string, error) {
	repo, err := git.PlainOpen(path)
	if err != nil {
		return "", err
	}

	hash, err := repo.ResolveRevision(plumbing.Revision(revision))

	return hash.String(), err
}

func checkoutPreviousCommit(path string) (string, error) {
	repo, err := git.PlainOpen(path)
	if err != nil {
		return "", err
	}

	previousHash, err := repo.ResolveRevision(plumbing.Revision("HEAD~"))
	if err != nil {
		return "", err
	}

	worktree, err := repo.Worktree()
	if err != nil {
		return "", err
	}

	err = worktree.Reset(&git.ResetOptions{Commit: *previousHash})
	if err != nil {
		return "", err
	}

	return previousHash.String(), nil
}

func generateRepo(t *testing.T) string {
	t.Helper()
	tempDir := t.TempDir()
	path, err := repotest.GeneratePlugin("dummy_plugin", tempDir, "lua")

	assert.Nil(t, err)
	return path
}

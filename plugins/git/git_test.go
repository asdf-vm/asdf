package git

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/stretchr/testify/assert"
)

// TODO: Switch to local repo so tests don't go over the network
const (
	testRepo       = "https://github.com/Stratus3D/asdf-lua"
	testPluginName = "lua"
)

func TestPluginClone(t *testing.T) {
	t.Run("when plugin name is valid but URL is invalid prints an error", func(t *testing.T) {
		tempDir := t.TempDir()
		directory := filepath.Join(tempDir, testPluginName)

		plugin := NewPlugin(directory)
		err := plugin.Clone("foobar")

		assert.ErrorContains(t, err, "unable to clone plugin: repository not found")
	})

	t.Run("clones provided Git URL to plugin directory when URL is valid", func(t *testing.T) {
		tempDir := t.TempDir()
		directory := filepath.Join(tempDir, testPluginName)

		plugin := NewPlugin(directory)
		err := plugin.Clone(testRepo)

		assert.Nil(t, err)

		// Assert plugin directory contains Git repo with bin directory
		_, err = os.ReadDir(directory + "/.git")
		assert.Nil(t, err)

		entries, err := os.ReadDir(directory + "/bin")
		assert.Nil(t, err)
		assert.Equal(t, 5, len(entries))
	})
}

func TestPluginHead(t *testing.T) {
	tempDir := t.TempDir()
	directory := filepath.Join(tempDir, testPluginName)

	plugin := NewPlugin(directory)

	err := plugin.Clone(testRepo)
	assert.Nil(t, err)

	head, err := plugin.Head()
	assert.Nil(t, err)
	assert.NotZero(t, head)
}

func TestPluginRemoteURL(t *testing.T) {
	tempDir := t.TempDir()
	directory := filepath.Join(tempDir, testPluginName)

	plugin := NewPlugin(directory)

	err := plugin.Clone(testRepo)
	assert.Nil(t, err)

	url, err := plugin.RemoteURL()
	assert.Nil(t, err)
	assert.NotZero(t, url)
}

func TestPluginUpdate(t *testing.T) {
	tempDir := t.TempDir()
	directory := filepath.Join(tempDir, testPluginName)

	plugin := NewPlugin(directory)

	err := plugin.Clone(testRepo)
	assert.Nil(t, err)

	t.Run("returns error when plugin with name does not exist", func(t *testing.T) {
		nonexistantPath := filepath.Join(tempDir, "nonexistant")
		nonexistantPlugin := NewPlugin(nonexistantPath)
		updatedToRef, err := nonexistantPlugin.Update("")

		assert.NotNil(t, err)
		assert.Equal(t, updatedToRef, "")
		expectedErrMsg := "unable to open plugin Git repository: repository does not exist"
		assert.ErrorContains(t, err, expectedErrMsg)
	})

	t.Run("returns error when plugin repo does not exist", func(t *testing.T) {
		badPluginName := "badplugin"
		badPluginDir := filepath.Join(tempDir, badPluginName)
		err := os.MkdirAll(badPluginDir, 0777)
		assert.Nil(t, err)

		badPlugin := NewPlugin(badPluginDir)

		updatedToRef, err := badPlugin.Update("")

		assert.NotNil(t, err)
		assert.Equal(t, updatedToRef, "")
		expectedErrMsg := "unable to open plugin Git repository: repository does not exist"
		assert.ErrorContains(t, err, expectedErrMsg)
	})

	t.Run("does not return error when plugin is already updated", func(t *testing.T) {
		// update plugin twice to test already updated case
		updatedToRef, err := plugin.Update("")
		assert.Nil(t, err)
		updatedToRef2, err := plugin.Update("")
		assert.Nil(t, err)
		assert.Equal(t, updatedToRef, updatedToRef2)
	})

	t.Run("updates plugin when plugin when plugin exists", func(t *testing.T) {
		latestHash, err := getCurrentCommit(directory)
		assert.Nil(t, err)

		_, err = checkoutPreviousCommit(directory)
		assert.Nil(t, err)

		updatedToRef, err := plugin.Update("")
		assert.Nil(t, err)
		assert.Equal(t, latestHash, updatedToRef)

		currentHash, err := getCurrentCommit(directory)
		assert.Nil(t, err)
		assert.Equal(t, latestHash, currentHash)
	})

	t.Run("Returns error when specified ref does not exist", func(t *testing.T) {
		ref := "non-existant"
		updatedToRef, err := plugin.Update(ref)
		assert.Equal(t, updatedToRef, "")
		expectedErrMsg := "couldn't find remote ref \"non-existant\""
		assert.ErrorContains(t, err, expectedErrMsg)

	})

	t.Run("updates plugin to ref when plugin with name and ref exist", func(t *testing.T) {
		ref := "master"

		hash, err := getCommit(directory, ref)
		assert.Nil(t, err)

		updatedToRef, err := plugin.Update(ref)
		assert.Nil(t, err)
		assert.Equal(t, hash, updatedToRef)

		// Check that plugin was updated to ref
		latestHash, err := getCurrentCommit(directory)
		assert.Nil(t, err)
		assert.Equal(t, hash, latestHash)
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

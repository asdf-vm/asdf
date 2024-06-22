package pluginindex

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"time"

	"asdf/git"

	"github.com/stretchr/testify/assert"
)

const (
	realIndexURL    = "https://github.com/asdf-vm/asdf-plugins.git"
	badIndexURL     = "http://asdf-vm.com/non-existent"
	elixirPluginURL = "https://github.com/asdf-vm/asdf-elixir.git"
	erlangPluginURL = "https://github.com/asdf-vm/asdf-erlang.git"
)

type MockIndex struct {
	Directory string
	URL       string
}

// Only defined so MockIndex complies with git.Repoer interface. These are not
// used by pluginindex package code
func (m *MockIndex) Head() (string, error)      { return "", nil }
func (m *MockIndex) RemoteURL() (string, error) { return "", nil }

func (m *MockIndex) Clone(URL string) error {
	m.URL = URL

	if m.URL == badIndexURL {
		return errors.New("unable to clone: repository not found")
	}

	err := writeMockPluginFile(m.Directory, "elixir", elixirPluginURL)
	if err != nil {
		return err
	}

	return nil
}

func (m *MockIndex) Update(_ string) (string, error) {
	if m.URL == badIndexURL {
		return "", errors.New("unable to clone: repository not found")
	}

	// Write another plugin file to mimic update
	err := writeMockPluginFile(m.Directory, "erlang", erlangPluginURL)
	if err != nil {
		return "", err
	}

	return "", nil
}

func writeMockPluginFile(dir, pluginName, pluginURL string) error {
	dirname := filepath.Join(dir, "plugins")
	err := os.MkdirAll(dirname, os.ModePerm)
	if err != nil {
		return err
	}

	filename := filepath.Join(dirname, pluginName)
	file, err := os.OpenFile(filename, os.O_RDWR|os.O_CREATE, os.ModePerm)
	if err != nil {
		return err
	}
	defer file.Close()

	_, err = file.WriteString(fmt.Sprintf("repository = %s", pluginURL))
	if err != nil {
		return err
	}

	return nil
}

func TestGetPluginSourceURL(t *testing.T) {
	t.Run("with Git returns a plugin url when provided name of existing plugin", func(t *testing.T) {
		dir := t.TempDir()
		pluginIndex := New(dir, realIndexURL, true, 0, &git.Repo{Directory: dir})
		url, err := pluginIndex.GetPluginSourceURL("elixir")
		assert.Nil(t, err)
		assert.Equal(t, url, elixirPluginURL)
	})

	t.Run("returns a plugin url when provided name of existing plugin", func(t *testing.T) {
		dir := t.TempDir()
		pluginIndex := New(dir, realIndexURL, true, 0, &MockIndex{Directory: dir})
		url, err := pluginIndex.GetPluginSourceURL("elixir")
		assert.Nil(t, err)
		assert.Equal(t, url, elixirPluginURL)
	})

	t.Run("returns a plugin url when provided name of existing plugin when loading from cache", func(t *testing.T) {
		dir := t.TempDir()
		pluginIndex := New(dir, realIndexURL, false, 10, &MockIndex{Directory: dir})
		url, err := pluginIndex.GetPluginSourceURL("elixir")
		assert.Nil(t, err)
		assert.Equal(t, url, elixirPluginURL)

		url, err = pluginIndex.GetPluginSourceURL("elixir")
		assert.Nil(t, err)
		assert.Equal(t, url, elixirPluginURL)
	})

	t.Run("returns an error when given a name that isn't in the index", func(t *testing.T) {
		dir := t.TempDir()
		pluginIndex := New(dir, realIndexURL, false, 10, &MockIndex{Directory: dir})
		url, err := pluginIndex.GetPluginSourceURL("foobar")
		assert.EqualError(t, err, "plugin foobar not found in repository")
		assert.Equal(t, url, "")
	})

	t.Run("returns an error when plugin index cannot be updated", func(t *testing.T) {
		dir := t.TempDir()

		// create plain text file so it appears plugin index already exists on disk
		file, err := os.OpenFile(filepath.Join(dir, "test"), os.O_RDONLY|os.O_CREATE, 0o666)
		assert.Nil(t, err)
		file.Close()
		repo := MockIndex{Directory: dir, URL: badIndexURL}

		pluginIndex := New(dir, badIndexURL, false, 10, &repo)

		url, err := pluginIndex.GetPluginSourceURL("lua")
		assert.EqualError(t, err, "unable to clone: repository not found")
		assert.Equal(t, url, "")
	})

	t.Run("returns error when given non-existent plugin index", func(t *testing.T) {
		dir := t.TempDir()
		pluginIndex := New(dir, badIndexURL, false, 10, &MockIndex{Directory: dir})
		url, err := pluginIndex.GetPluginSourceURL("lua")
		assert.EqualError(t, err, "unable to clone: repository not found")
		assert.Equal(t, url, "")
	})
}

func TestRefresh(t *testing.T) {
	t.Run("with Git updates repo when called once", func(t *testing.T) {
		dir := t.TempDir()
		pluginIndex := New(dir, realIndexURL, false, 0, &git.Repo{Directory: dir})
		url, err := pluginIndex.GetPluginSourceURL("elixir")
		assert.Nil(t, err)
		assert.Equal(t, url, elixirPluginURL)

		updated, err := pluginIndex.Refresh()
		assert.Nil(t, err)
		assert.True(t, updated)
	})

	t.Run("updates repo when called once", func(t *testing.T) {
		dir := t.TempDir()
		pluginIndex := New(dir, realIndexURL, false, 0, &MockIndex{Directory: dir})

		updated, err := pluginIndex.Refresh()
		assert.Nil(t, err)
		assert.True(t, updated)

		url, err := pluginIndex.GetPluginSourceURL("erlang")
		assert.Nil(t, err)
		assert.Equal(t, url, erlangPluginURL)
	})

	t.Run("does not update index when time has not elaspsed", func(t *testing.T) {
		dir := t.TempDir()
		pluginIndex := New(dir, realIndexURL, false, 10, &MockIndex{Directory: dir})

		// Call Refresh twice, the second call should not perform an update
		updated, err := pluginIndex.Refresh()
		assert.Nil(t, err)
		assert.True(t, updated)

		updated, err = pluginIndex.Refresh()
		assert.Nil(t, err)
		assert.False(t, updated)
	})

	t.Run("updates plugin index when time has elaspsed", func(t *testing.T) {
		dir := t.TempDir()
		pluginIndex := New(dir, realIndexURL, false, 0, &MockIndex{Directory: dir})

		// Call Refresh twice, the second call should perform an update
		updated, err := pluginIndex.Refresh()
		assert.Nil(t, err)
		assert.True(t, updated)

		time.Sleep(10 * time.Nanosecond)
		updated, err = pluginIndex.Refresh()
		assert.Nil(t, err)
		assert.True(t, updated)
	})

	t.Run("returns error when plugin index repo doesn't exist", func(t *testing.T) {
		dir := t.TempDir()
		pluginIndex := New(dir, badIndexURL, false, 0, &MockIndex{Directory: dir})

		updated, err := pluginIndex.Refresh()
		assert.EqualError(t, err, "unable to clone: repository not found")
		assert.False(t, updated)
	})
}

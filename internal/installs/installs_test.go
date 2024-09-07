package installs

import (
	"os"
	"path/filepath"
	"testing"

	"asdf/internal/config"
	"asdf/internal/installtest"
	"asdf/internal/plugins"
	"asdf/repotest"

	"github.com/stretchr/testify/assert"
)

const testPluginName = "lua"

func TestDownloadPath(t *testing.T) {
	conf, plugin := generateConfig(t)

	t.Run("returns empty string when given path version", func(t *testing.T) {
		path := DownloadPath(conf, plugin, "path", "foo/bar")
		assert.Empty(t, path)
	})

	t.Run("returns empty string when given path version", func(t *testing.T) {
		path := DownloadPath(conf, plugin, "version", "1.2.3")
		assert.Equal(t, path, filepath.Join(conf.DataDir, "downloads", "lua", "1.2.3"))
	})
}

func TestInstallPath(t *testing.T) {
	conf, plugin := generateConfig(t)

	t.Run("returns empty string when given path version", func(t *testing.T) {
		path := InstallPath(conf, plugin, "path", "foo/bar")
		assert.Equal(t, path, "foo/bar")
	})

	t.Run("returns install path when given regular version as version", func(t *testing.T) {
		path := InstallPath(conf, plugin, "version", "1.2.3")
		assert.Equal(t, path, filepath.Join(conf.DataDir, "installs", "lua", "1.2.3"))
	})
}

func TestInstalled(t *testing.T) {
	conf, plugin := generateConfig(t)

	t.Run("returns empty slice for newly installed plugin", func(t *testing.T) {
		installedVersions, err := Installed(conf, plugin)
		assert.Nil(t, err)
		assert.Empty(t, installedVersions)
	})

	t.Run("returns slice of all installed versions for a tool", func(t *testing.T) {
		mockInstall(t, conf, plugin, "1.0.0")

		installedVersions, err := Installed(conf, plugin)
		assert.Nil(t, err)
		assert.Equal(t, installedVersions, []string{"1.0.0"})
	})
}

func TestIsInstalled(t *testing.T) {
	conf, plugin := generateConfig(t)
	installVersion(t, conf, plugin, "1.0.0")

	t.Run("returns false when not installed", func(t *testing.T) {
		assert.False(t, IsInstalled(conf, plugin, "version", "4.0.0"))
	})
	t.Run("returns true when installed", func(t *testing.T) {
		assert.True(t, IsInstalled(conf, plugin, "version", "1.0.0"))
	})
}

// helper functions
func generateConfig(t *testing.T) (config.Config, plugins.Plugin) {
	t.Helper()
	testDataDir := t.TempDir()
	conf, err := config.LoadConfig()
	assert.Nil(t, err)
	conf.DataDir = testDataDir

	_, err = repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)

	return conf, plugins.New(conf, testPluginName)
}

func mockInstall(t *testing.T, conf config.Config, plugin plugins.Plugin, version string) {
	t.Helper()
	path := InstallPath(conf, plugin, "version", version)
	err := os.MkdirAll(path, os.ModePerm)
	assert.Nil(t, err)
}

func installVersion(t *testing.T, conf config.Config, plugin plugins.Plugin, version string) {
	t.Helper()
	err := installtest.InstallOneVersion(conf, plugin, "version", version)
	assert.Nil(t, err)
}

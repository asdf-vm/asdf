package installs

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/installtest"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/toolversions"
	"github.com/asdf-vm/asdf/repotest"
	"github.com/stretchr/testify/assert"
)

const testPluginName = "lua"

func TestDownloadPath(t *testing.T) {
	conf, plugin := generateConfig(t)

	t.Run("returns empty string when given path version", func(t *testing.T) {
		version := toolversions.Version{Type: "path", Value: "foo/bar"}
		path := DownloadPath(conf, plugin, version)
		assert.Empty(t, path)
	})

	t.Run("returns empty string when given path version", func(t *testing.T) {
		version := toolversions.Version{Type: "version", Value: "1.2.3"}
		path := DownloadPath(conf, plugin, version)
		assert.Equal(t, path, filepath.Join(conf.DataDir, "downloads", "lua", "1.2.3"))
	})
}

func TestInstallPath(t *testing.T) {
	conf, plugin := generateConfig(t)

	t.Run("returns empty string when given path version", func(t *testing.T) {
		version := toolversions.Version{Type: "path", Value: "foo/bar"}
		path := InstallPath(conf, plugin, version)
		assert.Equal(t, path, "foo/bar")
	})

	t.Run("returns install path when given regular version as version", func(t *testing.T) {
		version := toolversions.Version{Type: "version", Value: "1.2.3"}
		path := InstallPath(conf, plugin, version)
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
		version := toolversions.Version{Type: "version", Value: "4.0.0"}
		assert.False(t, IsInstalled(conf, plugin, version))
	})
	t.Run("returns true when installed", func(t *testing.T) {
		version := toolversions.Version{Type: "version", Value: "1.0.0"}
		assert.True(t, IsInstalled(conf, plugin, version))
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

func mockInstall(t *testing.T, conf config.Config, plugin plugins.Plugin, versionStr string) {
	t.Helper()
	version := toolversions.Version{Type: "version", Value: versionStr}
	path := InstallPath(conf, plugin, version)
	err := os.MkdirAll(path, os.ModePerm)
	assert.Nil(t, err)
}

func installVersion(t *testing.T, conf config.Config, plugin plugins.Plugin, version string) {
	t.Helper()
	err := installtest.InstallOneVersion(conf, plugin, "version", version)
	assert.Nil(t, err)
}

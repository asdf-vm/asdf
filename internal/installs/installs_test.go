package installs

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/data"
	"github.com/asdf-vm/asdf/internal/installtest"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/repotest"
	"github.com/asdf-vm/asdf/internal/toolversions"
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

	t.Run("expands leading ~/ in path version to home directory", func(t *testing.T) {
		homeDir, err := os.UserHomeDir()
		assert.Nil(t, err)

		version := toolversions.Version{Type: "path", Value: "~/src/elixir"}
		path := InstallPath(conf, plugin, version)
		assert.Equal(t, path, filepath.Join(homeDir, "src", "elixir"))
	})

	t.Run("leaves a path version without a leading ~/ unchanged", func(t *testing.T) {
		for _, value := range []string{"/opt/elixir", "foo/bar", "~elixir/src", "src/~/elixir"} {
			version := toolversions.Version{Type: "path", Value: value}
			assert.Equal(t, InstallPath(conf, plugin, version), value)
		}
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

	t.Run("filters out directories with incomplete marker", func(t *testing.T) {
		mockInstall(t, conf, plugin, "1.0.0")
		mockInstall(t, conf, plugin, "2.0.0")
		mockInstall(t, conf, plugin, "3.0.0")

		version2 := toolversions.Version{Type: "version", Value: "2.0.0"}
		err := markIncomplete(conf, plugin, version2)
		assert.Nil(t, err)

		installedVersions, err := Installed(conf, plugin)
		assert.Nil(t, err)
		assert.Equal(t, 2, len(installedVersions))
		assert.Contains(t, installedVersions, "1.0.0")
		assert.Contains(t, installedVersions, "3.0.0")
		assert.NotContains(t, installedVersions, "2.0.0")
	})

	t.Run("continues scanning and reports error when a marker lookup fails", func(t *testing.T) {
		if os.Geteuid() == 0 {
			t.Skip("permission checks do not apply when running as root")
		}

		conf4, plugin4 := generateConfig(t)
		mockInstall(t, conf4, plugin4, "1.0.0")
		mockInstall(t, conf4, plugin4, "2.0.0")
		mockInstall(t, conf4, plugin4, "3.0.0")

		locksDir := data.InstallLocksDirectory(conf4.DataDir, plugin4.Name)
		assert.Nil(t, os.MkdirAll(locksDir, 0o755))
		assert.Nil(t, os.Chmod(locksDir, 0o000))
		t.Cleanup(func() { _ = os.Chmod(locksDir, 0o755) })

		installedVersions, err := Installed(conf4, plugin4)
		assert.Empty(t, installedVersions)
		assert.NotNil(t, err)
	})

	t.Run("returns all versions when none have incomplete marker", func(t *testing.T) {
		conf2, plugin2 := generateConfig(t)
		mockInstall(t, conf2, plugin2, "1.0.0")
		mockInstall(t, conf2, plugin2, "2.0.0")

		installedVersions, err := Installed(conf2, plugin2)
		assert.Nil(t, err)
		assert.Equal(t, 2, len(installedVersions))
	})

	t.Run("filters out ref installs with incomplete marker", func(t *testing.T) {
		conf3, plugin3 := generateConfig(t)
		refVersion := toolversions.Version{Type: "ref", Value: "foo"}
		path := InstallPath(conf3, plugin3, refVersion)
		err := os.MkdirAll(path, os.ModePerm)
		assert.Nil(t, err)

		err = markIncomplete(conf3, plugin3, refVersion)
		assert.Nil(t, err)

		installedVersions, err := Installed(conf3, plugin3)
		assert.Nil(t, err)
		assert.Empty(t, installedVersions)
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

	t.Run("returns false when directory exists but has incomplete marker", func(t *testing.T) {
		version := toolversions.Version{Type: "version", Value: "2.0.0"}
		mockInstall(t, conf, plugin, "2.0.0")

		err := markIncomplete(conf, plugin, version)
		assert.Nil(t, err)

		assert.False(t, IsInstalled(conf, plugin, version))
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

func markIncomplete(conf config.Config, plugin plugins.Plugin, version toolversions.Version) error {
	markerPath := IncompleteMarkerPath(conf, plugin, version)
	err := os.MkdirAll(filepath.Dir(markerPath), 0o755)
	if err != nil {
		return err
	}
	file, err := os.Create(markerPath)
	if err != nil {
		return err
	}
	defer file.Close()
	return nil
}

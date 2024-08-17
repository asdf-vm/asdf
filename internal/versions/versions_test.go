package versions

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"asdf/config"
	"asdf/plugins"
	"asdf/repotest"

	"github.com/stretchr/testify/assert"
)

const testPluginName = "lua"

func TestInstallOneVersion(t *testing.T) {
	t.Setenv("ASDF_CONFIG_FILE", "testdata/asdfrc")

	t.Run("returns error when plugin doesn't exist", func(t *testing.T) {
		conf, _ := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugins.New(conf, "non-existent"), "1.2.3", false, &stdout, &stderr)
		assert.IsType(t, plugins.PluginMissing{}, err)
	})

	t.Run("returns error when plugin version is 'system'", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "system", false, &stdout, &stderr)
		assert.IsType(t, UninstallableVersion{}, err)
	})

	t.Run("installs latest version of tool when version is 'latest'", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "latest", false, &stdout, &stderr)
		assert.Nil(t, err)
	})

	t.Run("returns error when version doesn't exist", func(t *testing.T) {
		version := "other-dummy"
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, version, false, &stdout, &stderr)
		assert.Errorf(t, err, "failed to run install callback: exit status 1")

		want := "pre_asdf_download_lua other-dummy\npre_asdf_install_lua other-dummy\nDummy couldn't install version: other-dummy (on purpose)\n"
		assert.Equal(t, want, stdout.String())

		assertNotInstalled(t, conf.DataDir, plugin.Name, version)
	})

	t.Run("returns error when version already installed", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "1.0.0", false, &stdout, &stderr)
		assert.Nil(t, err)
		assertInstalled(t, conf.DataDir, plugin.Name, "1.0.0")

		// Install a second time
		err = InstallOneVersion(conf, plugin, "1.0.0", false, &stdout, &stderr)
		assert.NotNil(t, err)
	})

	t.Run("creates download directory", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "1.0.0", false, &stdout, &stderr)
		assert.Nil(t, err)

		downloadPath := filepath.Join(conf.DataDir, "downloads", plugin.Name, "1.0.0")
		pathInfo, err := os.Stat(downloadPath)
		assert.Nil(t, err)
		assert.True(t, pathInfo.IsDir())
	})

	t.Run("creates install directory", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "1.0.0", false, &stdout, &stderr)
		assert.Nil(t, err)

		installPath := filepath.Join(conf.DataDir, "installs", plugin.Name, "1.0.0")
		pathInfo, err := os.Stat(installPath)
		assert.Nil(t, err)
		assert.True(t, pathInfo.IsDir())
	})

	t.Run("runs pre-download, pre-install and post-install hooks when installation successful", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "1.0.0", false, &stdout, &stderr)
		assert.Nil(t, err)
		assert.Equal(t, "", stderr.String())
		want := "pre_asdf_download_lua 1.0.0\npre_asdf_install_lua 1.0.0\npost_asdf_install_lua 1.0.0\n"
		assert.Equal(t, want, stdout.String())
	})

	t.Run("installs successfully when plugin exists but version does not", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "1.0.0", false, &stdout, &stderr)
		assert.Nil(t, err)

		// Check download directory
		downloadPath := filepath.Join(conf.DataDir, "downloads", plugin.Name, "1.0.0")
		entries, err := os.ReadDir(downloadPath)
		assert.Nil(t, err)
		// mock plugin doesn't write anything
		assert.Empty(t, entries)

		// Check install directory
		assertInstalled(t, conf.DataDir, plugin.Name, "1.0.0")
	})

	t.Run("install successfully when plugin lacks download callback", func(t *testing.T) {
		conf, _ := generateConfig(t)
		stdout, stderr := buildOutputs()
		testPluginName := "no-download"
		_, err := repotest.InstallPlugin("dummy_plugin_no_download", conf.DataDir, testPluginName)
		assert.Nil(t, err)
		plugin := plugins.New(conf, testPluginName)

		err = InstallOneVersion(conf, plugin, "1.0.0", false, &stdout, &stderr)
		assert.Nil(t, err)

		// no-download install script prints 'install'
		assert.Equal(t, "install", stdout.String())
	})
}

func TestLatest(t *testing.T) {
	pluginName := "latest_test"
	conf, _ := generateConfig(t)
	_, err := repotest.InstallPlugin("dummy_legacy_plugin", conf.DataDir, pluginName)
	assert.Nil(t, err)
	plugin := plugins.New(conf, pluginName)

	t.Run("when plugin has a latest-stable callback invokes it and returns version it printed", func(t *testing.T) {
		pluginName := "latest-with-callback"
		_, err := repotest.InstallPlugin("dummy_plugin", conf.DataDir, pluginName)
		assert.Nil(t, err)
		plugin := plugins.New(conf, pluginName)

		versions, err := Latest(plugin, "")
		assert.Nil(t, err)
		assert.Equal(t, []string{"2.0.0"}, versions)
	})

	t.Run("when given query matching no versions return empty slice of versions", func(t *testing.T) {
		versions, err := Latest(plugin, "impossible-to-satisfy-query")
		assert.Nil(t, err)
		assert.Empty(t, versions)
	})

	t.Run("when given no query returns latest version of plugin", func(t *testing.T) {
		versions, err := Latest(plugin, "")
		assert.Nil(t, err)
		assert.Equal(t, []string{"5.1.0"}, versions)
	})

	t.Run("when given no query returns latest version of plugin", func(t *testing.T) {
		versions, err := Latest(plugin, "^4")
		assert.Nil(t, err)
		assert.Equal(t, []string{"4.0.0"}, versions)
	})
}

func TestParseString(t *testing.T) {
	t.Run("returns 'version', and unmodified version when passed semantic version", func(t *testing.T) {
		versionType, version := ParseString("1.2.3")
		assert.Equal(t, versionType, "version")
		assert.Equal(t, version, "1.2.3")
	})

	t.Run("returns 'ref' and reference version when passed a ref version", func(t *testing.T) {
		versionType, version := ParseString("ref:abc123")
		assert.Equal(t, versionType, "ref")
		assert.Equal(t, version, "abc123")
	})

	t.Run("returns 'ref' and empty string when passed 'ref:'", func(t *testing.T) {
		versionType, version := ParseString("ref:")
		assert.Equal(t, versionType, "ref")
		assert.Equal(t, version, "")
	})
}

func TestAllVersions(t *testing.T) {
	pluginName := "list-all-test"
	conf, _ := generateConfig(t)
	_, err := repotest.InstallPlugin("dummy_plugin", conf.DataDir, pluginName)
	assert.Nil(t, err)
	plugin := plugins.New(conf, pluginName)

	t.Run("returns slice of available versions from plugin", func(t *testing.T) {
		versions, err := AllVersions(plugin)
		assert.Nil(t, err)
		assert.Equal(t, versions, []string{"1.0.0", "1.1.0", "2.0.0"})
	})

	t.Run("returns error when callback missing", func(t *testing.T) {
		pluginName = "list-all-fail"
		_, err := repotest.InstallPlugin("dummy_plugin_no_download", conf.DataDir, pluginName)
		assert.Nil(t, err)
		plugin := plugins.New(conf, pluginName)

		versions, err := AllVersions(plugin)
		assert.Equal(t, err.(plugins.NoCallbackError).Error(), "Plugin named list-all-fail does not have a callback named list-all")
		assert.Empty(t, versions)
	})
}

// Helper functions
func buildOutputs() (strings.Builder, strings.Builder) {
	var stdout strings.Builder
	var stderr strings.Builder

	return stdout, stderr
}

func assertInstalled(t *testing.T, dataDir, pluginName, version string) {
	t.Helper()

	installPath := filepath.Join(dataDir, "installs", pluginName, version)
	entries, err := os.ReadDir(installPath)
	assert.Nil(t, err)

	var fileNames []string
	for _, e := range entries {
		fileNames = append(fileNames, e.Name())
	}

	assert.Equal(t, fileNames, []string{"bin", "env", "version"})
}

func assertNotInstalled(t *testing.T, dataDir, pluginName, version string) {
	t.Helper()

	installPath := filepath.Join(dataDir, "installs", pluginName, version)
	entries, err := os.ReadDir(installPath)
	assert.Empty(t, entries)
	assert.Nil(t, err)
}

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

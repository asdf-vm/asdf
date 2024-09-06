package versions

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"asdf/internal/config"
	"asdf/internal/plugins"
	"asdf/repotest"

	"github.com/stretchr/testify/assert"
)

const testPluginName = "lua"

func TestInstallAll(t *testing.T) {
	t.Run("installs multiple tools when multiple tool versions are specified", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		currentDir := t.TempDir()
		secondPlugin := installPlugin(t, conf, "dummy_plugin", "another")
		version := "1.0.0"

		// write a version file
		content := fmt.Sprintf("%s %s\n%s %s", plugin.Name, version, secondPlugin.Name, version)
		writeVersionFile(t, currentDir, content)

		err := InstallAll(conf, currentDir, &stdout, &stderr)
		assert.Nil(t, err)

		assertVersionInstalled(t, conf.DataDir, plugin.Name, version)
		assertVersionInstalled(t, conf.DataDir, secondPlugin.Name, version)
	})

	t.Run("only installs tools with versions specified for current directory", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		currentDir := t.TempDir()
		secondPlugin := installPlugin(t, conf, "dummy_plugin", "another")
		version := "1.0.0"

		// write a version file
		content := fmt.Sprintf("%s %s\n", plugin.Name, version)
		writeVersionFile(t, currentDir, content)

		err := InstallAll(conf, currentDir, &stdout, &stderr)
		assert.ErrorContains(t, err[0], "no version set")

		assertVersionInstalled(t, conf.DataDir, plugin.Name, version)
		assertNotInstalled(t, conf.DataDir, secondPlugin.Name, version)
	})

	t.Run("installs all tools even after one fails to install", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		currentDir := t.TempDir()
		secondPlugin := installPlugin(t, conf, "dummy_plugin", "another")
		version := "1.0.0"

		// write a version file
		content := fmt.Sprintf("%s %s\n%s %s", secondPlugin.Name, "non-existent-version", plugin.Name, version)
		writeVersionFile(t, currentDir, content)

		err := InstallAll(conf, currentDir, &stdout, &stderr)
		assert.Empty(t, err)

		assertNotInstalled(t, conf.DataDir, secondPlugin.Name, version)
		assertVersionInstalled(t, conf.DataDir, plugin.Name, version)
	})
}

func TestInstall(t *testing.T) {
	conf, plugin := generateConfig(t)
	stdout, stderr := buildOutputs()
	currentDir := t.TempDir()

	t.Run("installs version of tool specified for current directory", func(t *testing.T) {
		version := "1.0.0"
		// write a version file
		data := []byte(fmt.Sprintf("%s %s", plugin.Name, version))
		err := os.WriteFile(filepath.Join(currentDir, ".tool-versions"), data, 0o666)
		assert.Nil(t, err)

		err = Install(conf, plugin, currentDir, &stdout, &stderr)
		assert.Nil(t, err)

		assertVersionInstalled(t, conf.DataDir, plugin.Name, version)
	})

	t.Run("returns error when plugin doesn't exist", func(t *testing.T) {
		conf, _ := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := Install(conf, plugins.New(conf, "non-existent"), currentDir, &stdout, &stderr)
		assert.IsType(t, plugins.PluginMissing{}, err)
	})

	t.Run("returns error when no version set", func(t *testing.T) {
		conf, _ := generateConfig(t)
		stdout, stderr := buildOutputs()
		currentDir := t.TempDir()
		err := Install(conf, plugin, currentDir, &stdout, &stderr)
		assert.EqualError(t, err, "no version set")
	})

	t.Run("if multiple versions are defined installs all of them", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		currentDir := t.TempDir()

		versions := "1.0.0 2.0.0"
		// write a version file
		data := []byte(fmt.Sprintf("%s %s", plugin.Name, versions))
		err := os.WriteFile(filepath.Join(currentDir, ".tool-versions"), data, 0o666)
		assert.Nil(t, err)

		err = Install(conf, plugin, currentDir, &stdout, &stderr)
		assert.Nil(t, err)

		assertVersionInstalled(t, conf.DataDir, plugin.Name, "1.0.0")
		assertVersionInstalled(t, conf.DataDir, plugin.Name, "2.0.0")
	})
}

func TestInstallVersion(t *testing.T) {
	t.Setenv("ASDF_CONFIG_FILE", "testdata/asdfrc")

	t.Run("returns error when plugin doesn't exist", func(t *testing.T) {
		conf, _ := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallVersion(conf, plugins.New(conf, "non-existent"), "1.2.3", "", &stdout, &stderr)
		assert.IsType(t, plugins.PluginMissing{}, err)
	})

	t.Run("installs latest version of tool when version is 'latest'", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallVersion(conf, plugin, "latest", "", &stdout, &stderr)
		assert.Nil(t, err)

		assertVersionInstalled(t, conf.DataDir, plugin.Name, "2.0.0")
	})

	t.Run("installs specific version of tool", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()

		err := InstallVersion(conf, plugin, "latest", "^1.", &stdout, &stderr)
		assert.Nil(t, err)

		assertVersionInstalled(t, conf.DataDir, plugin.Name, "1.1.0")
	})
}

func TestInstallOneVersion(t *testing.T) {
	t.Setenv("ASDF_CONFIG_FILE", "testdata/asdfrc")

	t.Run("returns error when plugin doesn't exist", func(t *testing.T) {
		conf, _ := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugins.New(conf, "non-existent"), "1.2.3", &stdout, &stderr)
		assert.IsType(t, plugins.PluginMissing{}, err)
	})

	t.Run("returns error when plugin version is 'system'", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "system", &stdout, &stderr)
		assert.IsType(t, UninstallableVersionError{}, err)
	})

	t.Run("returns error when version doesn't exist", func(t *testing.T) {
		version := "other-dummy"
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, version, &stdout, &stderr)
		assert.Errorf(t, err, "failed to run install callback: exit status 1")

		want := "pre_asdf_download_lua other-dummy\npre_asdf_install_lua other-dummy\nDummy couldn't install version: other-dummy (on purpose)\n"
		assert.Equal(t, want, stdout.String())

		assertNotInstalled(t, conf.DataDir, plugin.Name, version)
	})

	t.Run("returns error when version already installed", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "1.0.0", &stdout, &stderr)
		assert.Nil(t, err)
		assertVersionInstalled(t, conf.DataDir, plugin.Name, "1.0.0")

		// Install a second time
		err = InstallOneVersion(conf, plugin, "1.0.0", &stdout, &stderr)
		assert.NotNil(t, err)
	})

	t.Run("creates download directory", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "1.0.0", &stdout, &stderr)
		assert.Nil(t, err)

		downloadPath := filepath.Join(conf.DataDir, "downloads", plugin.Name, "1.0.0")
		pathInfo, err := os.Stat(downloadPath)
		assert.Nil(t, err)
		assert.True(t, pathInfo.IsDir())
	})

	t.Run("creates install directory", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "1.0.0", &stdout, &stderr)
		assert.Nil(t, err)

		installPath := filepath.Join(conf.DataDir, "installs", plugin.Name, "1.0.0")
		pathInfo, err := os.Stat(installPath)
		assert.Nil(t, err)
		assert.True(t, pathInfo.IsDir())
	})

	t.Run("runs pre-download, pre-install and post-install hooks when installation successful", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "1.0.0", &stdout, &stderr)
		assert.Nil(t, err)
		assert.Equal(t, "", stderr.String())
		want := "pre_asdf_download_lua 1.0.0\npre_asdf_install_lua 1.0.0\npost_asdf_install_lua 1.0.0\n"
		assert.Equal(t, want, stdout.String())
	})

	t.Run("installs successfully when plugin exists but version does not", func(t *testing.T) {
		conf, plugin := generateConfig(t)
		stdout, stderr := buildOutputs()
		err := InstallOneVersion(conf, plugin, "1.0.0", &stdout, &stderr)
		assert.Nil(t, err)

		// Check download directory
		downloadPath := filepath.Join(conf.DataDir, "downloads", plugin.Name, "1.0.0")
		entries, err := os.ReadDir(downloadPath)
		assert.Nil(t, err)
		// mock plugin doesn't write anything
		assert.Empty(t, entries)

		// Check install directory
		assertVersionInstalled(t, conf.DataDir, plugin.Name, "1.0.0")
	})

	t.Run("install successfully when plugin lacks download callback", func(t *testing.T) {
		conf, _ := generateConfig(t)
		stdout, stderr := buildOutputs()
		testPluginName := "no-download"
		_, err := repotest.InstallPlugin("dummy_plugin_no_download", conf.DataDir, testPluginName)
		assert.Nil(t, err)
		plugin := plugins.New(conf, testPluginName)

		err = InstallOneVersion(conf, plugin, "1.0.0", &stdout, &stderr)
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

		version, err := Latest(plugin, "")
		assert.Nil(t, err)
		assert.Equal(t, "2.0.0", version)
	})

	t.Run("when given query matching no versions return empty slice of versions", func(t *testing.T) {
		version, err := Latest(plugin, "impossible-to-satisfy-query")
		assert.Error(t, err, "no latest version found")
		assert.Equal(t, version, "")
	})

	t.Run("when given no query returns latest version of plugin", func(t *testing.T) {
		version, err := Latest(plugin, "")
		assert.Nil(t, err)
		assert.Equal(t, "5.1.0", version)
	})

	t.Run("when given no query returns latest version of plugin", func(t *testing.T) {
		version, err := Latest(plugin, "4")
		assert.Nil(t, err)
		assert.Equal(t, "4.0.0", version)
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

func assertVersionInstalled(t *testing.T, dataDir, pluginName, version string) {
	t.Helper()

	installDir := filepath.Join(dataDir, "installs", pluginName, version)
	installedVersionFile := filepath.Join(installDir, "version")

	bytes, err := os.ReadFile(installedVersionFile)
	assert.Nil(t, err, "expected file from install to exist")

	want := fmt.Sprintf("%s\n", version)
	assert.Equal(t, want, string(bytes), "got wrong version")

	entries, err := os.ReadDir(installDir)
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
	if err != nil && !os.IsNotExist(err) {
		t.Errorf("failed to check directory %s due to error %s", installPath, err)
	}
	assert.Empty(t, entries)
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

func installPlugin(t *testing.T, conf config.Config, fixture, name string) plugins.Plugin {
	_, err := repotest.InstallPlugin(fixture, conf.DataDir, name)
	assert.Nil(t, err)
	return plugins.New(conf, name)
}

func writeVersionFile(t *testing.T, dir, contents string) {
	t.Helper()
	err := os.WriteFile(filepath.Join(dir, ".tool-versions"), []byte(contents), 0o666)
	assert.Nil(t, err)
}

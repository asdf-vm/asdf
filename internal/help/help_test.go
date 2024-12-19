package help

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/repotest"
	"github.com/stretchr/testify/assert"
)

const (
	version        = "0.15.0"
	testPluginName = "lua"
)

func TestWrite(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}
	err := os.MkdirAll(filepath.Join(testDataDir, "plugins"), 0o777)
	assert.Nil(t, err)

	// install dummy plugin
	_, err = repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)
	plugin := plugins.New(conf, testPluginName)
	writeExtensionCommand(t, plugin, "", "")

	var stdout strings.Builder

	err = Write(version, []plugins.Plugin{plugin}, &stdout)
	assert.Nil(t, err)
	output := stdout.String()

	// Simple format assertions
	assert.Contains(t, output, "version: ")
	assert.Contains(t, output, "MANAGE PLUGINS\n")
	assert.Contains(t, output, "MANAGE TOOLS\n")
	assert.Contains(t, output, "UTILS\n")
	assert.Contains(t, output, "RESOURCES\n")
	assert.Contains(t, output, "PLUGIN lua\n")
}

func TestWriteToolHelp(t *testing.T) {
	conf, plugin := generateConfig(t)

	t.Run("when plugin implements all help callbacks", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder

		err := WriteToolHelp(conf, plugin.Name, &stdout, &stderr)

		assert.Nil(t, err)
		assert.Empty(t, stderr.String())
		expected := "Dummy plugin documentation\n\nDummy plugin is a plugin only used for unit tests\n"
		assert.Equal(t, stdout.String(), expected)
	})

	t.Run("when plugin does not have help.overview callback", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder
		plugin := installPlugin(t, conf, "dummy_legacy_plugin", "legacy-plugin")

		err := WriteToolHelp(conf, plugin.Name, &stdout, &stderr)

		assert.EqualError(t, err, "Plugin named legacy-plugin does not have a callback named help.overview")
		assert.Empty(t, stdout.String())
		assert.Equal(t, stderr.String(), "No documentation for plugin legacy-plugin\n")
	})

	t.Run("when plugin does not exist", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder

		err := WriteToolHelp(conf, "non-existent", &stdout, &stderr)

		assert.EqualError(t, err, "Plugin named non-existent not installed")
		assert.Empty(t, stdout.String())
		assert.Equal(t, stderr.String(), "No plugin named non-existent\n")
	})
}

func TestWriteToolVersionHelp(t *testing.T) {
	conf, plugin := generateConfig(t)

	t.Run("when plugin implements all help callbacks", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder

		err := WriteToolVersionHelp(conf, plugin.Name, "1.2.3", &stdout, &stderr)

		assert.Nil(t, err)
		assert.Empty(t, stderr.String())
		expected := "Dummy plugin documentation\n\nDummy plugin is a plugin only used for unit tests\n\nDetails specific for version 1.2.3\n"
		assert.Equal(t, stdout.String(), expected)
	})

	t.Run("when plugin does not have help.overview callback", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder
		plugin := installPlugin(t, conf, "dummy_legacy_plugin", "legacy-plugin")

		err := WriteToolVersionHelp(conf, plugin.Name, "1.2.3", &stdout, &stderr)

		assert.EqualError(t, err, "Plugin named legacy-plugin does not have a callback named help.overview")
		assert.Empty(t, stdout.String())
		assert.Equal(t, stderr.String(), "No documentation for plugin legacy-plugin\n")
	})

	t.Run("when plugin does not exist", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder

		err := WriteToolVersionHelp(conf, "non-existent", "1.2.3", &stdout, &stderr)

		assert.EqualError(t, err, "Plugin named non-existent not installed")
		assert.Empty(t, stdout.String())
		assert.Equal(t, stderr.String(), "No plugin named non-existent\n")
	})
}

func generateConfig(t *testing.T) (config.Config, plugins.Plugin) {
	t.Helper()
	testDataDir := t.TempDir()
	conf, err := config.LoadConfig()
	assert.Nil(t, err)
	conf.DataDir = testDataDir

	return conf, installPlugin(t, conf, "dummy_plugin", testPluginName)
}

func installPlugin(t *testing.T, conf config.Config, fixture, pluginName string) plugins.Plugin {
	_, err := repotest.InstallPlugin(fixture, conf.DataDir, pluginName)
	assert.Nil(t, err)

	return plugins.New(conf, pluginName)
}

func writeExtensionCommand(t *testing.T, plugin plugins.Plugin, name, contents string) error {
	t.Helper()
	assert.Nil(t, os.MkdirAll(filepath.Join(plugin.Dir, "lib", "commands"), 0o777))
	filename := "command"
	if name != "" {
		filename = fmt.Sprintf("command-%s", name)
	}

	path := filepath.Join(plugin.Dir, "lib", "commands", filename)
	err := os.WriteFile(path, []byte(contents), 0o777)
	return err
}

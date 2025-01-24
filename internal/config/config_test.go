package config

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLoadConfig(t *testing.T) {
	config, err := LoadConfig()

	assert.Nil(t, err, "Returned error when building config")

	assert.NotZero(t, config.Home, "Expected Home to be set")
}

func TestLoadConfigEnv(t *testing.T) {
	config, err := loadConfigEnv()

	assert.Nil(t, err, "Returned error when loading env for config")

	assert.Zero(t, config.Home, "Shouldn't set Home property when loading config")
}

func TestLoadSettings(t *testing.T) {
	t.Run("When given invalid path returns error", func(t *testing.T) {
		settings, err := loadSettings("./foobar")

		if err == nil {
			t.Fatal("Didn't get an error")
		}

		if settings.Loaded {
			t.Fatal("Didn't expect settings to be loaded")
		}
	})

	t.Run("When given path to populated asdfrc returns populated settings struct", func(t *testing.T) {
		settings, err := loadSettings("testdata/asdfrc")

		assert.Nil(t, err)

		assert.True(t, settings.Loaded, "Expected Loaded field to be set to true")
		assert.True(t, settings.LegacyVersionFile, "LegacyVersionFile field has wrong value")
		assert.True(t, settings.AlwaysKeepDownload, "AlwaysKeepDownload field has wrong value")
		assert.True(t, settings.PluginRepositoryLastCheckDuration.Never, "PluginRepositoryLastCheckDuration field has wrong value")
		assert.Zero(t, settings.PluginRepositoryLastCheckDuration.Every, "PluginRepositoryLastCheckDuration field has wrong value")
		assert.True(t, settings.DisablePluginShortNameRepository, "DisablePluginShortNameRepository field has wrong value")
	})

	t.Run("When given path to empty file returns settings struct with defaults", func(t *testing.T) {
		settings, err := loadSettings("testdata/empty-asdfrc")

		assert.Nil(t, err)

		assert.False(t, settings.LegacyVersionFile, "LegacyVersionFile field has wrong value")
		assert.False(t, settings.AlwaysKeepDownload, "AlwaysKeepDownload field has wrong value")
		assert.False(t, settings.PluginRepositoryLastCheckDuration.Never, "PluginRepositoryLastCheckDuration field has wrong value")
		assert.Equal(t, settings.PluginRepositoryLastCheckDuration.Every, 60, "PluginRepositoryLastCheckDuration field has wrong value")
		assert.False(t, settings.DisablePluginShortNameRepository, "DisablePluginShortNameRepository field has wrong value")
	})
}

func TestConfigMethods(t *testing.T) {
	// Set the asdf config file location to the test file
	t.Setenv("ASDF_CONFIG_FILE", "testdata/asdfrc")

	config, err := LoadConfig()
	assert.Nil(t, err, "Returned error when building config")

	t.Run("Returns LegacyVersionFile from asdfrc file", func(t *testing.T) {
		legacyFile, err := config.LegacyVersionFile()
		assert.Nil(t, err, "Returned error when loading settings")
		assert.True(t, legacyFile, "Expected LegacyVersionFile to be set")
	})

	t.Run("Returns AlwaysKeepDownload from asdfrc file", func(t *testing.T) {
		alwaysKeepDownload, err := config.AlwaysKeepDownload()
		assert.Nil(t, err, "Returned error when loading settings")
		assert.True(t, alwaysKeepDownload, "Expected AlwaysKeepDownload to be set")
	})

	t.Run("Returns PluginRepositoryLastCheckDuration from asdfrc file", func(t *testing.T) {
		checkDuration, err := config.PluginRepositoryLastCheckDuration()
		assert.Nil(t, err, "Returned error when loading settings")
		assert.True(t, checkDuration.Never, "Expected PluginRepositoryLastCheckDuration to be set")
		assert.Zero(t, checkDuration.Every, "Expected PluginRepositoryLastCheckDuration to be set")
	})

	t.Run("Returns DisablePluginShortNameRepository from asdfrc file", func(t *testing.T) {
		DisablePluginShortNameRepository, err := config.DisablePluginShortNameRepository()
		assert.Nil(t, err, "Returned error when loading settings")
		assert.True(t, DisablePluginShortNameRepository, "Expected DisablePluginShortNameRepository to be set")
	})

	t.Run("When file does not exist returns settings struct with defaults", func(t *testing.T) {
		config := Config{ConfigFile: "non-existant"}

		legacy, err := config.LegacyVersionFile()
		assert.Nil(t, err)
		assert.False(t, legacy)

		keepDownload, err := config.AlwaysKeepDownload()
		assert.Nil(t, err)
		assert.False(t, keepDownload)

		lastCheck, err := config.PluginRepositoryLastCheckDuration()
		assert.Nil(t, err)
		assert.False(t, lastCheck.Never)

		checkDuration, err := config.PluginRepositoryLastCheckDuration()
		assert.Nil(t, err)
		assert.Equal(t, checkDuration.Every, 60)

		shortName, err := config.DisablePluginShortNameRepository()
		assert.Nil(t, err)
		assert.False(t, shortName)
	})
}

func TestConfigGetHook(t *testing.T) {
	// Set the asdf config file location to the test file
	t.Setenv("ASDF_CONFIG_FILE", "testdata/asdfrc")

	config, err := LoadConfig()
	assert.Nil(t, err, "Returned error when building config")

	t.Run("Returns empty string when hook not present in asdfrc file", func(t *testing.T) {
		hookCmd, err := config.GetHook("post_asdf_plugin_add")
		assert.Nil(t, err)
		assert.Zero(t, hookCmd)
	})

	t.Run("Returns string containing Bash expression when present in asdfrc file", func(t *testing.T) {
		hookCmd, err := config.GetHook("pre_asdf_plugin_add")
		assert.Nil(t, err)
		assert.Equal(t, hookCmd, "echo Executing with args: $@")
	})

	t.Run("Ignores trailing and leading spaces", func(t *testing.T) {
		hookCmd, err := config.GetHook("pre_asdf_plugin_add_test")
		assert.Nil(t, err)
		assert.Equal(t, hookCmd, "echo Executing with args: $@")
	})

	t.Run("Preserves quoting", func(t *testing.T) {
		hookCmd, err := config.GetHook("pre_asdf_plugin_add_test2")
		assert.Nil(t, err)
		assert.Equal(t, hookCmd, "echo 'Executing' \"with args: $@\"")
	})

	t.Run("works if no config file", func(t *testing.T) {
		config := Config{}

		hookCmd, err := config.GetHook("some_hook")
		assert.Nil(t, err)
		assert.Empty(t, hookCmd)
	})
}

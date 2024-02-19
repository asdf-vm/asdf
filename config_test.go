package main

import (
	"testing"
)

func TestLoadConfig(t *testing.T) {
	config, err := LoadConfig()

	assert(t, err == nil, "Returned error when building config")

	assert(t, config.Home != "", "Expected Home to be set")
}

func TestLoadConfigEnv(t *testing.T) {
	config, err := loadConfigEnv()

	assert(t, err == nil, "Returned error when loading env for config")

	assert(t, config.Home == "", "Shouldn't set Home property when loading config")
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

		refuteError(t, err)

		assert(t, settings.Loaded, "Expected Loaded field to be set to true")
		assert(t, settings.LegacyVersionFile == true, "LegacyVersionFile field has wrong value")
		assert(t, settings.AlwaysKeepDownload == true, "AlwaysKeepDownload field has wrong value")
		assert(t, settings.PluginRepositoryLastCheckDuration.Never, "PluginRepositoryLastCheckDuration field has wrong value")
		assert(t, settings.PluginRepositoryLastCheckDuration.Every == 0, "PluginRepositoryLastCheckDuration field has wrong value")
		assert(t, settings.DisablePluginShortNameRepository == true, "DisablePluginShortNameRepository field has wrong value")
	})

	t.Run("When given path to empty file returns settings struct with defaults", func(t *testing.T) {
		settings, err := loadSettings("testdata/empty-asdfrc")

		refuteError(t, err)

		assert(t, settings.LegacyVersionFile == false, "LegacyVersionFile field has wrong value")
		assert(t, settings.AlwaysKeepDownload == false, "AlwaysKeepDownload field has wrong value")
		assert(t, settings.PluginRepositoryLastCheckDuration.Never == false, "PluginRepositoryLastCheckDuration field has wrong value")
		assert(t, settings.PluginRepositoryLastCheckDuration.Every == 60, "PluginRepositoryLastCheckDuration field has wrong value")
		assert(t, settings.DisablePluginShortNameRepository == false, "DisablePluginShortNameRepository field has wrong value")
	})
}

func TestConfigMethods(t *testing.T) {
	// Set the asdf config file location to the test file
	t.Setenv("ASDF_CONFIG_FILE", "testdata/asdfrc")

	config, err := LoadConfig()
	assert(t, err == nil, "Returned error when building config")

	t.Run("Returns LegacyVersionFile from asdfrc file", func(t *testing.T) {
		legacyFile, err := config.LegacyVersionFile()
		assert(t, err == nil, "Returned error when loading settings")
		assert(t, legacyFile == true, "Expected LegacyVersionFile to be set")
	})

	t.Run("Returns AlwaysKeepDownload from asdfrc file", func(t *testing.T) {
		alwaysKeepDownload, err := config.AlwaysKeepDownload()
		assert(t, err == nil, "Returned error when loading settings")
		assert(t, alwaysKeepDownload == true, "Expected AlwaysKeepDownload to be set")
	})

	t.Run("Returns PluginRepositoryLastCheckDuration from asdfrc file", func(t *testing.T) {
		checkDuration, err := config.PluginRepositoryLastCheckDuration()
		assert(t, err == nil, "Returned error when loading settings")
		assert(t, checkDuration.Never == true, "Expected PluginRepositoryLastCheckDuration to be set")
		assert(t, checkDuration.Every == 0, "Expected PluginRepositoryLastCheckDuration to be set")
	})

	t.Run("Returns DisablePluginShortNameRepository from asdfrc file", func(t *testing.T) {
		DisablePluginShortNameRepository, err := config.DisablePluginShortNameRepository()
		assert(t, err == nil, "Returned error when loading settings")
		assert(t, DisablePluginShortNameRepository == true, "Expected DisablePluginShortNameRepository to be set")
	})
}

func assert(t *testing.T, expr bool, message string) {
	t.Helper()

	if !expr {
		t.Error(message)
	}
}

func refuteError(t *testing.T, err error) {
	if err != nil {
		t.Fatal("Returned unexpected error", err)
	}
}

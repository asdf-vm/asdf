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
		_, err := LoadSettings("./foobar")

		if err == nil {
			t.Fatal("Didn't get an error")
		}
	})

	t.Run("When given path to populated asdfrc returns populated settings struct", func(t *testing.T) {
		settings, err := LoadSettings("testdata/asdfrc")

		refuteError(t, err)

		assert(t, settings.LegacyVersionFile == true, "LegacyVersionFile field has wrong value")
		assert(t, settings.AlwaysKeepDownload == true, "AlwaysKeepDownload field has wrong value")
		assert(t, settings.PluginRepositoryLastCheckDuration == "never", "PluginRepositoryLastCheckDuration field has wrong value")
		assert(t, settings.DisablePluginShortNameRepository == true, "DisablePluginShortNameRepository field has wrong value")
	})

	t.Run("When given path to empty file returns settings struct with defaults", func(t *testing.T) {
		settings, err := LoadSettings("testdata/empty-asdfrc")

		refuteError(t, err)

		assert(t, settings.LegacyVersionFile == false, "LegacyVersionFile field has wrong value")
		assert(t, settings.AlwaysKeepDownload == false, "AlwaysKeepDownload field has wrong value")
		assert(t, settings.PluginRepositoryLastCheckDuration == "60", "PluginRepositoryLastCheckDuration field has wrong value")
		assert(t, settings.DisablePluginShortNameRepository == false, "DisablePluginShortNameRepository field has wrong value")
	})
}

func assert(t *testing.T, expr bool, message string) {
	if !expr {
		t.Error(message)
	}
}

func refuteError(t *testing.T, err error) {
	if err != nil {
		t.Fatal("Returned unexpected error", err)
	}
}

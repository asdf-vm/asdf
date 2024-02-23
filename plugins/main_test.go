package plugins

import (
	"asdf/config"
	"os"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

// TODO: Switch to local repo so tests don't go over the network
const (
	testRepo       = "https://github.com/Stratus3D/asdf-lua"
	testPluginName = "lua"
)

func TestPluginAdd(t *testing.T) {
	testDataDir := t.TempDir()

	t.Run("when given an invalid plugin name prints an error", func(t *testing.T) {
		var invalids = []string{"plugin^name", "plugin%name", "plugin name", "PLUGIN_NAME"}

		for _, invalid := range invalids {
			t.Run(invalid, func(t *testing.T) {
				err := PluginAdd(config.Config{}, invalid, testRepo)

				expectedErrMsg := "is invalid. Name may only contain lowercase letters, numbers, '_', and '-'"
				if !strings.Contains(err.Error(), expectedErrMsg) {
					t.Errorf("Expected an error with message %v", expectedErrMsg)
				}
			})
		}
	})

	t.Run("when plugin with same name already exists prints an error", func(t *testing.T) {
		conf := config.Config{DataDir: testDataDir}

		// Add plugin
		err := PluginAdd(conf, testPluginName, testRepo)

		if err != nil {
			t.Fatal("Expected to be able to add plugin")
		}

		// Add it again to trigger error
		err = PluginAdd(conf, testPluginName, testRepo)

		if err == nil {
			t.Fatal("expected error got nil")
		}

		expectedErrMsg := "plugin named \"lua\" already added"
		if !strings.Contains(err.Error(), expectedErrMsg) {
			t.Errorf("Expected an error with message %v", expectedErrMsg)
		}
	})

	t.Run("when plugin name is valid but URL is invalid prints an error", func(t *testing.T) {
		conf := config.Config{DataDir: testDataDir}

		err := PluginAdd(conf, "foo", "foobar")

		assert.ErrorContains(t, err, "unable to clone plugin: repository not found")
	})

	t.Run("when plugin name and URL are valid installs plugin", func(t *testing.T) {
		testDataDir := t.TempDir()
		conf := config.Config{DataDir: testDataDir}

		err := PluginAdd(conf, testPluginName, testRepo)

		assert.Nil(t, err, "Expected to be able to add plugin")

		// Assert plugin directory contains Git repo with bin directory
		pluginDir := PluginDirectory(testDataDir, testPluginName)

		_, err = os.ReadDir(pluginDir + "/.git")
		assert.Nil(t, err)

		entries, err := os.ReadDir(pluginDir + "/bin")
		assert.Nil(t, err)
		assert.Equal(t, 5, len(entries))
	})
}

func TestPluginExists(t *testing.T) {
	testDataDir := t.TempDir()
	pluginDir := PluginDirectory(testDataDir, testPluginName)
	err := os.MkdirAll(pluginDir, 0777)
	if err != nil {
		t.Errorf("got %v, expected nil", err)
	}

	t.Run("returns true when plugin exists", func(t *testing.T) {
		exists, err := PluginExists(testDataDir, testPluginName)

		if err != nil {
			t.Errorf("got %v, expected nil", err)
		}

		if exists != true {
			t.Error("got false, expected true")
		}
	})

	t.Run("returns false when plugin path is file and not dir", func(t *testing.T) {
		pluginName := "file"
		pluginDir := PluginDirectory(testDataDir, pluginName)
		err := touchFile(pluginDir)
		if err != nil {
			t.Errorf("got %v, expected nil", err)
		}

		exists, err := PluginExists(testDataDir, pluginName)

		if err != nil {
			t.Errorf("got %v, expected nil", err)
		}

		if exists != false {
			t.Error("got false, expected true")
		}
	})

	t.Run("returns false when plugin dir does not exist", func(t *testing.T) {
		exists, err := PluginExists(testDataDir, "non-existant")

		if err != nil {
			t.Errorf("got %v, expected nil", err)
		}

		if exists != false {
			t.Error("got false, expected true")
		}
	})
}

func TestPluginDirectory(t *testing.T) {
	t.Run("returns new path with plugin name as last segment", func(t *testing.T) {
		pluginDir := PluginDirectory("~/.asdf/", testPluginName)
		expected := "~/.asdf/plugins/lua"
		if pluginDir != expected {
			t.Errorf("got %v, expected %v", pluginDir, expected)
		}
	})
}

func TestValidatePluginName(t *testing.T) {
	t.Run("returns no error when plugin name is valid", func(t *testing.T) {
		err := validatePluginName(testPluginName)
		refuteError(t, err)
	})

	var invalids = []string{"plugin^name", "plugin%name", "plugin name", "PLUGIN_NAME"}

	for _, invalid := range invalids {
		t.Run(invalid, func(t *testing.T) {
			err := validatePluginName(invalid)

			if err == nil {
				t.Error("Expected an error")
			}
		})
	}
}

func refuteError(t *testing.T, err error) {
	if err != nil {
		t.Fatal("Returned unexpected error", err)
	}
}

func touchFile(name string) error {
	file, err := os.OpenFile(name, os.O_RDONLY|os.O_CREATE, 0644)
	if err != nil {
		return err
	}
	return file.Close()
}

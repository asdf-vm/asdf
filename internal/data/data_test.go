package data

import (
	"path/filepath"
	"testing"
)

const testPluginName = "lua"

func TestPluginDirectory(t *testing.T) {
	t.Run("returns new path with plugin name as last segment", func(t *testing.T) {
		pluginDir := PluginDirectory("~/.asdf/", testPluginName)
		expected := filepath.Join("~/.asdf", "plugins", "lua")
		if pluginDir != expected {
			t.Errorf("got %v, expected %v", pluginDir, expected)
		}
	})
}

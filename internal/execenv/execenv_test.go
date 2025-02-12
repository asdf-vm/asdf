package execenv

import (
	"testing"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/repotest"
	"github.com/stretchr/testify/assert"
)

const (
	testPluginName  = "lua"
	testPluginName2 = "ruby"
)

func TestGenerate(t *testing.T) {
	t.Run("returns map of environment variables", func(t *testing.T) {
		testDataDir := t.TempDir()
		conf := config.Config{DataDir: testDataDir}
		_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
		assert.Nil(t, err)
		plugin := plugins.New(conf, testPluginName)
		assert.Nil(t, repotest.WritePluginCallback(plugin.Dir, "exec-env", "#!/usr/bin/env bash\nexport BAZ=bar"))
		env, err := Generate(plugin, map[string]string{"ASDF_INSTALL_VERSION": "test"})
		assert.Nil(t, err)
		assert.Equal(t, "bar", env["BAZ"])
		assert.Equal(t, "test", env["ASDF_INSTALL_VERSION"])
	})

	t.Run("returns error when plugin lacks exec-env callback", func(t *testing.T) {
		testDataDir := t.TempDir()
		conf := config.Config{DataDir: testDataDir}
		_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName2)
		assert.Nil(t, err)
		plugin := plugins.New(conf, testPluginName2)
		env, err := Generate(plugin, map[string]string{})
		assert.Equal(t, err.(plugins.NoCallbackError).Error(), "Plugin named ruby does not have a callback named exec-env")
		_, found := env["FOO"]
		assert.False(t, found)
	})

	t.Run("preserves environment variables that contain equals sign in value", func(t *testing.T) {
		testDataDir := t.TempDir()
		conf := config.Config{DataDir: testDataDir}
		_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
		assert.Nil(t, err)
		plugin := plugins.New(conf, testPluginName)
		assert.Nil(t, repotest.WritePluginCallback(plugin.Dir, "exec-env", "#!/usr/bin/env bash\nexport BAZ=bar"))
		env, err := Generate(plugin, map[string]string{"EQUALSTEST": "abc=123"})
		assert.Nil(t, err)
		assert.Equal(t, "bar", env["BAZ"])
		assert.Equal(t, "abc=123", env["EQUALSTEST"])
	})

	t.Run("preserves environment variables that contain equals sign in value", func(t *testing.T) {
		testDataDir := t.TempDir()
		conf := config.Config{DataDir: testDataDir}
		_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
		assert.Nil(t, err)
		plugin := plugins.New(conf, testPluginName)
		assert.Nil(t, repotest.WritePluginCallback(plugin.Dir, "exec-env", "#!/usr/bin/env bash\nexport BAZ=bar"))
		env, err := Generate(plugin, map[string]string{"EQUALSTEST": "abc\n123"})
		assert.Nil(t, err)
		assert.Equal(t, "bar", env["BAZ"])
		assert.Equal(t, "abc\n123", env["EQUALSTEST"])
	})

	t.Run("preserves environment variables that contain equals sign and line breaks in value", func(t *testing.T) {
		value := "-----BEGIN CERTIFICATE-----\nMANY\\LINES\\THE\nLAST\\ONE\\ENDS\\IN\nAN=\n-----END CERTIFICATE-----"
		testDataDir := t.TempDir()
		conf := config.Config{DataDir: testDataDir}
		_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
		assert.Nil(t, err)
		plugin := plugins.New(conf, testPluginName)
		assert.Nil(t, repotest.WritePluginCallback(plugin.Dir, "exec-env", "#!/usr/bin/env bash\nexport BAZ=\""+value+"\""))
		env, err := Generate(plugin, map[string]string{})
		assert.Nil(t, err)
		assert.Equal(t, value, env["BAZ"])
	})
}

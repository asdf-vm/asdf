package execenv

import (
	"testing"

	"asdf/internal/config"
	"asdf/internal/plugins"
	"asdf/repotest"

	"github.com/stretchr/testify/assert"
)

const (
	testPluginName  = "lua"
	testPluginName2 = "ruby"
)

func TestGenerate(t *testing.T) {
	testDataDir := t.TempDir()

	t.Run("returns map of environment variables", func(t *testing.T) {
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
		conf := config.Config{DataDir: testDataDir}
		_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName2)
		assert.Nil(t, err)
		plugin := plugins.New(conf, testPluginName2)
		env, err := Generate(plugin, map[string]string{})
		assert.Equal(t, err.(plugins.NoCallbackError).Error(), "Plugin named ruby does not have a callback named exec-env")
		_, found := env["FOO"]
		assert.False(t, found)
	})
}

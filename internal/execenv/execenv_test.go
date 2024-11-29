package execenv

import (
	"testing"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/repotest"
	"github.com/stretchr/testify/assert"
)

const (
	testPluginName  = "lua"
	testPluginName2 = "ruby"
)

func TestCurrentEnv(t *testing.T) {
	t.Run("returns map of current environment", func(t *testing.T) {
		envMap := CurrentEnv()
		path, found := envMap["PATH"]
		assert.True(t, found)
		assert.NotEmpty(t, path)
	})
}

func TestMergeEnv(t *testing.T) {
	t.Run("merges two maps", func(t *testing.T) {
		map1 := map[string]string{"Key": "value"}
		map2 := map[string]string{"Key2": "value2"}
		map3 := MergeEnv(map1, map2)
		assert.Equal(t, map3["Key"], "value")
		assert.Equal(t, map3["Key2"], "value2")
	})

	t.Run("doesn't change original map", func(t *testing.T) {
		map1 := map[string]string{"Key": "value"}
		map2 := map[string]string{"Key2": "value2"}
		_ = MergeEnv(map1, map2)
		assert.Equal(t, map1["Key2"], "value2")
	})

	t.Run("second map overwrites values in first", func(t *testing.T) {
		map1 := map[string]string{"Key": "value"}
		map2 := map[string]string{"Key": "value2"}
		map3 := MergeEnv(map1, map2)
		assert.Equal(t, map3["Key"], "value2")
	})
}

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

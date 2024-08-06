package resolve

import (
	"os"
	"path/filepath"
	"testing"

	"asdf/config"
	"asdf/plugins"
	"asdf/repotest"

	"github.com/stretchr/testify/assert"
)

func TestFindVersionsInDir(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir, DefaultToolVersionsFilename: ".tool-versions"}
	_, err := repotest.InstallPlugin("dummy_plugin", conf.DataDir, "lua")
	assert.Nil(t, err)
	plugin := plugins.New(conf, "lua")

	t.Run("when no versions set returns found false", func(t *testing.T) {
		currentDir := t.TempDir()

		versions, found, err := findVersionsInDir(conf, plugin, currentDir)

		assert.Empty(t, versions)
		assert.False(t, found)
		assert.Nil(t, err)
	})

	t.Run("when version is set returns found true and version", func(t *testing.T) {
		currentDir := t.TempDir()

		data := []byte("lua 1.2.3")
		err = os.WriteFile(filepath.Join(currentDir, ".tool-versions"), data, 0o666)

		versions, found, err := findVersionsInDir(conf, plugin, currentDir)

		assert.Equal(t, versions, []string{"1.2.3"})
		assert.True(t, found)
		assert.Nil(t, err)
	})

	t.Run("when multiple versions present in .tool-versions returns found true and versions", func(t *testing.T) {
		currentDir := t.TempDir()

		data := []byte("lua 1.2.3 2.3.4")
		err = os.WriteFile(filepath.Join(currentDir, ".tool-versions"), data, 0o666)

		versions, found, err := findVersionsInDir(conf, plugin, currentDir)

		assert.Equal(t, versions, []string{"1.2.3", "2.3.4"})
		assert.True(t, found)
		assert.Nil(t, err)
	})

	t.Run("when DefaultToolVersionsFilename is set reads from file with that name if exists", func(t *testing.T) {
		conf := config.Config{DataDir: testDataDir, DefaultToolVersionsFilename: "custom-file"}
		currentDir := t.TempDir()

		data := []byte("lua 1.2.3 2.3.4")
		err = os.WriteFile(filepath.Join(currentDir, "custom-file"), data, 0o666)

		versions, found, err := findVersionsInDir(conf, plugin, currentDir)

		assert.Equal(t, versions, []string{"1.2.3", "2.3.4"})
		assert.True(t, found)
		assert.Nil(t, err)
	})
}

func TestFindVersionsLegacyFiles(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}
	_, err := repotest.InstallPlugin("dummy_plugin", conf.DataDir, "lua")
	assert.Nil(t, err)
	plugin := plugins.New(conf, "lua")

	t.Run("when given tool that lacks list-legacy-filenames callback returns empty versions list", func(t *testing.T) {
		pluginName := "foobar"
		_, err := repotest.InstallPlugin("dummy_plugin_no_download", conf.DataDir, pluginName)
		assert.Nil(t, err)
		plugin := plugins.New(conf, pluginName)
		versions, found, err := findVersionsInLegacyFile(plugin, t.TempDir())
		assert.Empty(t, versions)
		assert.False(t, found)
		assert.Nil(t, err)
	})

	t.Run("when given tool that has a list-legacy-filenames callback but file not found returns empty versions list", func(t *testing.T) {
		versions, found, err := findVersionsInLegacyFile(plugin, t.TempDir())
		assert.Empty(t, versions)
		assert.False(t, found)
		assert.Nil(t, err)
	})

	t.Run("when given tool that has a list-legacy-filenames callback and file found returns populated versions list", func(t *testing.T) {
		// write legacy version file
		currentDir := t.TempDir()
		data := []byte("1.2.3")
		err = os.WriteFile(filepath.Join(currentDir, ".dummy-version"), data, 0o666)
		assert.Nil(t, err)

		versions, found, err := findVersionsInLegacyFile(plugin, currentDir)
		assert.Equal(t, versions, []string{"1.2.3"})
		assert.True(t, found)
		assert.Nil(t, err)
	})
}

func TestFindVersionsInEnv(t *testing.T) {
	t.Run("when env variable isn't set returns empty list of versions", func(t *testing.T) {
		versions, found := findVersionsInEnv("non-existent")
		assert.False(t, found)
		assert.Empty(t, versions)
	})

	t.Run("when env variable is set returns version", func(t *testing.T) {
		os.Setenv("ASDF_LUA_VERSION", "5.4.5")
		versions, found := findVersionsInEnv("lua")
		assert.True(t, found)
		assert.Equal(t, versions, []string{"5.4.5"})
		os.Unsetenv("ASDF_LUA_VERSION")
	})

	t.Run("when env variable is set to multiple versions", func(t *testing.T) {
		os.Setenv("ASDF_LUA_VERSION", "5.4.5 5.4.6")
		versions, found := findVersionsInEnv("lua")
		assert.True(t, found)
		assert.Equal(t, versions, []string{"5.4.5", "5.4.6"})
		os.Unsetenv("ASDF_LUA_VERSION")
	})
}

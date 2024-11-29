package resolve

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/repotest"
	"github.com/stretchr/testify/assert"
)

func TestVersion(t *testing.T) {
	testDataDir := t.TempDir()
	currentDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir, DefaultToolVersionsFilename: ".tool-versions", ConfigFile: "testdata/asdfrc"}
	_, err := repotest.InstallPlugin("dummy_plugin", conf.DataDir, "lua")
	assert.Nil(t, err)
	plugin := plugins.New(conf, "lua")

	t.Run("returns empty slice when non-existent version passed", func(t *testing.T) {
		toolVersion, found, err := Version(conf, plugin, t.TempDir())
		assert.Nil(t, err)
		assert.False(t, found)
		assert.Empty(t, toolVersion.Versions)
	})

	t.Run("returns single version from .tool-versions file", func(t *testing.T) {
		// write a version file
		data := []byte("lua 1.2.3")
		err = os.WriteFile(filepath.Join(currentDir, ".tool-versions"), data, 0o666)

		toolVersion, found, err := Version(conf, plugin, currentDir)
		assert.Nil(t, err)
		assert.True(t, found)
		assert.Equal(t, toolVersion.Versions, []string{"1.2.3"})
	})

	t.Run("returns version from env when env variable set", func(t *testing.T) {
		// Set env
		t.Setenv("ASDF_LUA_VERSION", "2.3.4")

		// write a version file
		data := []byte("lua 1.2.3")
		err = os.WriteFile(filepath.Join(currentDir, ".tool-versions"), data, 0o666)

		// assert env variable takes precedence
		toolVersion, found, err := Version(conf, plugin, currentDir)
		assert.Nil(t, err)
		assert.True(t, found)
		assert.Equal(t, toolVersion.Versions, []string{"2.3.4"})
	})

	t.Run("returns single version from .tool-versions file in parent directory", func(t *testing.T) {
		// write a version file
		data := []byte("lua 1.2.3")
		err = os.WriteFile(filepath.Join(currentDir, ".tool-versions"), data, 0o666)

		subDir := filepath.Join(currentDir, "subdir")
		err = os.MkdirAll(subDir, 0o777)
		assert.Nil(t, err)

		toolVersion, found, err := Version(conf, plugin, subDir)
		assert.Nil(t, err)
		assert.True(t, found)
		assert.Equal(t, toolVersion.Versions, []string{"1.2.3"})
	})
}

func TestFindVersionsInDir(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir, DefaultToolVersionsFilename: ".tool-versions", ConfigFile: "testdata/asdfrc"}
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

		toolVersion, found, err := findVersionsInDir(conf, plugin, currentDir)

		assert.Equal(t, toolVersion.Versions, []string{"1.2.3"})
		assert.True(t, found)
		assert.Nil(t, err)
	})

	t.Run("when multiple versions present in .tool-versions returns found true and versions", func(t *testing.T) {
		currentDir := t.TempDir()

		data := []byte("lua 1.2.3 2.3.4")
		err = os.WriteFile(filepath.Join(currentDir, ".tool-versions"), data, 0o666)

		toolVersion, found, err := findVersionsInDir(conf, plugin, currentDir)

		assert.Equal(t, toolVersion.Versions, []string{"1.2.3", "2.3.4"})
		assert.True(t, found)
		assert.Nil(t, err)
	})

	t.Run("when DefaultToolVersionsFilename is set reads from file with that name if exists", func(t *testing.T) {
		conf := config.Config{DataDir: testDataDir, DefaultToolVersionsFilename: "custom-file"}
		currentDir := t.TempDir()

		data := []byte("lua 1.2.3 2.3.4")
		err = os.WriteFile(filepath.Join(currentDir, "custom-file"), data, 0o666)

		toolVersion, found, err := findVersionsInDir(conf, plugin, currentDir)

		assert.Equal(t, toolVersion.Versions, []string{"1.2.3", "2.3.4"})
		assert.True(t, found)
		assert.Nil(t, err)
	})

	t.Run("when legacy file support is on looks up version in legacy file", func(t *testing.T) {
		currentDir := t.TempDir()

		data := []byte("1.2.3 2.3.4")
		err = os.WriteFile(filepath.Join(currentDir, ".dummy-version"), data, 0o666)

		toolVersion, found, err := findVersionsInDir(conf, plugin, currentDir)

		assert.Equal(t, toolVersion.Versions, []string{"1.2.3", "2.3.4"})
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
		toolVersion, found, err := findVersionsInLegacyFile(plugin, t.TempDir())
		assert.Empty(t, toolVersion.Versions)
		assert.False(t, found)
		assert.Nil(t, err)
	})

	t.Run("when given tool that has a list-legacy-filenames callback but file not found returns empty versions list", func(t *testing.T) {
		toolVersion, found, err := findVersionsInLegacyFile(plugin, t.TempDir())
		assert.Empty(t, toolVersion.Versions)
		assert.False(t, found)
		assert.Nil(t, err)
	})

	t.Run("when given tool that has a list-legacy-filenames callback and file found returns populated versions list", func(t *testing.T) {
		// write legacy version file
		currentDir := t.TempDir()
		data := []byte("1.2.3")
		err = os.WriteFile(filepath.Join(currentDir, ".dummy-version"), data, 0o666)
		assert.Nil(t, err)

		toolVersion, found, err := findVersionsInLegacyFile(plugin, currentDir)
		assert.Equal(t, toolVersion.Versions, []string{"1.2.3"})
		assert.True(t, found)
		assert.Nil(t, err)
	})
}

func TestFindVersionsInEnv(t *testing.T) {
	t.Run("when env variable isn't set returns empty list of versions", func(t *testing.T) {
		versions, envVariableName, found := findVersionsInEnv("non-existent")
		assert.False(t, found)
		assert.Empty(t, versions)
		assert.Equal(t, envVariableName, "ASDF_NON-EXISTENT_VERSION")
	})

	t.Run("when env variable is set returns version", func(t *testing.T) {
		os.Setenv("ASDF_LUA_VERSION", "5.4.5")
		versions, envVariableName, found := findVersionsInEnv("lua")
		assert.True(t, found)
		assert.Equal(t, versions, []string{"5.4.5"})
		assert.Equal(t, envVariableName, "ASDF_LUA_VERSION")

		os.Unsetenv("ASDF_LUA_VERSION")
	})

	t.Run("when env variable is set to multiple versions", func(t *testing.T) {
		os.Setenv("ASDF_LUA_VERSION", "5.4.5 5.4.6")
		versions, envVariableName, found := findVersionsInEnv("lua")
		assert.True(t, found)
		assert.Equal(t, versions, []string{"5.4.5", "5.4.6"})
		assert.Equal(t, envVariableName, "ASDF_LUA_VERSION")
		os.Unsetenv("ASDF_LUA_VERSION")
	})
}

func TestVariableVersionName(t *testing.T) {
	tests := []struct {
		input  string
		output string
	}{
		{
			input:  "ruby",
			output: "ASDF_RUBY_VERSION",
		},
		{
			input:  "lua",
			output: "ASDF_LUA_VERSION",
		},
		{
			input:  "foo-bar",
			output: "ASDF_FOO-BAR_VERSION",
		},
	}

	for _, tt := range tests {
		t.Run(fmt.Sprintf("input: %s, output: %s", tt.input, tt.output), func(t *testing.T) {
			assert.Equal(t, tt.output, variableVersionName(tt.input))
		})
	}
}

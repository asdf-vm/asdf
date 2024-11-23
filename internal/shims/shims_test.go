package shims

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"asdf/internal/config"
	"asdf/internal/installs"
	"asdf/internal/installtest"
	"asdf/internal/plugins"
	"asdf/internal/toolversions"
	"asdf/repotest"

	"github.com/stretchr/testify/assert"
	"golang.org/x/sys/unix"
)

const testPluginName = "lua"

func TestFindExecutable(t *testing.T) {
	version := "1.1.0"
	conf, plugin := generateConfig(t)
	installVersion(t, conf, plugin, version)
	stdout, stderr := buildOutputs()
	assert.Nil(t, GenerateAll(conf, &stdout, &stderr))
	currentDir := t.TempDir()

	t.Run("returns error when shim with name does not exist", func(t *testing.T) {
		executable, found, err := FindExecutable(conf, "foo", currentDir)
		assert.Empty(t, executable)
		assert.False(t, found)
		assert.Equal(t, err.(UnknownCommandError).Error(), "unknown command: foo")
	})

	t.Run("returns error when shim is present but no version is set", func(t *testing.T) {
		executable, found, err := FindExecutable(conf, "dummy", currentDir)
		assert.Empty(t, executable)
		assert.False(t, found)
		assert.Equal(t, err.(NoVersionSetError).Error(), "no versions set for dummy")
	})

	t.Run("returns string containing path to executable when found", func(t *testing.T) {
		// write a version file
		data := []byte("lua 1.1.0")
		assert.Nil(t, os.WriteFile(filepath.Join(currentDir, ".tool-versions"), data, 0o666))

		executable, found, err := FindExecutable(conf, "dummy", currentDir)
		assert.Equal(t, filepath.Base(filepath.Dir(filepath.Dir(executable))), "1.1.0")
		assert.Equal(t, filepath.Base(executable), "dummy")
		assert.True(t, found)
		assert.Nil(t, err)
	})

	t.Run("returns string containing path to system executable when system version set", func(t *testing.T) {
		// Create dummy `ls` executable
		versionStruct := toolversions.Version{Type: "version", Value: version}
		path := filepath.Join(installs.InstallPath(conf, plugin, versionStruct), "bin", "ls")
		assert.Nil(t, os.WriteFile(path, []byte("echo 'I'm ls'"), 0o777))

		// write system version to version file
		toolpath := filepath.Join(currentDir, ".tool-versions")
		assert.Nil(t, os.WriteFile(toolpath, []byte("lua system\n"), 0o666))
		assert.Nil(t, GenerateAll(conf, &stdout, &stderr))

		executable, found, err := FindExecutable(conf, "ls", currentDir)
		assert.True(t, found)
		assert.Nil(t, err)

		// see that it actually returns path to system ls
		assert.Equal(t, filepath.Base(executable), "ls")
		assert.NotEqual(t, executable, path)
	})
}

func TestGetExecutablePath(t *testing.T) {
	version := toolversions.Version{Type: "version", Value: "1.1.0"}
	conf, plugin := generateConfig(t)
	installVersion(t, conf, plugin, version.Value)

	t.Run("returns path to executable", func(t *testing.T) {
		path, err := GetExecutablePath(conf, plugin, "dummy", version.Value)
		assert.Nil(t, err)
		assert.Equal(t, filepath.Base(path), "dummy")
		assert.Equal(t, filepath.Base(filepath.Dir(filepath.Dir(path))), version.Value)
	})

	t.Run("returns error when executable with name not found", func(t *testing.T) {
		path, err := GetExecutablePath(conf, plugin, "foo", version.Value)
		assert.ErrorContains(t, err, "executable not found")
		assert.Equal(t, path, "")
	})

	t.Run("returns custom path when plugin has exec-path callback", func(t *testing.T) {
		// Create exec-path callback
		installDummyExecPathScript(t, conf, plugin, version, "dummy")

		path, err := GetExecutablePath(conf, plugin, "dummy", version.Value)
		assert.Nil(t, err)
		assert.Equal(t, filepath.Base(filepath.Dir(path)), "custom")
	})
}

func TestRemoveAll(t *testing.T) {
	version := "1.1.0"
	conf, plugin := generateConfig(t)
	installVersion(t, conf, plugin, version)
	executables, err := ToolExecutables(conf, plugin, "version", version)
	assert.Nil(t, err)
	stdout, stderr := buildOutputs()

	t.Run("removes all files in shim directory", func(t *testing.T) {
		assert.Nil(t, GenerateAll(conf, &stdout, &stderr))
		assert.Nil(t, RemoveAll(conf))

		// check for generated shims
		for _, executable := range executables {
			_, err := os.Stat(Path(conf, filepath.Base(executable)))
			assert.True(t, errors.Is(err, os.ErrNotExist))
		}
	})
}

func TestGenerateAll(t *testing.T) {
	version := "1.1.0"
	version2 := "2.0.0"
	conf, plugin := generateConfig(t)
	installVersion(t, conf, plugin, version)
	installPlugin(t, conf, "dummy_plugin", "ruby")
	installVersion(t, conf, plugin, version2)
	executables, err := ToolExecutables(conf, plugin, "version", version)
	assert.Nil(t, err)
	stdout, stderr := buildOutputs()

	t.Run("generates shim script for every executable in every version of every tool", func(t *testing.T) {
		assert.Nil(t, GenerateAll(conf, &stdout, &stderr))

		// check for generated shims
		for _, executable := range executables {
			shimName := filepath.Base(executable)
			shimPath := Path(conf, shimName)
			assert.Nil(t, unix.Access(shimPath, unix.X_OK))

			// shim exists and has expected contents
			content, err := os.ReadFile(shimPath)
			assert.Nil(t, err)
			want := fmt.Sprintf("#!/usr/bin/env bash\n# asdf-plugin: lua 2.0.0\n# asdf-plugin: lua 1.1.0\nexec asdf exec \"%s\" \"$@\"", shimName)
			assert.Equal(t, want, string(content))
		}
	})
}

func TestGenerateForPluginVersions(t *testing.T) {
	t.Setenv("ASDF_CONFIG_FILE", "testdata/asdfrc")
	version := "1.1.0"
	version2 := "2.0.0"
	conf, plugin := generateConfig(t)
	installVersion(t, conf, plugin, version)
	installVersion(t, conf, plugin, version2)
	executables, err := ToolExecutables(conf, plugin, "version", version)
	assert.Nil(t, err)
	stdout, stderr := buildOutputs()

	t.Run("generates shim script for every executable in every version the tool", func(t *testing.T) {
		assert.Nil(t, GenerateForPluginVersions(conf, plugin, &stdout, &stderr))

		// check for generated shims
		for _, executable := range executables {
			shimName := filepath.Base(executable)
			shimPath := Path(conf, shimName)
			assert.Nil(t, unix.Access(shimPath, unix.X_OK))

			// shim exists and has expected contents
			content, err := os.ReadFile(shimPath)
			assert.Nil(t, err)

			want := fmt.Sprintf("#!/usr/bin/env bash\n# asdf-plugin: lua 2.0.0\n# asdf-plugin: lua 1.1.0\nexec asdf exec \"%s\" \"$@\"", shimName)
			assert.Equal(t, want, string(content))
		}
	})

	t.Run("runs pre and post reshim hooks", func(t *testing.T) {
		stdout, stderr := buildOutputs()
		assert.Nil(t, GenerateForPluginVersions(conf, plugin, &stdout, &stderr))

		want := "pre_reshim 1.1.0\npost_reshim 1.1.0\npre_reshim 2.0.0\npost_reshim 2.0.0\n"
		assert.Equal(t, want, stdout.String())
	})
}

func TestGenerateForVersion(t *testing.T) {
	version := "1.1.0"
	version2 := "2.0.0"
	conf, plugin := generateConfig(t)
	installVersion(t, conf, plugin, version)
	installVersion(t, conf, plugin, version2)
	executables, err := ToolExecutables(conf, plugin, "version", version)
	assert.Nil(t, err)

	t.Run("generates shim script for every executable in version", func(t *testing.T) {
		stdout, stderr := buildOutputs()
		assert.Nil(t, GenerateForVersion(conf, plugin, "version", version, &stdout, &stderr))

		// check for generated shims
		for _, executable := range executables {
			shimName := filepath.Base(executable)
			shimPath := Path(conf, shimName)
			assert.Nil(t, unix.Access(shimPath, unix.X_OK))
		}
	})

	t.Run("updates existing shims for every executable in version", func(t *testing.T) {
		stdout, stderr := buildOutputs()
		assert.Nil(t, GenerateForVersion(conf, plugin, "version", version, &stdout, &stderr))
		assert.Nil(t, GenerateForVersion(conf, plugin, "version", version2, &stdout, &stderr))

		// check for generated shims
		for _, executable := range executables {
			shimName := filepath.Base(executable)
			shimPath := Path(conf, shimName)
			assert.Nil(t, unix.Access(shimPath, unix.X_OK))
		}
	})
}

func TestWrite(t *testing.T) {
	version := "1.1.0"
	version2 := "2.0.0"
	conf, plugin := generateConfig(t)
	installVersion(t, conf, plugin, version)
	installVersion(t, conf, plugin, version2)
	executables, err := ToolExecutables(conf, plugin, "version", version)
	executable := executables[0]
	assert.Nil(t, err)

	t.Run("writes a new shim file when doesn't exist", func(t *testing.T) {
		executable := executables[0]
		err = Write(conf, plugin, version, executable)
		assert.Nil(t, err)

		// shim is executable
		shimName := filepath.Base(executable)
		shimPath := Path(conf, shimName)
		assert.Nil(t, unix.Access(shimPath, unix.X_OK))

		// shim exists and has expected contents
		content, err := os.ReadFile(shimPath)
		assert.Nil(t, err)
		want := "#!/usr/bin/env bash\n# asdf-plugin: lua 1.1.0\nexec asdf exec \"dummy\" \"$@\""
		assert.Equal(t, want, string(content))
		os.Remove(shimPath)
	})

	t.Run("updates an existing shim file when already present", func(t *testing.T) {
		// Write same shim for two versions
		assert.Nil(t, Write(conf, plugin, version, executable))
		assert.Nil(t, Write(conf, plugin, version2, executable))

		// shim is still executable
		shimName := filepath.Base(executable)
		shimPath := Path(conf, shimName)
		assert.Nil(t, unix.Access(shimPath, unix.X_OK))

		// has expected contents
		content, err := os.ReadFile(shimPath)
		assert.Nil(t, err)
		want := "#!/usr/bin/env bash\n# asdf-plugin: lua 2.0.0\n# asdf-plugin: lua 1.1.0\nexec asdf exec \"dummy\" \"$@\""
		assert.Equal(t, want, string(content))
		os.Remove(shimPath)
	})

	t.Run("doesn't add the same version to a shim file twice", func(t *testing.T) {
		assert.Nil(t, Write(conf, plugin, version, executable))
		assert.Nil(t, Write(conf, plugin, version, executable))

		// Shim doesn't contain any duplicate lines
		shimPath := Path(conf, filepath.Base(executable))
		content, err := os.ReadFile(shimPath)
		assert.Nil(t, err)
		want := "#!/usr/bin/env bash\n# asdf-plugin: lua 1.1.0\nexec asdf exec \"dummy\" \"$@\""
		assert.Equal(t, want, string(content))
		os.Remove(shimPath)
	})
}

func TestToolExecutables(t *testing.T) {
	version := toolversions.Version{Type: "version", Value: "1.1.0"}
	conf, plugin := generateConfig(t)
	installVersion(t, conf, plugin, version.Value)

	t.Run("returns list of executables for plugin", func(t *testing.T) {
		executables, err := ToolExecutables(conf, plugin, "version", version.Value)
		assert.Nil(t, err)

		var filenames []string
		for _, executablePath := range executables {
			assert.True(t, strings.HasPrefix(executablePath, conf.DataDir))
			filenames = append(filenames, filepath.Base(executablePath))
		}

		assert.Equal(t, filenames, []string{"dummy"})
	})

	t.Run("returns list of executables for version installed in arbitrary directory", func(t *testing.T) {
		// Reference regular install by path to validate this behavior
		path := installs.InstallPath(conf, plugin, version)
		executables, err := ToolExecutables(conf, plugin, "path", path)
		assert.Nil(t, err)

		var filenames []string
		for _, executablePath := range executables {
			assert.True(t, strings.HasPrefix(executablePath, conf.DataDir))
			filenames = append(filenames, filepath.Base(executablePath))
		}

		assert.Equal(t, filenames, []string{"dummy"})
	})
}

func TestExecutableDirs(t *testing.T) {
	conf, plugin := generateConfig(t)
	installVersion(t, conf, plugin, "1.2.3")

	t.Run("returns list only containing 'bin' when list-bin-paths callback missing", func(t *testing.T) {
		executables, err := ExecutableDirs(plugin)
		assert.Nil(t, err)
		assert.Equal(t, executables, []string{"bin"})
	})

	t.Run("returns list of executable paths for tool version", func(t *testing.T) {
		data := []byte("echo 'foo bar'")
		err := os.WriteFile(filepath.Join(plugin.Dir, "bin", "list-bin-paths"), data, 0o777)
		assert.Nil(t, err)

		executables, err := ExecutableDirs(plugin)
		assert.Nil(t, err)
		assert.Equal(t, executables, []string{"foo", "bar"})
	})
}

// Helper functions
func buildOutputs() (strings.Builder, strings.Builder) {
	var stdout strings.Builder
	var stderr strings.Builder

	return stdout, stderr
}

func generateConfig(t *testing.T) (config.Config, plugins.Plugin) {
	t.Helper()
	testDataDir := t.TempDir()
	conf, err := config.LoadConfig()
	assert.Nil(t, err)
	conf.DataDir = testDataDir

	return conf, installPlugin(t, conf, "dummy_plugin", testPluginName)
}

func installDummyExecPathScript(t *testing.T, conf config.Config, plugin plugins.Plugin, version toolversions.Version, name string) {
	t.Helper()
	execPath := filepath.Join(plugin.Dir, "bin", "exec-path")
	contents := fmt.Sprintf("#!/usr/bin/env bash\necho 'bin/custom/%s'", name)
	err := os.WriteFile(execPath, []byte(contents), 0o777)
	assert.Nil(t, err)

	installPath := installs.InstallPath(conf, plugin, version)
	err = os.MkdirAll(filepath.Join(installPath, "bin", "custom"), 0o777)
	assert.Nil(t, err)

	err = os.WriteFile(filepath.Join(installPath, "bin", "custom", name), []byte{}, 0o777)
	assert.Nil(t, err)
}

func installPlugin(t *testing.T, conf config.Config, fixture, pluginName string) plugins.Plugin {
	_, err := repotest.InstallPlugin(fixture, conf.DataDir, pluginName)
	assert.Nil(t, err)

	return plugins.New(conf, pluginName)
}

func installVersion(t *testing.T, conf config.Config, plugin plugins.Plugin, version string) {
	t.Helper()
	err := installtest.InstallOneVersion(conf, plugin, "version", version)
	assert.Nil(t, err)
}

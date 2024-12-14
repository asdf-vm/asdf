package plugins

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/data"
	"github.com/asdf-vm/asdf/repotest"
	"github.com/stretchr/testify/assert"
)

const testPluginName = "lua"

func TestList(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}
	testRepo, err := repotest.GeneratePlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)

	err = Add(conf, testPluginName, testRepo)
	assert.Nil(t, err)

	t.Run("when urls and refs are set to false returns plugin names", func(t *testing.T) {
		plugins, err := List(conf, false, false)
		assert.Nil(t, err)

		plugin := plugins[0]
		assert.Equal(t, "lua", plugin.Name)
		assert.NotZero(t, plugin.Dir)
		assert.Zero(t, plugin.URL)
		assert.Zero(t, plugin.Ref)
	})

	t.Run("when urls is set to true returns plugins with repo urls set", func(t *testing.T) {
		plugins, err := List(conf, true, false)
		assert.Nil(t, err)

		plugin := plugins[0]
		assert.Equal(t, "lua", plugin.Name)
		assert.NotZero(t, plugin.Dir)
		assert.Zero(t, plugin.Ref)
		assert.NotZero(t, plugin.URL)
	})

	t.Run("when refs is set to true returns plugins with current repo refs set", func(t *testing.T) {
		plugins, err := List(conf, false, true)
		assert.Nil(t, err)

		plugin := plugins[0]
		assert.Equal(t, "lua", plugin.Name)
		assert.NotZero(t, plugin.Dir)
		assert.NotZero(t, plugin.Ref)
		assert.Zero(t, plugin.URL)
	})

	t.Run("when refs and urls are both set to true returns plugins with both set", func(t *testing.T) {
		plugins, err := List(conf, true, true)
		assert.Nil(t, err)

		plugin := plugins[0]
		assert.Equal(t, "lua", plugin.Name)
		assert.NotZero(t, plugin.Dir)
		assert.NotZero(t, plugin.Ref)
		assert.NotZero(t, plugin.URL)
	})
}

func TestNew(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}

	t.Run("returns Plugin struct with Dir and Name fields set correctly", func(t *testing.T) {
		plugin := New(conf, "test-plugin")

		assert.Equal(t, "test-plugin", plugin.Name)
		assert.Equal(t, filepath.Join(testDataDir, "plugins", "test-plugin"), plugin.Dir)
	})
}

func TestAdd(t *testing.T) {
	testDataDir := t.TempDir()

	t.Run("when given an invalid plugin name prints an error", func(t *testing.T) {
		invalids := []string{"plugin^name", "plugin%name", "plugin name", "PLUGIN_NAME"}

		for _, invalid := range invalids {
			t.Run(invalid, func(t *testing.T) {
				err := Add(config.Config{}, invalid, "never-cloned")

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
		repoPath, err := repotest.GeneratePlugin("dummy_plugin", testDataDir, testPluginName)
		assert.Nil(t, err)

		err = Add(conf, testPluginName, repoPath)
		if err != nil {
			t.Fatal("Expected to be able to add plugin")
		}

		// Add it again to trigger error
		err = Add(conf, testPluginName, repoPath)

		if err == nil {
			t.Fatal("expected error got nil")
		}

		expectedErrMsg := "Plugin named lua already added"
		if !strings.Contains(err.Error(), expectedErrMsg) {
			t.Errorf("Expected an error with message %v", expectedErrMsg)
		}
	})

	t.Run("when plugin name is valid but URL is invalid prints an error", func(t *testing.T) {
		conf := config.Config{DataDir: testDataDir}

		err := Add(conf, "foo", "foobar")

		assert.ErrorContains(t, err, "unable to clone plugin: repository not found")
	})

	t.Run("when plugin name and URL are valid installs plugin", func(t *testing.T) {
		testDataDir := t.TempDir()
		conf := config.Config{DataDir: testDataDir}
		pluginPath, err := repotest.GeneratePlugin("dummy_plugin", testDataDir, testPluginName)
		assert.Nil(t, err)

		err = Add(conf, testPluginName, pluginPath)

		assert.Nil(t, err, "Expected to be able to add plugin")

		// Assert plugin directory contains Git repo with bin directory
		pluginDir := data.PluginDirectory(testDataDir, testPluginName)

		_, err = os.ReadDir(pluginDir + "/.git")
		assert.Nil(t, err)

		entries, err := os.ReadDir(pluginDir + "/bin")
		assert.Nil(t, err)
		assert.Equal(t, 12, len(entries))
	})

	t.Run("when parameters are valid creates plugin download dir", func(t *testing.T) {
		testDataDir := t.TempDir()
		conf := config.Config{DataDir: testDataDir}

		repoPath, err := repotest.GeneratePlugin("dummy_plugin", testDataDir, testPluginName)
		assert.Nil(t, err)

		err = Add(conf, testPluginName, repoPath)
		assert.Nil(t, err)

		// Assert download dir exists
		downloadDir := data.DownloadDirectory(testDataDir, testPluginName)
		_, err = os.Stat(downloadDir)
		assert.Nil(t, err)
	})
}

func TestRemove(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}

	repoPath, err := repotest.GeneratePlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)

	err = Add(conf, testPluginName, repoPath)
	assert.Nil(t, err)

	t.Run("returns error when plugin with name does not exist", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder
		err := Remove(conf, "nonexistent", &stdout, &stderr)
		assert.NotNil(t, err)
		assert.ErrorContains(t, err, "No such plugin")
	})

	t.Run("returns error when invalid plugin name is given", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder
		err := Remove(conf, "foo/bar/baz", &stdout, &stderr)
		assert.NotNil(t, err)
		expectedErrMsg := "is invalid. Name may only contain lowercase letters, numbers, '_', and '-'"
		assert.ErrorContains(t, err, expectedErrMsg)
	})

	t.Run("removes plugin when passed name of installed plugin", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder
		err := Remove(conf, testPluginName, &stdout, &stderr)
		assert.Nil(t, err)

		pluginDir := data.PluginDirectory(testDataDir, testPluginName)
		_, err = os.Stat(pluginDir)
		assert.NotNil(t, err)
		assert.True(t, os.IsNotExist(err))
	})

	t.Run("removes plugin download dir when passed name of installed plugin", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder
		err := Add(conf, testPluginName, repoPath)
		assert.Nil(t, err)

		err = Remove(conf, testPluginName, &stdout, &stderr)
		assert.Nil(t, err)

		downloadDir := data.DownloadDirectory(testDataDir, testPluginName)
		_, err = os.Stat(downloadDir)
		assert.NotNil(t, err)
		assert.True(t, os.IsNotExist(err))
	})
}

func TestUpdate(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}

	repoPath, err := repotest.GeneratePlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)

	err = Add(conf, testPluginName, repoPath)
	assert.Nil(t, err)

	badPluginName := "badplugin"
	badRepo := data.PluginDirectory(testDataDir, badPluginName)
	err = os.MkdirAll(badRepo, 0o777)
	assert.Nil(t, err)

	tests := []struct {
		desc        string
		givenConf   config.Config
		givenName   string
		givenRef    string
		wantSomeRef bool
		wantErrMsg  string
	}{
		{
			desc:        "returns error when plugin with name does not exist",
			givenConf:   conf,
			givenName:   "nonexistent",
			givenRef:    "",
			wantSomeRef: false,
			wantErrMsg:  "no such plugin: nonexistent",
		},
		{
			desc:        "returns error when plugin repo does not exist",
			givenConf:   conf,
			givenName:   "badplugin",
			givenRef:    "",
			wantSomeRef: false,
			wantErrMsg:  "unable to open plugin Git repository: repository does not exist",
		},
		{
			desc:        "updates plugin when plugin with name exists",
			givenConf:   conf,
			givenName:   testPluginName,
			givenRef:    "",
			wantSomeRef: true,
			wantErrMsg:  "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.desc, func(t *testing.T) {
			updatedToRef, err := Update(tt.givenConf, tt.givenName, tt.givenRef)

			if tt.wantErrMsg == "" {
				assert.Nil(t, err)
			} else {
				assert.NotNil(t, err)
				assert.ErrorContains(t, err, tt.wantErrMsg)
			}

			if tt.wantSomeRef == true {
				assert.NotZero(t, updatedToRef)
			} else {
				assert.Zero(t, updatedToRef)
			}
		})
	}
}

func TestExists(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}
	_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)

	existingPlugin := New(conf, testPluginName)

	t.Run("returns nil if plugin exists", func(t *testing.T) {
		err := existingPlugin.Exists()
		assert.Nil(t, err)
	})

	t.Run("returns PluginMissing error when plugin missing", func(t *testing.T) {
		missingPlugin := New(conf, "non-existent")
		err := missingPlugin.Exists()
		assert.Equal(t, err, PluginMissing{plugin: "non-existent"})
	})
}

func TestPluginExists(t *testing.T) {
	testDataDir := t.TempDir()
	pluginDir := data.PluginDirectory(testDataDir, testPluginName)
	err := os.MkdirAll(pluginDir, 0o777)
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
		pluginDir := data.PluginDirectory(testDataDir, pluginName)
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
		exists, err := PluginExists(testDataDir, "non-existent")
		if err != nil {
			t.Errorf("got %v, expected nil", err)
		}

		if exists != false {
			t.Error("got false, expected true")
		}
	})
}

func TestValidatePluginName(t *testing.T) {
	t.Run("returns no error when plugin name is valid", func(t *testing.T) {
		err := validatePluginName(testPluginName)
		assert.Nil(t, err)
	})

	invalids := []string{"plugin^name", "plugin%name", "plugin name", "PLUGIN_NAME"}

	for _, invalid := range invalids {
		t.Run(invalid, func(t *testing.T) {
			err := validatePluginName(invalid)

			if err == nil {
				t.Error("Expected an error")
			}
		})
	}
}

func TestRunCallback(t *testing.T) {
	emptyEnv := map[string]string{}

	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}
	_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)

	plugin := New(conf, testPluginName)

	t.Run("returns NoCallback error when callback with name not found", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder

		err = plugin.RunCallback("non-existent", []string{}, emptyEnv, &stdout, &stderr)

		assert.Equal(t, err.(NoCallbackError).Error(), "Plugin named lua does not have a callback named non-existent")
	})

	t.Run("passes argument to command", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder

		err = plugin.RunCallback("debug", []string{"123"}, emptyEnv, &stdout, &stderr)
		assert.Nil(t, err)
		assert.Equal(t, "123\n", stdout.String())
		assert.Equal(t, "", stderr.String())
	})

	t.Run("passes arguments to command", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder

		err = plugin.RunCallback("debug", []string{"123", "test string"}, emptyEnv, &stdout, &stderr)
		assert.Nil(t, err)
		assert.Equal(t, "123 test string\n", stdout.String())
		assert.Equal(t, "", stderr.String())
	})

	t.Run("passes env to command", func(t *testing.T) {
		var stdout strings.Builder
		var stderr strings.Builder

		err = plugin.RunCallback("post-plugin-update", []string{}, map[string]string{"ASDF_PLUGIN_PREV_REF": "TEST"}, &stdout, &stderr)
		assert.Nil(t, err)
		assert.Equal(t, "plugin updated path= old git-ref=TEST new git-ref=\n", stdout.String())
		assert.Equal(t, "", stderr.String())
	})
}

func TestCallbackPath(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}
	_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)
	plugin := New(conf, testPluginName)

	t.Run("returns callback path when callback exists", func(t *testing.T) {
		path, err := plugin.CallbackPath("install")
		assert.Nil(t, err)
		assert.Equal(t, filepath.Base(path), "install")
		assert.Equal(t, filepath.Base(filepath.Dir(filepath.Dir(path))), plugin.Name)
		assert.Equal(t, filepath.Base(filepath.Dir(filepath.Dir(filepath.Dir(path)))), "plugins")
	})

	t.Run("returns error when callback does not exist", func(t *testing.T) {
		path, err := plugin.CallbackPath("non-existent")
		assert.Equal(t, err.(NoCallbackError).Error(), "Plugin named lua does not have a callback named non-existent")
		assert.Equal(t, path, "")
	})
}

func TestGetExtensionCommands(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}
	_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)
	plugin := New(conf, testPluginName)

	t.Run("returns empty slice when no extension commands defined", func(t *testing.T) {
		commands, err := plugin.GetExtensionCommands()
		assert.Nil(t, err)
		assert.Empty(t, commands)
	})

	t.Run("returns slice of with default extension command if it is present", func(t *testing.T) {
		assert.Nil(t, writeExtensionCommand(t, plugin, "", "#!/usr/bin/env bash\necho $1"))
		commands, err := plugin.GetExtensionCommands()
		assert.Nil(t, err)
		assert.Equal(t, commands, []string{""})
	})

	t.Run("returns slice of all extension commands when they are present", func(t *testing.T) {
		assert.Nil(t, writeExtensionCommand(t, plugin, "", "#!/usr/bin/env bash\necho $1"))
		assert.Nil(t, writeExtensionCommand(t, plugin, "foobar", "#!/usr/bin/env bash\necho $1"))

		commands, err := plugin.GetExtensionCommands()
		assert.Nil(t, err)
		assert.Equal(t, commands, []string{"", "foobar"})
	})
}

func TestExtensionCommandPath(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}
	_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)
	plugin := New(conf, testPluginName)

	t.Run("returns NoCallback error when callback with name not found", func(t *testing.T) {
		path, err := plugin.ExtensionCommandPath("non-existent")

		assert.Equal(t, err.(NoCommandError).Error(), "Plugin named lua does not have a extension command named non-existent")
		assert.Equal(t, path, "")
	})

	t.Run("returns default extension command script when no name", func(t *testing.T) {
		assert.Nil(t, writeExtensionCommand(t, plugin, "", "#!/usr/bin/env bash\necho $1"))
		path, err := plugin.ExtensionCommandPath("")
		assert.Nil(t, err)
		assert.Equal(t, filepath.Base(path), "command")
	})

	t.Run("passes arguments to command", func(t *testing.T) {
		assert.Nil(t, writeExtensionCommand(t, plugin, "debug", "#!/usr/bin/env bash\necho $@"))
		path, err := plugin.ExtensionCommandPath("debug")
		assert.Nil(t, err)
		assert.Equal(t, filepath.Base(path), "command-debug")
	})
}

func writeExtensionCommand(t *testing.T, plugin Plugin, name, contents string) error {
	t.Helper()
	assert.Nil(t, os.MkdirAll(filepath.Join(plugin.Dir, "lib", "commands"), 0o777))
	filename := "command"
	if name != "" {
		filename = fmt.Sprintf("command-%s", name)
	}

	path := filepath.Join(plugin.Dir, "lib", "commands", filename)
	err := os.WriteFile(path, []byte(contents), 0o777)
	return err
}

func TestLegacyFilenames(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}
	_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)
	plugin := New(conf, testPluginName)

	t.Run("returns list of filenames when list-legacy-filenames callback is present", func(t *testing.T) {
		filenames, err := plugin.LegacyFilenames()
		assert.Nil(t, err)
		assert.Equal(t, filenames, []string{".dummy-version", ".dummyrc"})
	})

	t.Run("returns empty list when list-legacy-filenames callback not present", func(t *testing.T) {
		testPluginName := "foobar"
		_, err := repotest.InstallPlugin("dummy_plugin_no_download", testDataDir, testPluginName)
		assert.Nil(t, err)
		plugin := New(conf, testPluginName)

		filenames, err := plugin.LegacyFilenames()
		assert.Nil(t, err)
		assert.Equal(t, filenames, []string{})
	})
}

func TestParseLegacyVersionFile(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}
	_, err := repotest.InstallPlugin("dummy_plugin", testDataDir, testPluginName)
	assert.Nil(t, err)
	plugin := New(conf, testPluginName)

	data := []byte("dummy-1.2.3")
	currentDir := t.TempDir()
	path := filepath.Join(currentDir, ".dummy-version")
	err = os.WriteFile(path, data, 0o666)
	assert.Nil(t, err)

	t.Run("returns file contents unchanged when parse-legacy-file callback not present", func(t *testing.T) {
		testPluginName := "foobar"
		_, err := repotest.InstallPlugin("dummy_plugin_no_download", testDataDir, testPluginName)
		assert.Nil(t, err)
		plugin := New(conf, testPluginName)

		versions, err := plugin.ParseLegacyVersionFile(path)
		assert.Nil(t, err)
		assert.Equal(t, versions, []string{"dummy-1.2.3"})
	})

	t.Run("returns file contents parsed by parse-legacy-file callback when it is present", func(t *testing.T) {
		versions, err := plugin.ParseLegacyVersionFile(path)
		assert.Nil(t, err)
		assert.Equal(t, versions, []string{"1.2.3"})
	})

	t.Run("returns error when passed file that doesn't exist", func(t *testing.T) {
		versions, err := plugin.ParseLegacyVersionFile("non-existent-file")
		assert.Error(t, err)
		assert.Empty(t, versions)
	})
}

func touchFile(name string) error {
	file, err := os.OpenFile(name, os.O_RDONLY|os.O_CREATE, 0o644)
	if err != nil {
		return err
	}
	return file.Close()
}

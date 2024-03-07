package plugins

import (
	"asdf/config"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

// TODO: Switch to local repo so tests don't go over the network
const (
	testRepo       = "https://github.com/Stratus3D/asdf-lua"
	testPluginName = "lua"
)

func TestList(t *testing.T) {
	testDataDir := t.TempDir()
	conf := config.Config{DataDir: testDataDir}
	testRepo, err := installMockPluginRepo(testDataDir, testPluginName)
	assert.Nil(t, err)

	err = PluginAdd(conf, testPluginName, testRepo)
	assert.Nil(t, err)

	t.Run("when urls and refs are set to false returns plugin names", func(t *testing.T) {
		plugins, err := List(conf, false, false)
		assert.Nil(t, err)

		plugin := plugins[0]
		assert.Equal(t, "lua", plugin.Name)
		assert.NotZero(t, plugin.Dir)
		assert.Zero(t, plugin.Url)
		assert.Zero(t, plugin.Ref)
	})

	t.Run("when urls is set to true returns plugins with repo urls set", func(t *testing.T) {
		plugins, err := List(conf, true, false)
		assert.Nil(t, err)

		plugin := plugins[0]
		assert.Equal(t, "lua", plugin.Name)
		assert.NotZero(t, plugin.Dir)
		assert.Zero(t, plugin.Ref)
		assert.NotZero(t, plugin.Url)
	})

	t.Run("when refs is set to true returns plugins with current repo refs set", func(t *testing.T) {
		plugins, err := List(conf, false, true)
		assert.Nil(t, err)

		plugin := plugins[0]
		assert.Equal(t, "lua", plugin.Name)
		assert.NotZero(t, plugin.Dir)
		assert.NotZero(t, plugin.Ref)
		assert.Zero(t, plugin.Url)
	})

	t.Run("when refs and urls are both set to true returns plugins with both set", func(t *testing.T) {
		plugins, err := List(conf, true, true)
		assert.Nil(t, err)

		plugin := plugins[0]
		assert.Equal(t, "lua", plugin.Name)
		assert.NotZero(t, plugin.Dir)
		assert.NotZero(t, plugin.Ref)
		assert.NotZero(t, plugin.Url)
	})
}

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

func installMockPluginRepo(dataDir, name string) (string, error) {
	// Because the legacy dummy plugin directory is relative to the root of this
	// project I cannot use the usual testing functions to locate it. To
	// determine the location of it we compute the module root, which also
	// happens to be the root of the repo.
	modRootDir, err := moduleRoot()
	if err != nil {
		return "", err
	}

	location := dataDir + "/repo-" + name

	// Then we specify the path to the dummy plugin relative to the module root
	err = runCmd("cp", "-r", filepath.Join(modRootDir, "test/fixtures/dummy_plugin"), location)
	if err != nil {
		return location, err
	}

	// Definitely some opportunities to refactor here. This code might be
	// simplified by switching to the Go git library
	err = runCmd("git", "-C", location, "init", "-q")
	if err != nil {
		return location, err
	}

	err = runCmd("git", "-C", location, "config", "user.name", "\"Test\"")
	if err != nil {
		return location, err
	}

	err = runCmd("git", "-C", location, "config", "user.email", "\"test@example.com\"")
	if err != nil {
		return location, err
	}

	err = runCmd("git", "-C", location, "add", "-A")
	if err != nil {
		return location, err
	}

	err = runCmd("git", "-C", location, "commit", "-q", "-m", fmt.Sprintf("\"asdf %s plugin\"", name))
	return location, err
}

// helper function to make running commands easier
func runCmd(cmdName string, args ...string) error {
	cmd := exec.Command(cmdName, args...)

	// Capture stdout and stderr
	var stdout strings.Builder
	var stderr strings.Builder
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()

	if err != nil {
		// If command fails print both stderr and stdout
		fmt.Println("stdout:", stdout.String())
		fmt.Println("stderr:", stderr.String())
		return err
	}

	return nil
}

func moduleRoot() (string, error) {
	currentDir, err := os.Getwd()

	if err != nil {
		return "", err
	}

	return findModuleRoot(currentDir), nil
}

// Taken from https://github.com/golang/go/blob/9e3b1d53a012e98cfd02de2de8b1bd53522464d4/src/cmd/go/internal/modload/init.go#L1504C1-L1522C2 because that function is in an internal module
// and I can't rely on it.
func findModuleRoot(dir string) (roots string) {
	if dir == "" {
		panic("dir not set")
	}
	dir = filepath.Clean(dir)

	// Look for enclosing go.mod.
	for {
		if fi, err := os.Stat(filepath.Join(dir, "go.mod")); err == nil && !fi.IsDir() {
			return dir
		}
		d := filepath.Dir(dir)
		if d == dir {
			break
		}
		dir = d
	}
	return ""
}

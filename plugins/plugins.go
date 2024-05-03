// Package plugins provides functions for interacting with asdf plugins
package plugins

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"

	"asdf/config"

	"github.com/go-git/go-git/v5"
)

const (
	dataDirPlugins       = "plugins"
	invalidPluginNameMsg = "'%q' is invalid. Name may only contain lowercase letters, numbers, '_', and '-'"
	pluginAlreadyExists  = "plugin named %q already added"
)

// Plugin represents a plugin to the packages in asdf
type Plugin struct {
	Name string
	Dir  string
	Ref  string
	URL  string
}

// List takes config and flags for what to return and builds a list of plugins
// representing the currently installed plugins on the system.
func List(config config.Config, urls, refs bool) (plugins []Plugin, err error) {
	pluginsDir := DataDirectory(config.DataDir)
	files, err := os.ReadDir(pluginsDir)
	if err != nil {
		return plugins, err
	}

	for _, file := range files {
		if file.IsDir() {
			if refs || urls {
				var url string
				var refString string
				location := filepath.Join(pluginsDir, file.Name())
				repo, err := git.PlainOpen(location)
				// TODO: Improve these error messages
				if err != nil {
					return plugins, err
				}

				if refs {
					ref, err := repo.Head()
					refString = ref.Hash().String()

					if err != nil {
						return plugins, err
					}
				}

				if urls {
					remotes, err := repo.Remotes()
					url = remotes[0].Config().URLs[0]

					if err != nil {
						return plugins, err
					}
				}

				plugins = append(plugins, Plugin{
					Name: file.Name(),
					Dir:  location,
					URL:  url,
					Ref:  refString,
				})
			} else {
				plugins = append(plugins, Plugin{
					Name: file.Name(),
					Dir:  filepath.Join(pluginsDir, file.Name()),
				})
			}
		}
	}

	return plugins, nil
}

// Add takes plugin name and Git URL and installs the plugin if it isn't
// already installed
func Add(config config.Config, pluginName, pluginURL string) error {
	err := validatePluginName(pluginName)
	if err != nil {
		return err
	}

	exists, err := PluginExists(config.DataDir, pluginName)
	if err != nil {
		return fmt.Errorf("unable to check if plugin already exists: %w", err)
	}

	if exists {
		return fmt.Errorf(pluginAlreadyExists, pluginName)
	}

	pluginDir := PluginDirectory(config.DataDir, pluginName)

	if err != nil {
		return fmt.Errorf("unable to create plugin directory: %w", err)
	}

	_, err = git.PlainClone(pluginDir, false, &git.CloneOptions{
		URL: pluginURL,
	})
	if err != nil {
		return fmt.Errorf("unable to clone plugin: %w", err)
	}

	return nil
}

// Remove removes a plugin with the provided name if installed
func Remove(config config.Config, pluginName string) error {
	err := validatePluginName(pluginName)
	if err != nil {
		return err
	}

	exists, err := PluginExists(config.DataDir, pluginName)
	if err != nil {
		return fmt.Errorf("unable to check if plugin exists: %w", err)
	}

	if !exists {
		return fmt.Errorf("no such plugin: %s", pluginName)
	}

	pluginDir := PluginDirectory(config.DataDir, pluginName)

	return os.RemoveAll(pluginDir)
}

// PluginExists returns a boolean indicating whether or not a plugin with the
// provided name is currently installed
func PluginExists(dataDir, pluginName string) (bool, error) {
	pluginDir := PluginDirectory(dataDir, pluginName)
	fileInfo, err := os.Stat(pluginDir)
	if errors.Is(err, os.ErrNotExist) {
		return false, nil
	}

	if err != nil {
		return false, err
	}

	return fileInfo.IsDir(), nil
}

// PluginDirectory returns the directory a plugin would be installed in, if it
// is installed
func PluginDirectory(dataDir, pluginName string) string {
	return filepath.Join(DataDirectory(dataDir), pluginName)
}

// DataDirectory return the plugin directory inside the data directory
func DataDirectory(dataDir string) string {
	return filepath.Join(dataDir, dataDirPlugins)
}

func validatePluginName(name string) error {
	match, err := regexp.MatchString("^[[:lower:][:digit:]_-]+$", name)
	if err != nil {
		return err
	}

	if !match {
		return fmt.Errorf(invalidPluginNameMsg, name)
	}

	return nil
}

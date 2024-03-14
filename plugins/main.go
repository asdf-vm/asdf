package plugins

import (
	"asdf/config"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"

	"github.com/go-git/go-git/v5"
)

const dataDirPlugins = "plugins"
const invalidPluginNameMsg = "'%q' is invalid. Name may only contain lowercase letters, numbers, '_', and '-'"
const pluginAlreadyExists = "plugin named %q already added"

type Plugin struct {
	Name string
	Dir  string
	Ref  string
	Url  string
}

func List(config config.Config, urls, refs bool) (plugins []Plugin, err error) {
	pluginsDir := PluginsDataDirectory(config.DataDir)
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
					Url:  url,
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

func Add(config config.Config, pluginName, pluginUrl string) error {
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
		URL: pluginUrl,
	})

	if err != nil {
		return fmt.Errorf("unable to clone plugin: %w", err)
	}

	return nil
}

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

func PluginDirectory(dataDir, pluginName string) string {
	return filepath.Join(PluginsDataDirectory(dataDir), pluginName)
}

func PluginsDataDirectory(dataDir string) string {
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

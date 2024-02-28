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

func PluginAdd(config config.Config, pluginName, pluginUrl string) error {
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
	return filepath.Join(dataDir, dataDirPlugins, pluginName)
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

// Package plugins provides functions for interacting with asdf plugins
package plugins

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"

	"asdf/config"
	"asdf/execute"
	"asdf/git"
	"asdf/hook"
	"asdf/pluginindex"
)

// NewPluginAlreadyExists generates a new PluginAlreadyExists error instance for
// a particular plugin
func NewPluginAlreadyExists(plugin string) PluginAlreadyExists {
	return PluginAlreadyExists{plugin: plugin}
}

// PluginAlreadyExists is an error returned when the specified plugin already
// exists
type PluginAlreadyExists struct {
	plugin string
}

func (e PluginAlreadyExists) Error() string {
	return fmt.Sprintf(pluginAlreadyExistsMsg, e.plugin)
}

// NoCallbackError is an error returned by RunCallback when a callback with
// particular name does not exist
type NoCallbackError struct {
	callback string
	plugin   string
}

func (e NoCallbackError) Error() string {
	return fmt.Sprintf(hasNoCallbackMsg, e.plugin, e.callback)
}

const (
	dataDirPlugins         = "plugins"
	invalidPluginNameMsg   = "%s is invalid. Name may only contain lowercase letters, numbers, '_', and '-'"
	pluginAlreadyExistsMsg = "Plugin named %s already added"
	hasNoCallbackMsg       = "Plugin named %s does not have a callback named %s"
)

// Plugin struct represents an asdf plugin to all asdf code. The name and dir
// fields are the most used fields. Ref and Dir only still git info, which is
// only information and shown to the user at times.
type Plugin struct {
	Name string
	Dir  string
	Ref  string
	URL  string
}

// New takes config and a plugin name and returns a Plugin struct. It is
// intended for functions that need to quickly initialize a plugin.
func New(config config.Config, name string) Plugin {
	pluginsDir := DataDirectory(config.DataDir)
	dir := filepath.Join(pluginsDir, name)
	return Plugin{Dir: dir, Name: name}
}

// RunCallback invokes a callback with the given name if it exists for the plugin
func (p Plugin) RunCallback(name string, arguments []string, environment map[string]string, stdOut io.Writer, errOut io.Writer) error {
	callback := filepath.Join(p.Dir, "bin", name)

	_, err := os.Stat(callback)
	if errors.Is(err, os.ErrNotExist) {
		return NoCallbackError{callback: name, plugin: p.Name}
	}

	cmd := execute.New(fmt.Sprintf("'%s'", callback), arguments)
	cmd.Env = environment

	cmd.Stdout = stdOut
	cmd.Stderr = errOut

	return cmd.Run()
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
				plugin := git.NewRepo(location)

				// TODO: Improve these error messages
				if err != nil {
					return plugins, err
				}

				if refs {
					refString, err = plugin.Head()
					if err != nil {
						return plugins, err
					}
				}

				if urls {
					url, err = plugin.RemoteURL()
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
		return NewPluginAlreadyExists(pluginName)
	}

	plugin := New(config, pluginName)

	if pluginURL == "" {
		// Ignore error here as the default value is fine
		disablePluginIndex, _ := config.DisablePluginShortNameRepository()

		if disablePluginIndex {
			return fmt.Errorf("Short-name plugin repository is disabled")
		}

		lastCheckDuration := 0
		// We don't care about errors here as we can use the default value
		checkDuration, _ := config.PluginRepositoryLastCheckDuration()

		if !checkDuration.Never {
			lastCheckDuration = checkDuration.Every
		}

		index := pluginindex.Build(config.DataDir, "https://github.com/asdf-vm/asdf-plugins.git", false, lastCheckDuration)
		var err error
		pluginURL, err = index.GetPluginSourceURL(pluginName)
		if err != nil {
			return fmt.Errorf("error fetching plugin URL: %s", err)
		}
	}

	plugin.URL = pluginURL

	// Run pre hooks
	hook.Run(config, "pre_asdf_plugin_add", []string{plugin.Name})
	hook.Run(config, fmt.Sprintf("pre_asdf_plugin_add_%s", plugin.Name), []string{})

	err = git.NewRepo(plugin.Dir).Clone(plugin.URL)
	if err != nil {
		return err
	}

	env := map[string]string{"ASDF_PLUGIN_SOURCE_URL": plugin.URL, "ASDF_PLUGIN_PATH": plugin.Dir}
	plugin.RunCallback("post-plugin-add", []string{}, env, os.Stdout, os.Stderr)

	// Run post hooks
	hook.Run(config, "post_asdf_plugin_add", []string{plugin.Name})
	hook.Run(config, fmt.Sprintf("post_asdf_plugin_add_%s", plugin.Name), []string{})

	return nil
}

// Remove uninstalls a plugin by removing it from the file system if installed
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

// Update a plugin to a specific ref, or if no ref provided update to latest
func Update(config config.Config, pluginName, ref string) (string, error) {
	exists, err := PluginExists(config.DataDir, pluginName)
	if err != nil {
		return "", fmt.Errorf("unable to check if plugin exists: %w", err)
	}

	if !exists {
		return "", fmt.Errorf("no such plugin: %s", pluginName)
	}

	pluginDir := PluginDirectory(config.DataDir, pluginName)

	plugin := git.NewRepo(pluginDir)

	return plugin.Update(ref)
}

// PluginExists returns a boolean indicating whether or not a plugin with the
// provided name is currently installed
func PluginExists(dataDir, pluginName string) (bool, error) {
	pluginDir := PluginDirectory(dataDir, pluginName)
	return directoryExists(pluginDir)
}

func directoryExists(dir string) (bool, error) {
	fileInfo, err := os.Stat(dir)
	if errors.Is(err, os.ErrNotExist) {
		return false, nil
	}

	if err != nil {
		return false, err
	}

	return fileInfo.IsDir(), nil
}

// PluginDirectory returns the directory a plugin with a given name would be in
// if it were installed
func PluginDirectory(dataDir, pluginName string) string {
	return filepath.Join(DataDirectory(dataDir), pluginName)
}

// DataDirectory returns the path to the plugin directory inside the data
// directory
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

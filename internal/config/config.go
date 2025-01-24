// Package config provides a unified API for fetching asdf config. Either from
// the asdfrc file or environment variables.
package config

import (
	"context"
	"io/fs"
	"strconv"
	"strings"

	"github.com/mitchellh/go-homedir"
	"github.com/sethvargo/go-envconfig"
	"gopkg.in/ini.v1"
)

const (
	forcePrependDefault                = false
	dataDirDefault                     = "~/.asdf"
	configFileDefault                  = "~/.asdfrc"
	defaultToolVersionsFilenameDefault = ".tool-versions"
	defaultPluginIndexURL              = "https://github.com/asdf-vm/asdf-plugins.git"
)

/* PluginRepoCheckDuration represents the remote plugin repo check duration
* (never or every N seconds). It's not clear to me how this should be
* represented in Golang so using a struct for maximum flexibility. */
type PluginRepoCheckDuration struct {
	Never bool
	Every int
}

var pluginRepoCheckDurationDefault = PluginRepoCheckDuration{Every: 60}

// Config is the primary value this package builds and returns
type Config struct {
	Home                        string
	ConfigFile                  string `env:"ASDF_CONFIG_FILE, overwrite"`
	DefaultToolVersionsFilename string `env:"ASDF_DEFAULT_TOOL_VERSIONS_FILENAME, overwrite"`
	// Unclear if this value will be needed with the golang implementation.
	// AsdfDir string
	DataDir      string `env:"ASDF_DATA_DIR, overwrite"`
	ForcePrepend bool   `env:"ASDF_FORCE_PREPEND, overwrite"`
	// Field that stores the settings struct if it is loaded
	Settings       Settings
	PluginIndexURL string
}

// Settings is a struct that stores config values from the asdfrc file
type Settings struct {
	Loaded            bool
	Raw               *ini.Section
	LegacyVersionFile bool
	// I don't think this setting should be supported in the Golang implementation
	// UseReleaseCandidates bool
	AlwaysKeepDownload                bool
	PluginRepositoryLastCheckDuration PluginRepoCheckDuration
	DisablePluginShortNameRepository  bool
	Concurrency                       string
}

func defaultConfig(dataDir, configFile string) *Config {
	return &Config{
		ForcePrepend:                forcePrependDefault,
		DataDir:                     dataDir,
		ConfigFile:                  configFile,
		DefaultToolVersionsFilename: defaultToolVersionsFilenameDefault,
		PluginIndexURL:              defaultPluginIndexURL,
	}
}

func defaultSettings() *Settings {
	return &Settings{
		Loaded:                            false,
		Raw:                               nil,
		LegacyVersionFile:                 false,
		AlwaysKeepDownload:                false,
		PluginRepositoryLastCheckDuration: pluginRepoCheckDurationDefault,
		DisablePluginShortNameRepository:  false,
	}
}

func newPluginRepoCheckDuration(checkDuration string) PluginRepoCheckDuration {
	if strings.ToLower(checkDuration) == "never" {
		return PluginRepoCheckDuration{Never: true}
	}

	every, err := strconv.Atoi(checkDuration)
	if err != nil {
		// if error parsing config use default value
		return pluginRepoCheckDurationDefault
	}

	return PluginRepoCheckDuration{Every: every}
}

// LoadConfig builds the Config struct from environment variables
func LoadConfig() (Config, error) {
	config, err := loadConfigEnv()
	if err != nil {
		return config, err
	}

	homeDir, err := homedir.Dir()
	if err != nil {
		return config, err
	}

	config.Home = homeDir

	return config, nil
}

// Methods on the Config struct that allow it to load and cache values from the
// Settings struct, which is loaded from file on disk and therefor somewhat
// "expensive".

// LegacyVersionFile loads the asdfrc if it isn't already loaded and fetches
// the legacy version file support flag
func (c *Config) LegacyVersionFile() (bool, error) {
	err := c.loadSettings()
	if err != nil {
		return false, err
	}

	return c.Settings.LegacyVersionFile, nil
}

// AlwaysKeepDownload loads the asdfrc if it isn't already loaded and fetches
// the keep downloads boolean flag
func (c *Config) AlwaysKeepDownload() (bool, error) {
	err := c.loadSettings()
	if err != nil {
		return false, err
	}

	return c.Settings.AlwaysKeepDownload, nil
}

// PluginRepositoryLastCheckDuration loads the asdfrc if it isn't already loaded
// and fetches the keep  boolean flag
func (c *Config) PluginRepositoryLastCheckDuration() (PluginRepoCheckDuration, error) {
	err := c.loadSettings()
	if err != nil {
		return newPluginRepoCheckDuration(""), err
	}

	return c.Settings.PluginRepositoryLastCheckDuration, nil
}

// DisablePluginShortNameRepository loads the asdfrc if it isn't already loaded
// and fetches the disable plugin short name repo flag
func (c *Config) DisablePluginShortNameRepository() (bool, error) {
	err := c.loadSettings()
	if err != nil {
		return false, err
	}

	return c.Settings.DisablePluginShortNameRepository, nil
}

// Concurrency returns concurrency setting from asdfrc file
func (c *Config) Concurrency() (string, error) {
	err := c.loadSettings()
	if err != nil {
		return "", err
	}

	return c.Settings.Concurrency, nil
}

// GetHook returns a hook command from config if it is there
func (c *Config) GetHook(hook string) (string, error) {
	err := c.loadSettings()
	if err != nil {
		return "", err
	}

	if c.Settings.Raw != nil {
		return c.Settings.Raw.Key(hook).String(), nil
	}

	return "", nil
}

func (c *Config) loadSettings() error {
	if c.Settings.Loaded {
		return nil
	}

	settings, err := loadSettings(c.ConfigFile)

	c.Settings = settings

	if err != nil {
		_, ok := err.(*fs.PathError)
		if ok {
			return nil
		}

		return err
	}

	return nil
}

func loadConfigEnv() (Config, error) {
	dataDir, err := homedir.Expand(dataDirDefault)
	if err != nil {
		return Config{}, err
	}

	configFile, err := homedir.Expand(configFileDefault)
	if err != nil {
		return Config{}, err
	}

	config := defaultConfig(dataDir, configFile)

	context := context.Background()
	err = envconfig.Process(context, config)

	return *config, err
}

func loadSettings(asdfrcPath string) (Settings, error) {
	settings := defaultSettings()

	// asdfrc is effectively formatted as ini
	config, err := ini.Load(asdfrcPath)
	if err != nil {
		return *settings, err
	}

	mainConf := config.Section("")

	settings.Raw = mainConf

	settings.Loaded = true
	settings.PluginRepositoryLastCheckDuration = newPluginRepoCheckDuration(mainConf.Key("plugin_repository_last_check_duration").String())

	boolOverride(&settings.LegacyVersionFile, mainConf, "legacy_version_file")
	boolOverride(&settings.AlwaysKeepDownload, mainConf, "always_keep_download")
	boolOverride(&settings.DisablePluginShortNameRepository, mainConf, "disable_plugin_short_name_repository")
	settings.Concurrency = strings.ToLower(mainConf.Key("concurrency").String())

	return *settings, nil
}

func boolOverride(field *bool, section *ini.Section, key string) {
	lcYesOrNo := strings.ToLower(section.Key(key).String())

	if lcYesOrNo == "yes" {
		*field = true
	}
	if lcYesOrNo == "no" {
		*field = false
	}
}

package config

import (
	"context"
	"strconv"
	"strings"

	"github.com/mitchellh/go-homedir"
	"github.com/sethvargo/go-envconfig"
	"gopkg.in/ini.v1"
)

const LegacyVersionFileDefault = false
const AlwaysKeepDownloadDefault = false
const DisablePluginShortNameRepositoryDefault = false
const ForcePrependDefault = false
const DataDirDefault = "~/.asdf"
const ConfigFileDefault = "~/.asdfrc"
const DefaultToolVersionsFilenameDefault = ".tool-versions"

/* Struct to represent the remote plugin repo check duration (never or every N
* seconds). It's not clear to me how this should be represented in Golang so
* using a struct for maximum flexibility. */
type PluginRepoCheckDuration struct {
	Never bool
	Every int
}

var PluginRepoCheckDurationDefault = PluginRepoCheckDuration{Every: 60}

type Settings struct {
	Loaded            bool
	LegacyVersionFile bool
	// I don't think this setting should be supported in the Golang implementation
	//UseReleaseCandidates bool
	AlwaysKeepDownload                bool
	PluginRepositoryLastCheckDuration PluginRepoCheckDuration
	DisablePluginShortNameRepository  bool
}

type Config struct {
	Home                        string
	ConfigFile                  string `env:"ASDF_CONFIG_FILE, overwrite"`
	DefaultToolVersionsFilename string `env:"ASDF_DEFAULT_TOOL_VERSIONS_FILENAME, overwrite"`
	// Unclear if this value will be needed with the golang implementation.
	//AsdfDir string
	DataDir      string `env:"ASDF_DATA_DIR, overwrite"`
	ForcePrepend bool   `env:"ASDF_FORCE_PREPEND, overwrite"`
	// Field that stores the settings struct if it is loaded
	Settings Settings
}

func NewPluginRepoCheckDuration(checkDuration string) PluginRepoCheckDuration {
	if strings.ToLower(checkDuration) == "never" {
		return PluginRepoCheckDuration{Never: true}
	}

	every, err := strconv.Atoi(checkDuration)
	if err != nil {
		// if error parsing config use default value
		return PluginRepoCheckDurationDefault
	}

	return PluginRepoCheckDuration{Every: every}
}

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
func (c *Config) LegacyVersionFile() (bool, error) {
	err := c.loadSettings()

	if err != nil {
		return false, err
	}

	return c.Settings.LegacyVersionFile, nil
}

func (c *Config) AlwaysKeepDownload() (bool, error) {
	err := c.loadSettings()

	if err != nil {
		return false, err
	}

	return c.Settings.AlwaysKeepDownload, nil
}

func (c *Config) PluginRepositoryLastCheckDuration() (PluginRepoCheckDuration, error) {
	err := c.loadSettings()

	if err != nil {
		return NewPluginRepoCheckDuration(""), err
	}

	return c.Settings.PluginRepositoryLastCheckDuration, nil
}

func (c *Config) DisablePluginShortNameRepository() (bool, error) {
	err := c.loadSettings()

	if err != nil {
		return false, err
	}

	return c.Settings.DisablePluginShortNameRepository, nil
}

func (c *Config) loadSettings() error {
	if c.Settings.Loaded {
		return nil
	}

	settings, err := loadSettings(c.ConfigFile)

	if err != nil {
		return err
	}

	c.Settings = settings

	return nil
}

func loadConfigEnv() (Config, error) {
	dataDir, err := homedir.Expand(DataDirDefault)
	if err != nil {
		return Config{}, err
	}

	configFile, err := homedir.Expand(ConfigFileDefault)
	if err != nil {
		return Config{}, err
	}

	config := Config{
		ForcePrepend:                ForcePrependDefault,
		DataDir:                     dataDir,
		ConfigFile:                  configFile,
		DefaultToolVersionsFilename: DefaultToolVersionsFilenameDefault,
	}

	context := context.Background()
	err = envconfig.Process(context, &config)

	return config, err
}

func loadSettings(asdfrcPath string) (Settings, error) {
	// asdfrc is effectively formatted as ini
	config, err := ini.Load(asdfrcPath)

	if err != nil {
		return Settings{}, err
	}

	mainConf := config.Section("")
	checkDuration := NewPluginRepoCheckDuration(mainConf.Key("plugin_repository_last_check_duration").String())

	return Settings{
		Loaded:                            true,
		LegacyVersionFile:                 yesNoToBool(mainConf, "legacy_version_file", LegacyVersionFileDefault),
		AlwaysKeepDownload:                yesNoToBool(mainConf, "use_release_candidates", AlwaysKeepDownloadDefault),
		PluginRepositoryLastCheckDuration: checkDuration,
		DisablePluginShortNameRepository:  yesNoToBool(mainConf, "disable_plugin_short_name_repository", DisablePluginShortNameRepositoryDefault),
	}, nil
}

func yesNoToBool(section *ini.Section, key string, defaultValue bool) bool {
	yesOrNo := section.Key(key).String()
	lcYesOrNo := strings.ToLower(yesOrNo)
	if lcYesOrNo == "yes" {
		return true
	}
	if lcYesOrNo == "no" {
		return false
	}

	return defaultValue
}

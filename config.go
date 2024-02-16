package main

import (
	"context"
	"strings"

	"github.com/mitchellh/go-homedir"
	"github.com/sethvargo/go-envconfig"
	"gopkg.in/ini.v1"
)

// Not sure how best to represent this enum type
//type PluginRepositoryLastCheckDuration struct {
//  Never bool
//  Every int
//}

type Settings struct {
	LegacyVersionFile bool
	// I don't think this setting should be supported in the Golang implementation
	//UseReleaseCandidates bool
	AlwaysKeepDownload                bool
	PluginRepositoryLastCheckDuration string
	DisablePluginShortNameRepository  bool
}

type Config struct {
	Home                        string
	ConfigFile                  string `env:"ASDF_CONFIG_FILE"`
	DefaultToolVersionsFilename string `env:"ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"`
	// Unclear if this value will be needed with the golang implementation.
	//AsdfDir string
	DataDir      string `env:"ASDF_DATA_DIR"`
	ForcePrepend bool   `env:"ASDF_FORCE_PREPEND"`
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

func loadConfigEnv() (Config, error) {
	context := context.Background()
	config := Config{}

	err := envconfig.Process(context, &config)

	return config, err
}

func LoadSettings(asdfrcPath string) (Settings, error) {
	// asdfrc is effectively formatted as ini
	config, err := ini.Load(asdfrcPath)

	if err != nil {
		return Settings{}, err
	}

	mainConf := config.Section("")
	checkDuration := stringToCheckDuration(mainConf.Key("plugin_repository_last_check_duration").String(), "60")

	return Settings{
		LegacyVersionFile:                 YesNoToBool(mainConf, "legacy_version_file", false),
		AlwaysKeepDownload:                YesNoToBool(mainConf, "use_release_candidates", false),
		PluginRepositoryLastCheckDuration: checkDuration,
		DisablePluginShortNameRepository:  YesNoToBool(mainConf, "disable_plugin_short_name_repository", false),
	}, nil
}

func YesNoToBool(section *ini.Section, key string, defaultValue bool) bool {
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

// Eventually this should return a custom type but I need to figure out how to
// represent the (never string, duration int) type. For now it just returns a
// string.
func stringToCheckDuration(checkDuration string, defaultValue string) string {
	if checkDuration != "" {
		return checkDuration
	}

	return defaultValue
}

// Package resolve contains functions for resolving a tool version in a given
// directory. This is a core feature of asdf as asdf must be able to resolve a
// tool version in any directory if set.
package resolve

import (
	"fmt"
	"iter"
	"os"
	"path"
	"strings"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/toolversions"
)

// ToolVersions represents a tool along with versions specified for it
type ToolVersions struct {
	Versions  []string
	Directory string
	Source    string
}

// AllVersions takes a set of plugins and a directory and resolves all tools to one or more
// versions. This includes tools without a corresponding plugin.
func AllVersions(conf config.Config, plugins []plugins.Plugin, directory string) (versions map[string]ToolVersions, err error) {
	resolvedToolVersions := map[string]ToolVersions{}
	for _, plugin := range plugins {
		version, envVariableName, found := findVersionsInEnv(plugin.Name)
		if found {
			resolvedToolVersions[plugin.Name] = ToolVersions{Versions: version, Source: envVariableName}
		}
	}

	for iterDir := range iterDirectories(conf, directory) {
		for _, plugin := range plugins {
			if _, isPluginResolved := resolvedToolVersions[plugin.Name]; !isPluginResolved {
				version, found, err := findLegacyVersionsInDir(conf, plugin, iterDir)
				if err != nil {
					return versions, err
				}
				if found {
					resolvedToolVersions[plugin.Name] = version
				}
			}
		}

		filepath := path.Join(iterDir, conf.DefaultToolVersionsFilename)
		if _, err = os.Stat(filepath); err == nil {
			if allVersions, err := toolversions.GetAllToolsAndVersions(filepath); err == nil {
				for _, v := range allVersions {
					if _, isPluginResolved := resolvedToolVersions[v.Name]; !isPluginResolved {
						resolvedToolVersions[v.Name] = ToolVersions{Versions: v.Versions, Source: conf.DefaultToolVersionsFilename, Directory: iterDir}
					}
				}
			}
		}
	}
	return resolvedToolVersions, nil
}

// Version takes a plugin and a directory and resolves the tool to one or more
// versions. Only returns results for the provided plugin.
func Version(conf config.Config, plugin plugins.Plugin, directory string) (versions ToolVersions, found bool, err error) {
	version, envVariableName, found := findVersionsInEnv(plugin.Name)
	if found {
		return ToolVersions{Versions: version, Source: envVariableName}, true, nil
	}

	for iterDir := range iterDirectories(conf, directory) {
		versions, found, err = findVersionsInDir(conf, plugin, iterDir)
		if err != nil {
			return versions, false, err
		}
		if found {
			return versions, found, err
		}
	}
	return versions, found, err
}

func iterDirectories(conf config.Config, directory string) iter.Seq[string] {
	return func(yield func(string) bool) {
		if !yield(directory) {
			return
		}
		iterDir := directory
		for {
			nextDir := path.Dir(iterDir)
			// If current dir and next dir are the same it means we've reached `/` and
			// have no more parent directories to search.
			if nextDir == iterDir {
				break
			}
			if !yield(iterDir) {
				return
			}
			iterDir = nextDir
		}
		// If no version found, try current users home directory. I'd like to
		// eventually remove this feature.
		homeDir := conf.Home
		// homeDir, osErr := os.UserHomeDir()
		if homeDir != "" {
			if !yield(homeDir) {
				return
			}
		}
	}
}

func findVersionsInDir(conf config.Config, plugin plugins.Plugin, directory string) (versions ToolVersions, found bool, err error) {
	versions, found, err = findLegacyVersionsInDir(conf, plugin, directory)
	if found || err != nil {
		return versions, found, err
	}

	return versions, found, nil
}

func findLegacyVersionsInDir(conf config.Config, plugin plugins.Plugin, directory string) (versions ToolVersions, found bool, err error) {
	legacyFiles, err := conf.LegacyVersionFile()
	if err != nil {
		return versions, found, err
	}

	if legacyFiles {
		versions, found, err := findVersionsInLegacyFile(plugin, directory)

		if found || err != nil {
			return versions, found, err
		}
	}
	return versions, false, nil
}

// findVersionsInEnv returns the version from the environment if present
func findVersionsInEnv(pluginName string) ([]string, string, bool) {
	envVariableName := variableVersionName(pluginName)
	versionString := os.Getenv(envVariableName)
	if versionString == "" {
		return []string{}, envVariableName, false
	}
	return parseVersion(versionString), envVariableName, true
}

// findVersionsInLegacyFile looks up a legacy version in the given directory if
// the specified plugin has a list-legacy-filenames callback script. If the
// callback script exists asdf will look for files with the given name in the
// current and extract the version from them.
func findVersionsInLegacyFile(plugin plugins.Plugin, directory string) (versions ToolVersions, found bool, err error) {
	var legacyFileNames []string

	legacyFileNames, err = plugin.LegacyFilenames()
	if err != nil {
		return versions, false, err
	}

	for _, filename := range legacyFileNames {
		filepath := path.Join(directory, filename)
		if _, err := os.Stat(filepath); err == nil {
			versionsSlice, err := plugin.ParseLegacyVersionFile(filepath)

			if len(versionsSlice) == 0 || (len(versionsSlice) == 1 && versionsSlice[0] == "") {
				return versions, false, nil
			}
			return ToolVersions{Versions: versionsSlice, Source: filename, Directory: directory}, err == nil, err
		}
	}

	return versions, found, err
}

// parseVersion parses the raw version
func parseVersion(rawVersions string) []string {
	var versions []string
	for _, version := range strings.Split(rawVersions, " ") {
		version = strings.TrimSpace(version)
		if len(version) > 0 {
			versions = append(versions, version)
		}
	}
	return versions
}

func variableVersionName(toolName string) string {
	return fmt.Sprintf("ASDF_%s_VERSION", strings.ToUpper(toolName))
}

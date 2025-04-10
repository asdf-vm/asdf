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
	Name      string
	Versions  []string
	Directory string
	Source    string
}

// AllVersions takes a set of plugins and a directory and resolves all tools to one or more
// versions. This includes tools without a corresponding plugin.
func AllVersions(conf config.Config, plugins []plugins.Plugin, directory string) (versions []ToolVersions, err error) {
	resolvedToolVersions := map[string]bool{}
	var finalVersions []ToolVersions

	// First: Resolve using environment values
	for _, plugin := range plugins {
		version, envVariableName, found := findVersionsInEnv(plugin.Name)
		if found {
			resolvedToolVersions[plugin.Name] = true
			finalVersions = append(finalVersions, ToolVersions{Name: plugin.Name, Versions: version, Source: envVariableName})
		}
	}

	// Iterate from the current towards the root directory, ending with the user's home.
	for iterDir := range iterDirectories(conf, directory) {
		// Second: Resolve using the tool versions file
		filepath := path.Join(iterDir, conf.DefaultToolVersionsFilename)
		if _, err = os.Stat(filepath); err == nil {
			allVersions, err := toolversions.GetAllToolsAndVersions(filepath)
			if err != nil {
				return versions, err
			}
			for _, version := range allVersions {
				if _, isPluginResolved := resolvedToolVersions[version.Name]; !isPluginResolved {
					resolvedToolVersions[version.Name] = true
					finalVersions = append(finalVersions, ToolVersions{Name: version.Name, Versions: version.Versions, Source: conf.DefaultToolVersionsFilename, Directory: iterDir})
				}
			}
		}

		// Third: Resolve using legacy settings
		for _, plugin := range plugins {
			if _, isPluginResolved := resolvedToolVersions[plugin.Name]; !isPluginResolved {
				version, found, err := findLegacyVersionsInDir(conf, plugin, iterDir)
				if err != nil {
					return versions, err
				}
				if found {
					resolvedToolVersions[plugin.Name] = true
					finalVersions = append(finalVersions, version)
				}
			}
		}
	}
	return finalVersions, nil
}

// Version takes a plugin and a directory and resolves the tool to one or more
// versions. Only returns results for the provided plugin.
func Version(conf config.Config, plugin plugins.Plugin, directory string) (versions ToolVersions, found bool, err error) {
	version, envVariableName, found := findVersionsInEnv(plugin.Name)
	if found {
		return ToolVersions{Name: plugin.Name, Versions: version, Source: envVariableName}, true, nil
	}

	for iterDir := range iterDirectories(conf, directory) {
		versions, found, err = findVersionsInDir(conf, plugin, iterDir)
		if found || err != nil {
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
		if homeDir != "" {
			if !yield(homeDir) {
				return
			}
		}
	}
}

func findVersionsInDir(conf config.Config, plugin plugins.Plugin, directory string) (versions ToolVersions, found bool, err error) {
	filepath := path.Join(directory, conf.DefaultToolVersionsFilename)
	if _, err = os.Stat(filepath); err == nil {
		foundVersions, found, err := toolversions.FindToolVersions(filepath, plugin.Name)
		if err != nil {
			return versions, found, err
		}
		if found {
			return ToolVersions{Name: plugin.Name, Versions: foundVersions, Source: conf.DefaultToolVersionsFilename, Directory: directory}, found, err
		}
	}

	return findLegacyVersionsInDir(conf, plugin, directory)
}

func findLegacyVersionsInDir(conf config.Config, plugin plugins.Plugin, directory string) (versions ToolVersions, found bool, err error) {
	legacyFiles, err := conf.LegacyVersionFile()
	if err != nil {
		return versions, found, err
	}

	if legacyFiles {
		return findVersionsInLegacyFile(plugin, directory)
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
			return ToolVersions{Name: plugin.Name, Versions: versionsSlice, Source: filename, Directory: directory}, err == nil, err
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

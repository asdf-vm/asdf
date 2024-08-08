// Package resolve contains functions for resolving a tool version in a given
// directory. This is a core feature of asdf as asdf must be able to resolve a
// tool version in any directory if set.
package resolve

import (
	"os"
	"path"
	"strings"

	"asdf/config"
	"asdf/internal/toolversions"
	"asdf/plugins"
)

// ToolVersions represents a tool along with versions specified for it
type ToolVersions struct {
	Versions  []string
	Directory string
	Source    string
}

// Version takes a plugin and a directory and resolves the tool to one or more
// versions.
func Version(conf config.Config, plugin plugins.Plugin, directory string) (versions ToolVersions, found bool, err error) {
	version, envVariableName, found := findVersionsInEnv(plugin.Name)
	if found {
		return ToolVersions{Versions: version, Source: envVariableName}, true, nil
	}

	for !found {
		versions, found, err = findVersionsInDir(conf, plugin, directory)
		if err != nil {
			return versions, false, err
		}

		nextDir := path.Dir(directory)
		if nextDir == directory {
			break
		}
		directory = nextDir
	}

	return versions, found, err
}

func findVersionsInDir(conf config.Config, plugin plugins.Plugin, directory string) (versions ToolVersions, found bool, err error) {
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

	filepath := path.Join(directory, conf.DefaultToolVersionsFilename)

	if _, err = os.Stat(filepath); err == nil {
		versions, found, err := toolversions.FindToolVersions(filepath, plugin.Name)
		if found || err != nil {
			return ToolVersions{Versions: versions, Source: conf.DefaultToolVersionsFilename, Directory: directory}, found, err
		}
	}

	return versions, found, nil
}

// findVersionsInEnv returns the version from the environment if present
func findVersionsInEnv(pluginName string) ([]string, string, bool) {
	envVariableName := "ASDF_" + strings.ToUpper(pluginName) + "_VERSION"
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

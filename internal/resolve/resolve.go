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
	Name     string
	Versions []string
	Source   string
}

func findVersionsInDir(conf config.Config, plugin plugins.Plugin, directory string) (versions []string, found bool, err error) {
	filename := conf.DefaultToolVersionsFilename
	filepath := path.Join(directory, filename)

	if _, err = os.Stat(filepath); err == nil {
		versions, found, err := toolversions.FindToolVersions(filepath, plugin.Name)
		if found || err != nil {
			return versions, found, err
		}
	}

	return versions, found, nil
}

// findVersionsInEnv returns the version from the environment if present
func findVersionsInEnv(pluginName string) ([]string, bool) {
	envVariableName := "ASDF_" + strings.ToUpper(pluginName) + "_VERSION"
	versionString := os.Getenv(envVariableName)
	if versionString == "" {
		return []string{}, false
	}
	return parseVersion(versionString), true
}

// findVersionsInLegacyFile looks up a legacy version in the given directory if
// the specified plugin has a list-legacy-filenames callback script. If the
// callback script exists asdf will look for files with the given name in the
// current and extract the version from them.
func findVersionsInLegacyFile(plugin plugins.Plugin, directory string) (versions []string, found bool, err error) {
	var legacyFileNames []string

	legacyFileNames, err = plugin.LegacyFilenames()
	if err != nil {
		return []string{}, false, err
	}

	for _, filename := range legacyFileNames {
		filepath := path.Join(directory, filename)
		if _, err := os.Stat(filepath); err == nil {
			versions, err := plugin.ParseLegacyVersionFile(filepath)

			if len(versions) == 0 || (len(versions) == 1 && versions[0] == "") {
				return nil, false, nil
			}
			return versions, err == nil, err
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

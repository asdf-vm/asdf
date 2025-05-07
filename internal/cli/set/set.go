// Package set provides the 'asdf set' command
package set

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"slices"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/toolversions"
	"github.com/asdf-vm/asdf/internal/versions"
)

// Main function is the entrypoint for the 'asdf set' command
func Main(_ io.Writer, stderr io.Writer, args []string, home bool, parent bool, homeFunc func() (string, error)) error {
	if len(args) < 1 {
		return printError(stderr, "tool and version must be provided as arguments")
	}

	if len(args) < 2 {
		return printError(stderr, "version must be provided as an argument")
	}

	if home && parent {
		return printError(stderr, "home and parent flags cannot both be specified; must be one location or the other")
	}

	conf, err := config.LoadConfig()
	if err != nil {
		return printError(stderr, fmt.Sprintf("error loading config: %s", err))
	}

	resolvedVersions := []string{}
	plugin := plugins.New(conf, args[0])
	pluginAvailableVersions, err := plugin.GetAvailableVersions()
	if err != nil {
		return printError(stderr, fmt.Sprintf("error getting available plugin versions: %s", err))
	}

	for _, version := range args[1:] {
		parsedVersion := toolversions.ParseFromCliArg(version)
		if parsedVersion.Type == "latest" {
			resolvedVersion, err := versions.Latest(plugin, parsedVersion.Value)
			if err != nil {
				return fmt.Errorf("unable to resolve latest version for %s", plugin.Name)
			}
			resolvedVersions = append(resolvedVersions, resolvedVersion)
			continue
		}
		resolvedVersions = append(resolvedVersions, version)
	}

	for _, version := range resolvedVersions {
		if !slices.Contains(pluginAvailableVersions, version) {
			return printError(stderr, fmt.Sprintf("version %s is not available for plugin %s\n", version, plugin.Name))
		}
	}

	tv := toolversions.ToolVersions{Name: args[0], Versions: resolvedVersions}

	if home {
		homeDir, err := homeFunc()
		if err != nil {
			return err
		}

		filepath := filepath.Join(homeDir, conf.DefaultToolVersionsFilename)
		err = toolversions.WriteToolVersionsToFile(filepath, []toolversions.ToolVersions{tv})
		if err != nil {
			err = printError(stderr, fmt.Sprintf("error writing version file: %s", err))
		}
		return err
	}

	currentDir, err := os.Getwd()
	if err != nil {
		return printError(stderr, fmt.Sprintf("unable to get current directory: %s", err))
	}

	if parent {
		// locate file in parent dir and update it
		path, found := findVersionFileInParentDir(conf, currentDir)
		if !found {
			return printError(stderr, fmt.Sprintf("No %s version file found in parent directory", conf.DefaultToolVersionsFilename))
		}

		err = toolversions.WriteToolVersionsToFile(path, []toolversions.ToolVersions{tv})
		if err != nil {
			err = printError(stderr, fmt.Sprintf("error writing version file: %s", err))
		}
		return err
	}

	// Write new file in current dir
	filepath := filepath.Join(currentDir, conf.DefaultToolVersionsFilename)
	return toolversions.WriteToolVersionsToFile(filepath, []toolversions.ToolVersions{tv})
}

func printError(stderr io.Writer, msg string) error {
	fmt.Fprintf(stderr, "%s", msg)
	return errors.New(msg)
}

func findVersionFileInParentDir(conf config.Config, directory string) (string, bool) {
	directory = filepath.Dir(directory)

	for {
		path := filepath.Join(directory, conf.DefaultToolVersionsFilename)
		if _, err := os.Stat(path); err == nil {
			return path, true
		}

		if directory == "/" {
			return "", false
		}

		directory = filepath.Dir(directory)
	}
}

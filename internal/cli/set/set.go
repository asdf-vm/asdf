// Package set provides the 'asdf set' command
package set

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/installs"
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

	for _, version := range args[1:] {
		parsedVersion := toolversions.ParseFromCliArg(version)
		if parsedVersion.Type == "latest" {
			plugin := plugins.New(conf, args[0])
			resolvedVersion, err := versions.Latest(plugin, parsedVersion.Value, stderr)
			if err != nil {
				return fmt.Errorf("unable to resolve latest version for %s", plugin.Name)
			}
			resolvedVersions = append(resolvedVersions, resolvedVersion)
			continue
		}
		resolvedVersions = append(resolvedVersions, version)
	}

	tv := toolversions.ToolVersions{Name: args[0], Versions: resolvedVersions}

	plugin := plugins.New(conf, args[0])
	warnIfNotInstalled(stderr, conf, plugin, resolvedVersions)

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

// warnIfNotInstalled prints a warning to stderr for any version being set
// that is not currently installed for the plugin, so users are not left
// wondering why a shim later reports no version resolves. It only warns for
// concrete versions -- "system", "path:" and "ref:" versions have no
// meaningful installed state to check.
func warnIfNotInstalled(stderr io.Writer, conf config.Config, plugin plugins.Plugin, versions []string) {
	for _, version := range versions {
		parsedVersion := toolversions.Parse(version)
		if parsedVersion.Type != "version" {
			continue
		}

		if !installs.IsInstalled(conf, plugin, parsedVersion) {
			fmt.Fprintf(stderr, "warning: version %s of %s is not installed, run `asdf install %s %s`\n", parsedVersion.Value, plugin.Name, plugin.Name, parsedVersion.Value)
		}
	}
}

func printError(stderr io.Writer, msg string) error {
	if !strings.HasSuffix(msg, "\n") {
		msg += "\n"
	}
	fmt.Fprint(stderr, msg)
	return errors.New(strings.TrimSuffix(msg, "\n"))
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

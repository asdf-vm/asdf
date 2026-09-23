// Package installs contains tool installation logic. It is "dumb" when it comes
// to versions and treats versions as opaque strings. It cannot depend on the
// versions package because the versions package relies on this page.
package installs

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/data"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/toolversions"
)

// IncompleteMarkerPath returns the path to the incomplete marker file for a version
func IncompleteMarkerPath(conf config.Config, plugin plugins.Plugin, version toolversions.Version) string {
	formattedVersion := toolversions.FormatForFS(version)
	return filepath.Join(data.InstallLocksDirectory(conf.DataDir, plugin.Name), formattedVersion)
}

// Installed returns a slice of all installed versions for a given plugin
func Installed(conf config.Config, plugin plugins.Plugin) (versions []string, err error) {
	installDirectory := data.InstallDirectory(conf.DataDir, plugin.Name)
	files, err := os.ReadDir(installDirectory)
	if err != nil {
		if _, ok := err.(*fs.PathError); ok {
			return versions, nil
		}

		return versions, err
	}

	for _, file := range files {
		if !file.IsDir() {
			continue
		}

		displayVersion := toolversions.VersionStringFromFSFormat(file.Name())
		version := toolversions.Parse(displayVersion)
		_, statErr := os.Stat(IncompleteMarkerPath(conf, plugin, version))
		if statErr == nil {
			continue
		}
		if !errors.Is(statErr, fs.ErrNotExist) {
			err = fmt.Errorf("checking install marker for version %s: %w", displayVersion, statErr)
			continue
		}

		versions = append(versions, displayVersion)
	}

	return versions, err
}

// InstallPath returns the path to a tool installation
func InstallPath(conf config.Config, plugin plugins.Plugin, version toolversions.Version) string {
	if version.Type == "path" {
		return resolveUserPath(version.Value)
	}

	return filepath.Join(data.InstallDirectory(conf.DataDir, plugin.Name), toolversions.FormatForFS(version))
}

// resolveUserPath expands a leading `~/` to the current user's home directory.
// A `.tool-versions` file is read directly rather than by a shell, so nothing
// else expands the `~` in a `path:~/src/elixir` version. Any other string is
// returned unchanged.
func resolveUserPath(path string) string {
	if !strings.HasPrefix(path, "~/") {
		return path
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return path
	}

	return filepath.Join(homeDir, path[2:])
}

// DownloadPath returns the download path for a particular plugin and version
func DownloadPath(conf config.Config, plugin plugins.Plugin, version toolversions.Version) string {
	if version.Type == "path" {
		return ""
	}

	return filepath.Join(data.DownloadDirectory(conf.DataDir, plugin.Name), toolversions.FormatForFS(version))
}

// IsInstalled checks if a specific version of a tool is installed
func IsInstalled(conf config.Config, plugin plugins.Plugin, version toolversions.Version) bool {
	installDir := InstallPath(conf, plugin, version)

	_, err := os.Stat(installDir)
	if err != nil {
		return false
	}

	_, err = os.Stat(IncompleteMarkerPath(conf, plugin, version))
	if err == nil {
		return false
	}
	return errors.Is(err, fs.ErrNotExist)
}

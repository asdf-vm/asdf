// Package installs contains tool installation logic. It is "dumb" when it comes
// to versions and treats versions as opaque strings. It cannot depend on the
// versions package because the versions package relies on this page.
package installs

import (
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/data"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/toolversions"
)

const incompleteSuffix = ".incomplete"

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

		name := file.Name()
		// Skip incomplete installations left behind by interrupted installs
		if strings.HasSuffix(name, incompleteSuffix) {
			continue
		}

		versions = append(versions, toolversions.VersionStringFromFSFormat(name))
	}

	return versions, err
}

// InstallPath returns the path to a tool installation
func InstallPath(conf config.Config, plugin plugins.Plugin, version toolversions.Version) string {
	if version.Type == "path" {
		return version.Value
	}

	return filepath.Join(data.InstallDirectory(conf.DataDir, plugin.Name), toolversions.FormatForFS(version))
}

// DownloadPath returns the download path for a particular plugin and version
func DownloadPath(conf config.Config, plugin plugins.Plugin, version toolversions.Version) string {
	if version.Type == "path" {
		return ""
	}

	return filepath.Join(data.DownloadDirectory(conf.DataDir, plugin.Name), toolversions.FormatForFS(version))
}

// StagingPath returns the temporary staging path used during installation.
// Installations are first performed in this directory and then atomically
// renamed to the final InstallPath on success, so that interrupted installs
// never appear as valid installed versions.
func StagingPath(conf config.Config, plugin plugins.Plugin, version toolversions.Version) string {
	return InstallPath(conf, plugin, version) + incompleteSuffix
}

// CleanIncomplete removes any stale staging directories for a given plugin and
// version. It is safe to call even if no incomplete directory exists.
func CleanIncomplete(conf config.Config, plugin plugins.Plugin, version toolversions.Version) error {
	return os.RemoveAll(StagingPath(conf, plugin, version))
}

// IsInstalled checks if a specific version of a tool is installed
func IsInstalled(conf config.Config, plugin plugins.Plugin, version toolversions.Version) bool {
	installDir := InstallPath(conf, plugin, version)

	// Check if version already installed
	_, err := os.Stat(installDir)
	return !os.IsNotExist(err)
}

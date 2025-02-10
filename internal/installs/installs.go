// Package installs contains tool installation logic. It is "dumb" when it comes
// to versions and treats versions as opaque strings. It cannot depend on the
// versions package because the versions package relies on this page.
package installs

import (
	"errors"
	"io/fs"
	"os"
	"path"
	"path/filepath"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/data"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/toolversions"
)

// Installed returns a slice of all installed versions for a given plugin
func Installed(conf config.Config, plugin plugins.Plugin) (versions []string, err error) {
	installDirectory := data.InstallDirectory(conf.DataDir, plugin.Name)
	files, err := os.ReadDir(installDirectory)
	if err != nil {
		if isFileNotFoundError(err) {
			return nil, nil
		}

		return nil, err
	}

	for _, file := range files {
		IsDir, err := resolveIsDirectory(installDirectory, file)
		if err != nil {
			if isFileNotFoundError(err) {
				continue
			}

			return nil, err
		}

		if IsDir {
			versions = append(versions, file.Name())
		}
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

// IsInstalled checks if a specific version of a tool is installed
func IsInstalled(conf config.Config, plugin plugins.Plugin, version toolversions.Version) bool {
	installDir := InstallPath(conf, plugin, version)

	// Check if version already installed
	_, err := os.Stat(installDir)
	return !os.IsNotExist(err)
}

// isDirectory checks if a given file is a directory or a symbolic link to a directory.
func resolveIsDirectory(parent string, file os.DirEntry) (bool, error) {
	if file.IsDir() {
		return true, nil
	}

	// Check if file is a symbolic link (which is a directory)
	if file.Type()&os.ModeSymlink == 0 {
		return false, nil
	}

	// Resolve symbolic link to determine if it points to a directory
	linkTarget, err := os.Readlink(filepath.Join(parent, file.Name()))
	if err != nil {
		return false, err
	}

	// If the link target is relative, resolve it to an absolute path
	if !path.IsAbs(linkTarget) {
		linkTarget = filepath.Join(parent, linkTarget)
	}

	info, err := os.Stat(linkTarget)
	if err != nil {
		return false, err
	}

	return info.IsDir(), nil
}

func isFileNotFoundError(err error) bool {
	var ferr *fs.PathError
	return errors.As(err, &ferr) || errors.Is(err, fs.ErrNotExist)
}

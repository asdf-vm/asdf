// Package installtest provides functions used by various asdf tests for
// installing versions of tools. It provides a simplified version of the
// versions.InstallOneVersion function.
package installtest

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/toolversions"
)

const (
	dataDirInstalls  = "installs"
	dataDirDownloads = "downloads"
)

// InstallOneVersion is a simplified version of versions.InstallOneVersion
// function for use in Go tests.
func InstallOneVersion(conf config.Config, plugin plugins.Plugin, versionType, version string) error {
	var stdOut strings.Builder
	var stdErr strings.Builder

	err := plugin.Exists()
	if err != nil {
		return err
	}

	downloadDir := DownloadPath(conf, plugin, version)
	installDir := InstallPath(conf, plugin, version)
	stagingDir := installDir + ".incomplete"

	// Clean up any previous incomplete install
	os.RemoveAll(stagingDir)

	env := map[string]string{
		"ASDF_INSTALL_TYPE":    versionType,
		"ASDF_INSTALL_VERSION": version,
		"ASDF_INSTALL_PATH":    stagingDir,
		"ASDF_DOWNLOAD_PATH":   downloadDir,
		"ASDF_CONCURRENCY":     "1",
	}

	err = os.MkdirAll(downloadDir, 0o777)
	if err != nil {
		return fmt.Errorf("unable to create download dir: %w", err)
	}

	err = plugin.RunCallback("download", []string{}, env, &stdOut, &stdErr)
	if _, ok := err.(plugins.NoCallbackError); err != nil && !ok {
		return fmt.Errorf("failed to run download callback: %w", err)
	}

	err = os.MkdirAll(stagingDir, 0o777)
	if err != nil {
		return fmt.Errorf("unable to create staging install dir: %w", err)
	}

	err = plugin.RunCallback("install", []string{}, env, &stdOut, &stdErr)
	if err != nil {
		os.RemoveAll(stagingDir)
		return fmt.Errorf("failed to run install callback: %w", err)
	}

	err = os.Rename(stagingDir, installDir)
	if err != nil {
		os.RemoveAll(stagingDir)
		return fmt.Errorf("failed to move staging install to final path: %w", err)
	}

	return nil
}

// InstallPath returns the path to a tool installation
func InstallPath(conf config.Config, plugin plugins.Plugin, version string) string {
	return filepath.Join(pluginInstallPath(conf, plugin), formatVersionStringForFS(version))
}

// DownloadPath returns the download path for a particular plugin and version
func DownloadPath(conf config.Config, plugin plugins.Plugin, version string) string {
	return filepath.Join(conf.DataDir, dataDirDownloads, plugin.Name, formatVersionStringForFS(version))
}

func pluginInstallPath(conf config.Config, plugin plugins.Plugin) string {
	return filepath.Join(conf.DataDir, dataDirInstalls, plugin.Name)
}

func formatVersionStringForFS(version string) string {
	return toolversions.FormatForFS(toolversions.Parse(version))
}

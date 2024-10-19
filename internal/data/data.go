// Package data provides constants and functions pertaining to directories and
// files in the asdf data directory on disk, specified by the $ASDF_DATA_DIR
package data

import (
	"path/filepath"
)

const (
	dataDirDownloads = "downloads"
	dataDirInstalls  = "installs"
	dataDirPlugins   = "plugins"
)

// DownloadDirectory returns the directory a plugin will be placing
// downloads of version source code
func DownloadDirectory(dataDir, pluginName string) string {
	return filepath.Join(dataDir, dataDirDownloads, pluginName)
}

// InstallDirectory returns the path to a plugin directory
func InstallDirectory(dataDir, pluginName string) string {
	return filepath.Join(dataDir, dataDirInstalls, pluginName)
}

// PluginsDirectory returns the path to the plugins directory in the data dir
func PluginsDirectory(dataDir string) string {
	return filepath.Join(dataDir, dataDirPlugins)
}

// PluginDirectory returns the directory a plugin with a given name would be in
// if it were installed
func PluginDirectory(dataDir, pluginName string) string {
	return filepath.Join(dataDir, dataDirPlugins, pluginName)
}

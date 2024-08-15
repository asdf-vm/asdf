// Package versions handles all operations pertaining to specific versions.
// Install, uninstall, etc...
package versions

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"asdf/config"
	"asdf/hook"
	"asdf/plugins"
)

const (
	systemVersion           = "system"
	latestVersion           = "latest"
	uninstallableVersionMsg = "uninstallable version: system"
	dataDirDownloads        = "downloads"
	dataDirInstalls         = "installs"
)

// UninstallableVersion is an error returned if someone tries to install the
// system version.
type UninstallableVersion struct{}

func (e UninstallableVersion) Error() string {
	return fmt.Sprint(uninstallableVersionMsg)
}

// TODO: Implement these functions
//func InstallAll() {
//}

//func InstallOne() {
//}

// InstallOneVersion installs a specific version of a specific tool
func InstallOneVersion(conf config.Config, plugin plugins.Plugin, version string, _ bool, stdOut io.Writer, stdErr io.Writer) error {
	err := plugin.Exists()
	if err != nil {
		return err
	}

	if version == systemVersion {
		return UninstallableVersion{}
	}

	if version == latestVersion {
		// TODO: Implement this
		return errors.New("not implemented")
	}

	downloadDir := downloadPath(conf, plugin, version)
	installDir := installPath(conf, plugin, version)
	versionType, version := ParseString(version)

	// Check if version already installed
	if _, err = os.Stat(installDir); !os.IsNotExist(err) {
		return fmt.Errorf("version %s of %s is already installed", version, plugin.Name)
	}

	env := map[string]string{
		"ASDF_INSTALL_TYPE":    versionType,
		"ASDF_INSTALL_VERSION": version,
		"ASDF_INSTALL_PATH":    installDir,
		"ASDF_DOWNLOAD_PATH":   downloadDir,
	}

	err = os.MkdirAll(downloadDir, 0o777)
	if err != nil {
		return fmt.Errorf("unable to create download dir: %w", err)
	}

	err = hook.RunWithOutput(conf, fmt.Sprintf("pre_asdf_download_%s", plugin.Name), []string{version}, stdOut, stdErr)
	if err != nil {
		return fmt.Errorf("failed to run pre-download hook: %w", err)
	}

	err = plugin.RunCallback("download", []string{}, env, stdOut, stdErr)
	if _, ok := err.(plugins.NoCallbackError); err != nil && !ok {
		return fmt.Errorf("failed to run download callback: %w", err)
	}

	err = hook.RunWithOutput(conf, fmt.Sprintf("pre_asdf_install_%s", plugin.Name), []string{version}, stdOut, stdErr)
	if err != nil {
		return fmt.Errorf("failed to run pre-install hook: %w", err)
	}

	err = os.MkdirAll(installDir, 0o777)
	if err != nil {
		return fmt.Errorf("unable to create install dir: %w", err)
	}

	err = plugin.RunCallback("install", []string{}, env, stdOut, stdErr)
	if err != nil {
		return fmt.Errorf("failed to run install callback: %w", err)
	}

	err = hook.RunWithOutput(conf, fmt.Sprintf("post_asdf_install_%s", plugin.Name), []string{version}, stdOut, stdErr)
	if err != nil {
		return fmt.Errorf("failed to run post-install hook: %w", err)
	}
	return nil
}

func downloadPath(conf config.Config, plugin plugins.Plugin, version string) string {
	return filepath.Join(conf.DataDir, dataDirDownloads, plugin.Name, version)
}

func installPath(conf config.Config, plugin plugins.Plugin, version string) string {
	return filepath.Join(conf.DataDir, dataDirInstalls, plugin.Name, version)
}

// ParseString parses a version string into versionType and version components
func ParseString(version string) (string, string) {
	segments := strings.Split(version, ":")
	if len(segments) >= 1 && segments[0] == "ref" {
		return "ref", strings.Join(segments[1:], ":")
	}

	return "version", version
}

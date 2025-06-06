// Package versions handles all operations pertaining to specific versions.
// Install, uninstall, etc...
package versions

import (
	"errors"
	"fmt"
	"io"
	"os"
	"regexp"
	"strings"

	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/hook"
	"github.com/asdf-vm/asdf/internal/installs"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/resolve"
	"github.com/asdf-vm/asdf/internal/shims"
	"github.com/asdf-vm/asdf/internal/toolversions"
)

const (
	systemVersion           = "system"
	latestVersion           = "latest"
	latestFilterRegex       = "(?i)(^Available versions:|-src|-dev|-latest|-stm|[-\\.]rc|-milestone|-alpha|-beta|[-\\.]pre|-next|(a|b|c)[0-9]+|snapshot|master|main)"
	numericStartFilterRegex = "^\\s*[0-9]"
	noLatestVersionErrMsg   = "no latest version found"
)

// UninstallableVersionError is an error returned if someone tries to install the
// system version.
type UninstallableVersionError struct {
	toolName    string
	versionType string
}

func (e UninstallableVersionError) Error() string {
	return fmt.Sprintf("uninstallable version %s of %s", e.versionType, e.toolName)
}

// NoVersionSetError is returned whenever an operation that requires a version
// is not able to resolve one.
type NoVersionSetError struct {
	toolName string
}

func (e NoVersionSetError) Error() string {
	// Eventually switch this to a more friendly error message, BATS tests fail
	// with this improvement
	// return fmt.Sprintf("no version set for plugin %s", e.toolName)
	return "no version set"
}

// VersionAlreadyInstalledError is returned whenever a version is already
// installed.
type VersionAlreadyInstalledError struct {
	toolName string
	version  toolversions.Version
}

func (e VersionAlreadyInstalledError) Error() string {
	return fmt.Sprintf("version %s of %s is already installed", e.version.Value, e.toolName)
}

// InstallAll installs all specified versions of every tool for the current
// directory. Typically this will just be a single version, if not already
// installed, but it may be multiple versions if multiple versions for the tool
// are specified in the .tool-versions file.
func InstallAll(conf config.Config, dir string, stdOut io.Writer, stdErr io.Writer) (failures []error) {
	plugins, err := plugins.List(conf, false, false)
	if err != nil {
		return []error{fmt.Errorf("unable to list plugins: %w", err)}
	}

	// Ideally we should install these in the order they are specified in the
	// closest .tool-versions file, but for now that is too complicated to
	// implement.
	for _, plugin := range plugins {
		err := Install(conf, plugin, dir, stdOut, stdErr)
		if err != nil {
			failures = append(failures, err)
		}
	}

	return failures
}

// Install installs all specified versions of a tool for the current directory.
// Typically this will just be a single version, if not already installed, but
// it may be multiple versions if multiple versions for the tool are specified
// in the .tool-versions file.
func Install(conf config.Config, plugin plugins.Plugin, dir string, stdOut io.Writer, stdErr io.Writer) error {
	err := plugin.Exists()
	if err != nil {
		return err
	}

	versions, found, err := resolve.Version(conf, plugin, dir)
	if err != nil {
		return err
	}

	if !found || len(versions.Versions) == 0 {
		return NoVersionSetError{toolName: plugin.Name}
	}

	for _, version := range versions.Versions {
		iErr := InstallOneVersion(conf, plugin, version, false, stdOut, stdErr)
		var vaiErr VersionAlreadyInstalledError
		if errors.As(iErr, &vaiErr) {
			err = errors.Join(err, iErr)
		} else if iErr != nil {
			return iErr
		}
	}

	return err
}

// InstallVersion installs a version of a specific tool, the version may be an
// exact version, or it may be `latest` or `latest` a regex query in order to
// select the latest version matching the provided pattern.
func InstallVersion(conf config.Config, plugin plugins.Plugin, version toolversions.Version, stdOut io.Writer, stdErr io.Writer) error {
	err := plugin.Exists()
	if err != nil {
		return err
	}

	resolvedVersion := ""
	if version.Type == latestVersion {
		resolvedVersion, err = Latest(plugin, version.Value)
		if err != nil {
			return err
		}
	}

	return InstallOneVersion(conf, plugin, resolvedVersion, false, stdOut, stdErr)
}

// InstallOneVersion installs a specific version of a specific tool
func InstallOneVersion(conf config.Config, plugin plugins.Plugin, versionStr string, keepDownload bool, stdOut io.Writer, stdErr io.Writer) error {
	err := plugin.Exists()
	if err != nil {
		return err
	}

	if versionStr == systemVersion {
		return UninstallableVersionError{toolName: plugin.Name, versionType: systemVersion}
	}

	version := toolversions.Parse(versionStr)

	if version.Type == "path" {
		return UninstallableVersionError{toolName: plugin.Name, versionType: "path"}
	}
	downloadDir := installs.DownloadPath(conf, plugin, version)
	installDir := installs.InstallPath(conf, plugin, version)

	if installs.IsInstalled(conf, plugin, version) {
		return VersionAlreadyInstalledError{version: version, toolName: plugin.Name}
	}

	concurrency, _ := conf.Concurrency()
	env := map[string]string{
		"ASDF_INSTALL_TYPE":    version.Type,
		"ASDF_INSTALL_VERSION": version.Value,
		"ASDF_INSTALL_PATH":    installDir,
		"ASDF_DOWNLOAD_PATH":   downloadDir,
		"ASDF_CONCURRENCY":     concurrency,
	}

	err = os.MkdirAll(downloadDir, 0o777)
	if err != nil {
		return fmt.Errorf("unable to create download dir: %w", err)
	}

	err = hook.RunWithOutput(conf, fmt.Sprintf("pre_asdf_download_%s", plugin.Name), []string{version.Value}, stdOut, stdErr)
	if err != nil {
		return fmt.Errorf("failed to run pre-download hook: %w", err)
	}

	err = plugin.RunCallback("download", []string{}, env, stdOut, stdErr)
	if _, ok := err.(plugins.NoCallbackError); err != nil && !ok {
		return fmt.Errorf("failed to run download callback: %w", err)
	}

	err = hook.RunWithOutput(conf, fmt.Sprintf("pre_asdf_install_%s", plugin.Name), []string{version.Value}, stdOut, stdErr)
	if err != nil {
		return fmt.Errorf("failed to run pre-install hook: %w", err)
	}

	err = os.MkdirAll(installDir, 0o777)
	if err != nil {
		return fmt.Errorf("unable to create install dir: %w", err)
	}

	err = plugin.RunCallback("install", []string{}, env, stdOut, stdErr)
	if err != nil {
		if rmErr := os.RemoveAll(installDir); rmErr != nil {
			fmt.Fprintf(stdErr, "failed to clean up '%s' due to %s\n", installDir, rmErr)
		}
		return fmt.Errorf("failed to run install callback: %w", err)
	}

	// Reshim
	err = shims.GenerateAll(conf, stdOut, stdErr)
	if err != nil {
		return fmt.Errorf("unable to generate shims post-install: %w", err)
	}

	err = hook.RunWithOutput(conf, fmt.Sprintf("post_asdf_install_%s", plugin.Name), []string{version.Value}, stdOut, stdErr)
	if err != nil {
		return fmt.Errorf("failed to run post-install hook: %w", err)
	}

	// delete download dir
	keep, err := conf.AlwaysKeepDownload()
	if err != nil {
		return err
	}

	if keep || keepDownload {
		return nil
	}

	err = os.RemoveAll(downloadDir)
	if err != nil {
		return fmt.Errorf("failed to remove download dir: %w", err)
	}

	return nil
}

// Latest invokes the plugin's latest-stable callback if it exists and returns
// the version it returns. If the callback is missing it invokes the list-all
// callback and returns the last version matching the query, if a query is
// provided.
func Latest(plugin plugins.Plugin, query string) (version string, err error) {
	var stdOut strings.Builder
	var stdErr strings.Builder

	err = plugin.RunCallback("latest-stable", []string{query}, map[string]string{}, &stdOut, &stdErr)
	if err == nil {
		versions := parseVersions(stdOut.String())
		if len(versions) < 1 {
			return version, errors.New(noLatestVersionErrMsg)
		}
		return versions[len(versions)-1], nil
	}

	// Fallback to list-all if latest-stable fails
	if _, ok := err.(plugins.NoCallbackError); !ok {
		return version, err
	}

	allVersions, err := AllVersions(plugin)
	if err != nil {
		return version, err
	}

	versions := filterByRegex(allVersions, latestFilterRegex, false)

	// If no query specified by user default to selecting version with numeric start
	if query == "" {
		versions = filterByRegex(versions, numericStartFilterRegex, true)
	} else {
		versions = filterByExactMatch(versions, query)
	}

	if len(versions) < 1 {
		return version, errors.New(noLatestVersionErrMsg)
	}

	return versions[len(versions)-1], nil
}

// AllVersions returns a slice of all available versions for the tool managed by
// the given plugin by invoking the plugin's list-all callback
func AllVersions(plugin plugins.Plugin) (versions []string, err error) {
	var stdout strings.Builder
	var stderr strings.Builder

	err = plugin.RunCallback("list-all", []string{}, map[string]string{}, &stdout, &stderr)
	if err != nil {
		return versions, err
	}

	versions = parseVersions(stdout.String())

	return versions, err
}

// Uninstall uninstalls a specific tool version. It invokes pre and
// post-uninstall hooks if set, and runs the plugin's uninstall callback if
// defined.
func Uninstall(conf config.Config, plugin plugins.Plugin, rawVersion string, stdout, stderr io.Writer) error {
	version := toolversions.ParseFromCliArg(rawVersion)

	if version.Type == "latest" {
		return errors.New("'latest' is a special version value that cannot be used for uninstall command")
	}

	if !installs.IsInstalled(conf, plugin, version) {
		return errors.New("No such version")
	}

	err := hook.RunWithOutput(conf, fmt.Sprintf("pre_asdf_uninstall_%s", plugin.Name), []string{version.Value}, stdout, stderr)
	if err != nil {
		return err
	}

	// invoke uninstall callback if available
	installDir := installs.InstallPath(conf, plugin, version)
	env := map[string]string{
		"ASDF_INSTALL_TYPE":    version.Type,
		"ASDF_INSTALL_VERSION": version.Value,
		"ASDF_INSTALL_PATH":    installDir,
	}
	err = plugin.RunCallback("uninstall", []string{}, env, stdout, stderr)
	if _, ok := err.(plugins.NoCallbackError); !ok && err != nil {
		return err
	}

	err = os.RemoveAll(installDir)
	if err != nil {
		return err
	}

	err = hook.RunWithOutput(conf, fmt.Sprintf("post_asdf_uninstall_%s", plugin.Name), []string{version.Value}, stdout, stderr)
	if err != nil {
		return err
	}

	return nil
}

func filterByExactMatch(allVersions []string, pattern string) (versions []string) {
	for _, version := range allVersions {
		if strings.HasPrefix(version, pattern) {
			versions = append(versions, version)
		}
	}

	return versions
}

func filterByRegex(allVersions []string, pattern string, keepMatch bool) (versions []string) {
	regex, _ := regexp.Compile(pattern)
	for _, version := range allVersions {
		match := regex.MatchString(version)
		if match == keepMatch {
			versions = append(versions, version)
		}
	}

	return versions
}

// future refactoring opportunity: this function is an exact copy of
// resolve.parseVersion
func parseVersions(rawVersions string) []string {
	var versions []string
	for _, version := range strings.Split(rawVersions, " ") {
		version = strings.TrimSpace(version)
		if len(version) > 0 {
			versions = append(versions, version)
		}
	}
	return versions
}

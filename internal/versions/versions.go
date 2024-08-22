// Package versions handles all operations pertaining to specific versions.
// Install, uninstall, etc...
package versions

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"asdf/config"
	"asdf/hook"
	"asdf/internal/resolve"
	"asdf/plugins"
)

const (
	systemVersion           = "system"
	latestVersion           = "latest"
	uninstallableVersionMsg = "uninstallable version: system"
	dataDirDownloads        = "downloads"
	dataDirInstalls         = "installs"
	latestFilterRegex       = "(?i)(^Available versions:|-src|-dev|-latest|-stm|[-\\.]rc|-milestone|-alpha|-beta|[-\\.]pre|-next|(a|b|c)[0-9]+|snapshot|master)"
	noLatestVersionErrMsg   = "no latest version found"
)

// UninstallableVersionError is an error returned if someone tries to install the
// system version.
type UninstallableVersionError struct{}

func (e UninstallableVersionError) Error() string {
	return fmt.Sprint(uninstallableVersionMsg)
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
		err := InstallOneVersion(conf, plugin, version, stdOut, stdErr)
		if err != nil {
			return err
		}
	}

	return nil
}

// InstallVersion installs a version of a specific tool, the version may be an
// exact version, or it may be `latest` or `latest` a regex query in order to
// select the latest version matching the provided pattern.
func InstallVersion(conf config.Config, plugin plugins.Plugin, version string, pattern string, stdOut io.Writer, stdErr io.Writer) error {
	err := plugin.Exists()
	if err != nil {
		return err
	}

	if version == latestVersion {
		version, err = Latest(plugin, pattern)
		if err != nil {
			return err
		}
	}

	return InstallOneVersion(conf, plugin, version, stdOut, stdErr)
}

// InstallOneVersion installs a specific version of a specific tool
func InstallOneVersion(conf config.Config, plugin plugins.Plugin, version string, stdOut io.Writer, stdErr io.Writer) error {
	err := plugin.Exists()
	if err != nil {
		return err
	}

	if version == systemVersion {
		return UninstallableVersionError{}
	}

	downloadDir := downloadPath(conf, plugin, version)
	installDir := installPath(conf, plugin, version)
	versionType, version := ParseString(version)

	if Installed(conf, plugin, version) {
		return fmt.Errorf("version %s of %s is already installed", version, plugin.Name)
	}

	env := map[string]string{
		"ASDF_INSTALL_TYPE":    versionType,
		"ASDF_INSTALL_VERSION": version,
		"ASDF_INSTALL_PATH":    installDir,
		"ASDF_DOWNLOAD_PATH":   downloadDir,
		"ASDF_CONCURRENCY":     asdfConcurrency(conf),
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

func asdfConcurrency(conf config.Config) string {
	val, ok := os.LookupEnv("ASDF_CONCURRENCY")

	if !ok {
		val, err := conf.Concurrency()
		if err != nil {
			return "1"
		}

		return val
	}

	return val
}

// Installed checks if a specific version of a tool is installed
func Installed(conf config.Config, plugin plugins.Plugin, version string) bool {
	installDir := installPath(conf, plugin, version)

	// Check if version already installed
	_, err := os.Stat(installDir)
	return !os.IsNotExist(err)
}

// Latest invokes the plugin's latest-stable callback if it exists and returns
// the version it returns. If the callback is missing it invokes the list-all
// callback and returns the last version matching the query, if a query is
// provided.
func Latest(plugin plugins.Plugin, query string) (version string, err error) {
	var stdOut strings.Builder
	var stdErr strings.Builder

	err = plugin.RunCallback("latest-stable", []string{query}, map[string]string{}, &stdOut, &stdErr)
	if err != nil {
		if _, ok := err.(plugins.NoCallbackError); !ok {
			return version, err
		}

		allVersions, err := AllVersionsFiltered(plugin, query)
		if err != nil {
			return version, err
		}

		versions := filterOutByRegex(allVersions, latestFilterRegex)

		if len(versions) < 1 {
			return version, errors.New(noLatestVersionErrMsg)
		}

		return versions[len(versions)-1], nil
	}

	// parse stdOut and return version
	allVersions := parseVersions(stdOut.String())
	versions := filterOutByRegex(allVersions, latestFilterRegex)
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

// AllVersionsFiltered returns a list of existing versions that match a regex
// query provided by the user.
func AllVersionsFiltered(plugin plugins.Plugin, query string) (versions []string, err error) {
	all, err := AllVersions(plugin)
	if err != nil {
		return versions, err
	}

	return filterByExactMatch(all, query), err
}

func filterByExactMatch(allVersions []string, pattern string) (versions []string) {
	for _, version := range allVersions {
		if strings.HasPrefix(version, pattern) {
			versions = append(versions, version)
		}
	}

	return versions
}

func filterOutByRegex(allVersions []string, pattern string) (versions []string) {
	for _, version := range allVersions {
		match, _ := regexp.MatchString(pattern, version)
		if !match {
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

// ParseString parses a version string into versionType and version components
func ParseString(version string) (string, string) {
	segments := strings.Split(version, ":")
	if len(segments) >= 1 && segments[0] == "ref" {
		return "ref", strings.Join(segments[1:], ":")
	}

	return "version", version
}

func downloadPath(conf config.Config, plugin plugins.Plugin, version string) string {
	return filepath.Join(conf.DataDir, dataDirDownloads, plugin.Name, version)
}

func installPath(conf config.Config, plugin plugins.Plugin, version string) string {
	return filepath.Join(conf.DataDir, dataDirInstalls, plugin.Name, version)
}

// Package shims manages writing and parsing of asdf shim scripts.
package shims

import (
	"fmt"
	"io"
	"os"
	"path"
	"path/filepath"
	"strings"

	"asdf/config"
	"asdf/hook"
	"asdf/internal/toolversions"
	"asdf/internal/versions"
	"asdf/plugins"

	"golang.org/x/sys/unix"
)

const shimDirName = "shims"

// RemoveAll removes all shim scripts
func RemoveAll(conf config.Config) error {
	shimDir := filepath.Join(conf.DataDir, shimDirName)
	entries, err := os.ReadDir(shimDir)
	if err != nil {
		return err
	}

	for _, entry := range entries {
		os.RemoveAll(path.Join(shimDir, entry.Name()))
	}

	return nil
}

// GenerateAll generates shims for all executables of every version of every
// plugin.
func GenerateAll(conf config.Config, stdOut io.Writer, stdErr io.Writer) error {
	plugins, err := plugins.List(conf, false, false)
	if err != nil {
		return err
	}

	for _, plugin := range plugins {
		err := GenerateForPluginVersions(conf, plugin, stdOut, stdErr)
		if err != nil {
			return err
		}
	}

	return nil
}

// GenerateForPluginVersions generates all shims for all installed versions of
// a tool.
func GenerateForPluginVersions(conf config.Config, plugin plugins.Plugin, stdOut io.Writer, stdErr io.Writer) error {
	installedVersions, err := versions.Installed(conf, plugin)
	if err != nil {
		return err
	}

	for _, version := range installedVersions {
		err = hook.RunWithOutput(conf, fmt.Sprintf("pre_asdf_reshim_%s", plugin.Name), []string{version}, stdOut, stdErr)
		if err != nil {
			return err
		}

		GenerateForVersion(conf, plugin, version)

		err = hook.RunWithOutput(conf, fmt.Sprintf("post_asdf_reshim_%s", plugin.Name), []string{version}, stdOut, stdErr)
		if err != nil {
			return err
		}
	}
	return nil
}

// GenerateForVersion loops over all the executable files found for a tool and
// generates a shim for each one
func GenerateForVersion(conf config.Config, plugin plugins.Plugin, version string) error {
	executables, err := ToolExecutables(conf, plugin, version)
	if err != nil {
		return err
	}

	for _, executablePath := range executables {
		err := Write(conf, plugin, version, executablePath)
		if err != nil {
			return err
		}
	}

	return nil
}

// Write generates a shim script and writes it to disk
func Write(conf config.Config, plugin plugins.Plugin, version, executablePath string) error {
	err := ensureShimDirExists(conf)
	if err != nil {
		return err
	}

	shimName := filepath.Base(executablePath)
	shimPath := Path(conf, shimName)
	versions := []toolversions.ToolVersions{{Name: plugin.Name, Versions: []string{version}}}

	if _, err := os.Stat(shimPath); err == nil {
		contents, err := os.ReadFile(shimPath)
		if err != nil {
			return err
		}

		oldVersions := parse(string(contents))
		versions = toolversions.Unique(append(versions, oldVersions...))
	}

	return os.WriteFile(shimPath, []byte(encode(shimName, versions)), 0o777)
}

// Path returns the path for a shim script
func Path(conf config.Config, shimName string) string {
	return filepath.Join(conf.DataDir, shimDirName, shimName)
}

func ensureShimDirExists(conf config.Config) error {
	return os.MkdirAll(filepath.Join(conf.DataDir, shimDirName), 0o777)
}

// ToolExecutables returns a slice of executables for a given tool version
func ToolExecutables(conf config.Config, plugin plugins.Plugin, version string) (executables []string, err error) {
	dirs, err := ExecutableDirs(plugin)
	if err != nil {
		return executables, err
	}

	installPath := versions.InstallPath(conf, plugin, version)
	paths := dirsToPaths(dirs, installPath)

	for _, path := range paths {
		entries, err := os.ReadDir(path)
		if err != nil {
			return executables, err
		}
		for _, entry := range entries {
			// If entry is dir or cannot be executed by the current user ignore it
			filePath := filepath.Join(path, entry.Name())
			if entry.IsDir() || unix.Access(filePath, unix.X_OK) != nil {
				return executables, nil
			}

			executables = append(executables, filePath)
			return executables, nil
		}
		if err != nil {
			return executables, err
		}
	}
	return executables, err
}

// ExecutableDirs returns a slice of directory names that tool executables are
// contained in
func ExecutableDirs(plugin plugins.Plugin) ([]string, error) {
	var stdOut strings.Builder
	var stdErr strings.Builder

	err := plugin.RunCallback("list-bin-paths", []string{}, map[string]string{}, &stdOut, &stdErr)
	if err != nil {
		if _, ok := err.(plugins.NoCallbackError); ok {
			// assume all executables are located in /bin directory
			return []string{"bin"}, nil
		}

		return []string{}, err
	}

	// use output from list-bin-paths to determine locations for executables
	rawDirs := strings.Split(stdOut.String(), " ")
	var dirs []string

	for _, dir := range rawDirs {
		dirs = append(dirs, strings.TrimSpace(dir))
	}

	return dirs, nil
}

func parse(contents string) (versions []toolversions.ToolVersions) {
	lines := strings.Split(contents, "\n")

	for _, line := range lines {
		if strings.HasPrefix(line, "# asdf-plugin:") {
			segments := strings.Split(line, " ")
			// if doesn't have expected number of elements on line skip
			if len(segments) >= 4 {
				versions = append(versions, toolversions.ToolVersions{Name: segments[2], Versions: []string{segments[3]}})
			}
		}
	}
	return versions
}

func encode(shimName string, toolVersions []toolversions.ToolVersions) string {
	var content string

	content = "#!/usr/bin/env bash\n"

	// Add all asdf-plugin comments
	for _, tool := range toolVersions {
		for _, version := range tool.Versions {
			content += fmt.Sprintf("# asdf-plugin: %s %s\n", tool.Name, version)
		}
	}

	// Add call asdf exec to actually run real command
	content += fmt.Sprintf("exec asdf exec \"%s\" \"$@\"", shimName)

	return content
}

func dirsToPaths(dirs []string, root string) (paths []string) {
	for _, dir := range dirs {
		paths = append(paths, filepath.Join(root, dir))
	}

	return paths
}

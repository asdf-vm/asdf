// Package shims manages writing and parsing of asdf shim scripts.
package shims

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"asdf/config"
	"asdf/internal/toolversions"
	"asdf/internal/versions"
	"asdf/plugins"

	"golang.org/x/sys/unix"
)

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
	return filepath.Join(conf.DataDir, "shims", shimName)
}

func ensureShimDirExists(conf config.Config) error {
	return os.MkdirAll(filepath.Join(conf.DataDir, "shims"), 0o777)
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
		// Walk the directory and any sub directories
		err = filepath.Walk(path, func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}

			// If entry is dir or cannot be executed by the current user ignore it
			if info.IsDir() || unix.Access(path, unix.X_OK) != nil {
				return nil
			}

			executables = append(executables, path)
			return nil
		})
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

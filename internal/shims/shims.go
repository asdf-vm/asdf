// Package shims manages writing and parsing of asdf shim scripts.
package shims

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"slices"
	"strings"

	"asdf/internal/config"
	"asdf/internal/hook"
	"asdf/internal/installs"
	"asdf/internal/paths"
	"asdf/internal/plugins"
	"asdf/internal/resolve"
	"asdf/internal/toolversions"

	"golang.org/x/sys/unix"
)

const shimDirName = "shims"

// UnknownCommandError is an error returned when a shim is not found
type UnknownCommandError struct {
	shim string
}

func (e UnknownCommandError) Error() string {
	return fmt.Sprintf("unknown command: %s", e.shim)
}

// NoVersionSetError is returned when shim is found but no version matches
type NoVersionSetError struct {
	shim string
}

func (e NoVersionSetError) Error() string {
	return fmt.Sprintf("no versions set for %s", e.shim)
}

// NoExecutableForPluginError is returned when a compatible version is found
// but no executable matching the name is located.
type NoExecutableForPluginError struct {
	shim     string
	tools    []string
	versions []string
}

func (e NoExecutableForPluginError) Error() string {
	return fmt.Sprintf("No %s executable found for %s %s", e.shim, strings.Join(e.tools, ", "), strings.Join(e.versions, ", "))
}

// FindExecutable takes a shim name and a current directory and returns the path
// to the executable that the shim resolves to.
func FindExecutable(conf config.Config, shimName, currentDirectory string) (string, plugins.Plugin, string, bool, error) {
	shimPath := Path(conf, shimName)

	if _, err := os.Stat(shimPath); err != nil {
		return "", plugins.Plugin{}, "", false, UnknownCommandError{shim: shimName}
	}

	toolVersions, err := GetToolsAndVersionsFromShimFile(shimPath)
	if err != nil {
		return "", plugins.Plugin{}, "", false, err
	}

	existingPluginToolVersions := make(map[plugins.Plugin]resolve.ToolVersions)

	// loop over tools and check if the plugin for them still exists
	for _, shimToolVersion := range toolVersions {
		plugin := plugins.New(conf, shimToolVersion.Name)
		if plugin.Exists() == nil {

			versions, found, err := resolve.Version(conf, plugin, currentDirectory)
			if err != nil {
				return "", plugins.Plugin{}, "", false, nil
			}

			if found {
				tempVersions := toolversions.Intersect(shimToolVersion.Versions, versions.Versions)
				if slices.Contains(versions.Versions, "system") {
					tempVersions = append(tempVersions, "system")
				}

				parsedVersions := toolversions.ParseSlice(versions.Versions)
				for _, parsedVersion := range parsedVersions {
					if parsedVersion.Type == "path" {
						tempVersions = append(tempVersions, toolversions.Format(parsedVersion))
					}
				}

				versions.Versions = tempVersions
				existingPluginToolVersions[plugin] = versions
			}
		}
	}

	if len(existingPluginToolVersions) == 0 {
		return "", plugins.Plugin{}, "", false, NoVersionSetError{shim: shimName}
	}

	for plugin, toolVersions := range existingPluginToolVersions {
		for _, version := range toolVersions.Versions {
			parsedVersion := toolversions.Parse(version)
			if parsedVersion.Type == "system" {
				if executablePath, found := SystemExecutableOnPath(conf, shimName); found {
					return executablePath, plugin, version, true, nil
				}

				break
			}

			if parsedVersion.Type == "path" {
				executablePath, err := GetExecutablePath(conf, plugin, shimName, parsedVersion)
				if err == nil {
					return executablePath, plugin, version, true, nil
				}

				break
			}

			executablePath, err := GetExecutablePath(conf, plugin, shimName, parsedVersion)
			if err == nil {
				return executablePath, plugin, version, true, nil
			}
		}
	}

	tools := []string{}
	versions := []string{}
	for plugin := range existingPluginToolVersions {
		tools = append(tools, plugin.Name)
		versions = append(versions, existingPluginToolVersions[plugin].Versions...)
	}

	return "", plugins.Plugin{}, "", false, NoExecutableForPluginError{shim: shimName, tools: tools, versions: versions}
}

// SystemExecutableOnPath returns the path to the system executable if found,
// removes asdf shim directory from search
func SystemExecutableOnPath(conf config.Config, executableName string) (string, bool) {
	currentPath := os.Getenv("PATH")
	executablePath, err := ExecutableOnPath(paths.RemoveFromPath(currentPath, Directory(conf)), executableName)
	return executablePath, err == nil
}

// ExecutableOnPath returns the path to an executable if one is found on the
// provided paths. `path` must be in the same format as the `PATH` environment
// variable.
func ExecutableOnPath(path, command string) (string, error) {
	currentPath := os.Getenv("PATH")
	defer os.Setenv("PATH", currentPath)
	os.Setenv("PATH", path)
	return exec.LookPath(command)
}

// GetExecutablePath returns the path of the executable
func GetExecutablePath(conf config.Config, plugin plugins.Plugin, shimName string, version toolversions.Version) (string, error) {
	executables, err := ToolExecutables(conf, plugin, version)
	if err != nil {
		return "", err
	}

	executable := ""

	for _, executablePath := range executables {
		if filepath.Base(executablePath) == shimName {
			executable = executablePath
		}
	}

	path, err := getCustomExecutablePath(conf, plugin, shimName, version, executable)
	if err == nil {
		return path, err
	}

	if executable != "" {
		return executable, nil
	}

	return "", fmt.Errorf("executable not found")
}

// GetToolsAndVersionsFromShimFile takes a file path and parses out the tools
// and versions present in it and returns them as a slice containing info in
// ToolVersions structs.
func GetToolsAndVersionsFromShimFile(shimPath string) (versions []toolversions.ToolVersions, err error) {
	contents, err := os.ReadFile(shimPath)
	if err != nil {
		return versions, err
	}

	versions = parse(string(contents))
	versions = toolversions.Unique(versions)

	return versions, err
}

func getCustomExecutablePath(conf config.Config, plugin plugins.Plugin, shimName string, version toolversions.Version, executablePath string) (string, error) {
	var stdOut strings.Builder
	var stdErr strings.Builder

	installPath := installs.InstallPath(conf, plugin, version)
	env := map[string]string{"ASDF_INSTALL_TYPE": "version"}

	relativePath, err := filepath.Rel(installPath, executablePath)
	if err != nil {
		return "", err
	}

	err = plugin.RunCallback("exec-path", []string{installPath, shimName, relativePath}, env, &stdOut, &stdErr)
	if err != nil {
		return "", err
	}

	return filepath.Join(installPath, strings.TrimSpace(stdOut.String())), err
}

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
	installedVersions, err := installs.Installed(conf, plugin)
	if err != nil {
		return err
	}

	for _, version := range installedVersions {
		parsedVersion := toolversions.Parse(version)
		GenerateForVersion(conf, plugin, parsedVersion, stdOut, stdErr)
	}
	return nil
}

// GenerateForVersion loops over all the executable files found for a tool and
// generates a shim for each one
func GenerateForVersion(conf config.Config, plugin plugins.Plugin, version toolversions.Version, stdOut io.Writer, stdErr io.Writer) error {
	err := hook.RunWithOutput(conf, fmt.Sprintf("pre_asdf_reshim_%s", plugin.Name), []string{toolversions.Format(version)}, stdOut, stdErr)
	if err != nil {
		return err
	}
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

	err = hook.RunWithOutput(conf, fmt.Sprintf("post_asdf_reshim_%s", plugin.Name), []string{toolversions.Format(version)}, stdOut, stdErr)
	if err != nil {
		return err
	}
	return nil
}

// Write generates a shim script and writes it to disk
func Write(conf config.Config, plugin plugins.Plugin, version toolversions.Version, executablePath string) error {
	err := ensureShimDirExists(conf)
	if err != nil {
		return err
	}

	shimName := filepath.Base(executablePath)
	shimPath := Path(conf, shimName)
	versions := []toolversions.ToolVersions{{Name: plugin.Name, Versions: []string{toolversions.Format(version)}}}

	if _, err := os.Stat(shimPath); err == nil {
		oldVersions, err := GetToolsAndVersionsFromShimFile(shimPath)
		if err != nil {
			return err
		}
		versions = toolversions.Unique(append(versions, oldVersions...))
	}

	return os.WriteFile(shimPath, []byte(encode(shimName, versions)), 0o777)
}

// Path returns the path for a shim script
func Path(conf config.Config, shimName string) string {
	return filepath.Join(conf.DataDir, shimDirName, shimName)
}

// Directory returns the path to the shims directory for the current
// configuration.
func Directory(conf config.Config) string {
	return filepath.Join(conf.DataDir, shimDirName)
}

func ensureShimDirExists(conf config.Config) error {
	return os.MkdirAll(filepath.Join(conf.DataDir, shimDirName), 0o777)
}

// ToolExecutables returns a slice of executables for a given tool version
func ToolExecutables(conf config.Config, plugin plugins.Plugin, version toolversions.Version) (executables []string, err error) {
	paths, err := ExecutablePaths(conf, plugin, version)
	if err != nil {
		return []string{}, err
	}

	for _, path := range paths {
		entries, err := os.ReadDir(path)
		if _, ok := err.(*os.PathError); err != nil && !ok {
			return executables, err
		}

		for _, entry := range entries {
			// If entry is dir or cannot be executed by the current user ignore it
			filePath := filepath.Join(path, entry.Name())
			if entry.IsDir() || unix.Access(filePath, unix.X_OK) != nil {
				continue
			}

			executables = append(executables, filePath)
		}
	}
	return executables, err
}

// ExecutablePaths returns a slice of absolute directory paths that tool
// executables are contained in.
func ExecutablePaths(conf config.Config, plugin plugins.Plugin, version toolversions.Version) ([]string, error) {
	dirs, err := ExecutableDirs(plugin)
	if err != nil {
		return []string{}, err
	}

	installPath := installs.InstallPath(conf, plugin, version)
	return dirsToPaths(dirs, installPath), nil
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

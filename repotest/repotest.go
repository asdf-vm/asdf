// Package repotest contains various test helpers for tests that work with code
// relying on plugin Git repos and the asdf plugin index
//
// Three main actions:
//
// * Install plugin index repo into asdf (index contains records that point to
// local plugins defined by this package)
// * Install plugin into asdf data dir
// * Create local plugin repo that can be cloned into asdf
package repotest

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	cp "github.com/otiai10/copy"
)

const fixturesDir = "fixtures"

// Setup copies all files into place and initializes all repos for any Go test
// that needs either plugin repos or the plugin index repo.
func Setup(asdfDataDir string) error {
	if err := InstallPluginIndex(asdfDataDir); err != nil {
		return err
	}

	return nil
}

// GeneratePlugin copies in the specified plugin fixture into a test directory
// and initializes a Git repo for it so it can be installed by asdf.
func GeneratePlugin(fixtureName, asdfDataDir, pluginName string) (string, error) {
	root, err := getModuleRoot()
	if err != nil {
		return "", err
	}

	fixturesDir := filepath.Join(asdfDataDir, fixturesDir)
	return generatePluginInDir(root, fixtureName, fixturesDir, pluginName)
}

// InstallPluginIndex generates and installs a plugin index Git repo inside of
// the provided asdf data directory.
func InstallPluginIndex(asdfDataDir string) error {
	root, err := getModuleRoot()
	if err != nil {
		return err
	}

	// Copy in plugin index
	source := filepath.Join(root, "test/fixtures/dummy_plugins_repo")
	return cp.Copy(source, filepath.Join(asdfDataDir, "plugin-index"))
}

// GeneratePluginIndex generates a mock plugin index Git repo inside the given
// directory.
func GeneratePluginIndex(asdfDataDir string) (string, error) {
	root, err := getModuleRoot()
	if err != nil {
		return "", err
	}

	// Copy in plugin index
	source := filepath.Join(root, "test/fixtures/dummy_plugins_repo")
	destination := filepath.Join(asdfDataDir, fixturesDir, "plugin-index")
	err = cp.Copy(source, destination)
	if err != nil {
		return destination, fmt.Errorf("unable to copy in plugin index: %w", err)
	}

	// Generate git repo for plugin
	return createGitRepo(destination)
}

func generatePluginInDir(root, fixtureName, outputDir, pluginName string) (string, error) {
	// Copy in plugin files into output dir
	pluginPath, err := copyInPlugin(root, fixtureName, outputDir, pluginName)
	if err != nil {
		return pluginPath, fmt.Errorf("unable to copy in plugin files: %w", err)
	}

	// Generate git repo for plugin
	return createGitRepo(pluginPath)
}

func getModuleRoot() (string, error) {
	cwd, err := os.Getwd()
	if err != nil {
		return "", fmt.Errorf("unable to get current working directory: %w", err)
	}

	root := findModuleRoot(cwd)
	return root, nil
}

func createGitRepo(location string) (string, error) {
	// Definitely some opportunities to refactor here. This code might be
	// simplified by switching to the Go git library
	err := runCmd("git", "-C", location, "init", "-q")
	if err != nil {
		return location, err
	}

	err = runCmd("git", "-C", location, "config", "user.name", "\"Test\"")
	if err != nil {
		return location, err
	}

	err = runCmd("git", "-C", location, "config", "user.email", "\"test@example.com\"")
	if err != nil {
		return location, err
	}

	err = runCmd("git", "-C", location, "add", "-A")
	if err != nil {
		return location, err
	}

	err = runCmd("git", "-C", location, "commit", "-q", "-m", "init repo")
	if err != nil {
		return location, err
	}

	err = runCmd("touch", filepath.Join(location, "README.md"))
	if err != nil {
		return location, err
	}

	err = runCmd("git", "-C", location, "add", "-A")
	if err != nil {
		return location, err
	}

	err = runCmd("git", "-C", location, "commit", "-q", "-m", "add readme")
	if err != nil {
		return location, err
	}

	// kind of ugly but I want a remote with a valid path so I use the same
	// location as the remote. Probably should refactor
	err = runCmd("git", "-C", location, "remote", "add", "origin", location)
	if err != nil {
		return location, err
	}

	return location, err
}

func copyInPlugin(root, name, destination, newName string) (string, error) {
	source := filepath.Join(root, "test/fixtures/", name)
	dest := filepath.Join(destination, newName)
	return dest, cp.Copy(source, dest)
}

// Taken from https://github.com/golang/go/blob/9e3b1d53a012e98cfd02de2de8b1bd53522464d4/src/cmd/go/internal/modload/init.go#L1504C1-L1522C2 because that function is in an internal module
// and I can't rely on it.
func findModuleRoot(dir string) (roots string) {
	if dir == "" {
		panic("dir not set")
	}
	dir = filepath.Clean(dir)

	// Look for enclosing go.mod.
	for {
		if fi, err := os.Stat(filepath.Join(dir, "go.mod")); err == nil && !fi.IsDir() {
			return dir
		}
		d := filepath.Dir(dir)
		if d == dir {
			break
		}
		dir = d
	}
	return ""
}

// helper function to make running commands easier
func runCmd(cmdName string, args ...string) error {
	cmd := exec.Command(cmdName, args...)

	// Capture stdout and stderr
	var stdout strings.Builder
	var stderr strings.Builder
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err != nil {
		// If command fails print both stderr and stdout
		fmt.Println("stdout:", stdout.String())
		fmt.Println("stderr:", stderr.String())
		return err
	}

	return nil
}

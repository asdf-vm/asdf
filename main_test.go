package main

import (
	"fmt"
	"os/exec"
	"strings"
	"testing"
)

// Basic integration tests using the legacy BATS test scripts. This ensures the
// new Golang implementation matches the existing Bash implementation.

func TestBatsTests(t *testing.T) {
	dir := t.TempDir()

	// Build asdf and put in temp directory
	buildAsdf(t, dir)

	// Run tests with the asdf binary in the temp directory

	// Uncomment these as they are implemented
	//t.Run("current_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "current_command.bats")
	//})

	//t.Run("help_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "help_command.bats")
	//})

	t.Run("info_command", func(t *testing.T) {
		runBatsFile(t, dir, "info_command.bats")
	})

	//t.Run("install_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "install_command.bats")
	//})

	t.Run("latest_command", func(t *testing.T) {
		runBatsFile(t, dir, "latest_command.bats")
	})

	//t.Run("list_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "list_command.bats")
	//})

	t.Run("plugin_add_command", func(t *testing.T) {
		runBatsFile(t, dir, "plugin_add_command.bats")
	})

	//t.Run("plugin_extension_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "plugin_extension_command.bats")
	//})

	//t.Run("plugin_list_all_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "plugin_list_all_command.bats")
	//})

	//t.Run("plugin_remove_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "plugin_remove_command.bats")
	//})

	//t.Run("plugin_test_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "plugin_test_command.bats")
	//})

	//t.Run("plugin_update_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "plugin_update_command.bats")
	//})

	//t.Run("remove_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "remove_command.bats")
	//})

	//t.Run("reshim_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "reshim_command.bats")
	//})

	//t.Run("shim_env_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "shim_env_command.bats")
	//})

	//t.Run("shim_exec", func(t *testing.T) {
	//  runBatsFile(t, dir, "shim_exec.bats")
	//})

	//t.Run("shim_versions_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "shim_versions_command.bats")
	//})

	//t.Run("uninstall_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "uninstall_command.bats")
	//})

	//t.Run("update_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "update_command.bats")
	//})

	//t.Run("version_commands", func(t *testing.T) {
	//  runBatsFile(t, dir, "version_commands.bats")
	//})

	//t.Run("where_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "where_command.bats")
	//})

	//t.Run("which_command", func(t *testing.T) {
	//  runBatsFile(t, dir, "which_command.bats")
	//})
}

func runBatsFile(t *testing.T, dir, filename string) {
	t.Helper()

	cmd := exec.Command("bats", "--verbose-run", fmt.Sprintf("test/%s", filename))

	// Capture stdout and stderr
	var stdout strings.Builder
	var stderr strings.Builder
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	// Add dir to asdf test variables
	asdfTestHome := fmt.Sprintf("BASE_DIR=%s", dir)
	asdfBinPath := fmt.Sprintf("ASDF_BIN=%s", dir)
	cmd.Env = []string{asdfBinPath, asdfTestHome}

	err := cmd.Run()
	if err != nil {
		// If command fails print both stderr and stdout
		fmt.Println("stdout:", stdout.String())
		fmt.Println("stderr:", stderr.String())
		t.Fatal("bats command failed to run test file successfully")

		return
	}
}

func buildAsdf(t *testing.T, dir string) {
	cmd := exec.Command("go", "build", "-o", dir)

	err := cmd.Run()
	if err != nil {
		t.Fatal("Failed to build asdf")
	}
}

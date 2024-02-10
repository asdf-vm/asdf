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
	t.Run("current_command", func(t *testing.T) {
		run_bats_file(t, "current_command.bats")
	})

	t.Run("get_asdf_config_value", func(t *testing.T) {
		run_bats_file(t, "get_asdf_config_value.bats")
	})

	t.Run("help_command", func(t *testing.T) {
		run_bats_file(t, "help_command.bats")
	})

	t.Run("info_command", func(t *testing.T) {
		run_bats_file(t, "info_command.bats")
	})

	t.Run("install_command", func(t *testing.T) {
		run_bats_file(t, "install_command.bats")
	})

	t.Run("latest_command", func(t *testing.T) {
		run_bats_file(t, "latest_command.bats")
	})

	t.Run("list_command", func(t *testing.T) {
		run_bats_file(t, "list_command.bats")
	})

	t.Run("plugin_extension_command", func(t *testing.T) {
		run_bats_file(t, "plugin_extension_command.bats")
	})

	t.Run("plugin_list_all_command", func(t *testing.T) {
		run_bats_file(t, "plugin_list_all_command.bats")
	})

	t.Run("plugin_remove_command", func(t *testing.T) {
		run_bats_file(t, "plugin_remove_command.bats")
	})

	t.Run("plugin_test_command", func(t *testing.T) {
		run_bats_file(t, "plugin_test_command.bats")
	})

	t.Run("plugin_update_command", func(t *testing.T) {
		run_bats_file(t, "plugin_update_command.bats")
	})

	t.Run("remove_command", func(t *testing.T) {
		run_bats_file(t, "remove_command.bats")
	})

	t.Run("reshim_command", func(t *testing.T) {
		run_bats_file(t, "reshim_command.bats")
	})

	t.Run("reshim_command", func(t *testing.T) {
		run_bats_file(t, "reshim_command.bats")
	})

	t.Run("shim_env_command", func(t *testing.T) {
		run_bats_file(t, "shim_env_command.bats")
	})

	t.Run("shim_exec", func(t *testing.T) {
		run_bats_file(t, "shim_exec.bats")
	})

	t.Run("shim_versions_command", func(t *testing.T) {
		run_bats_file(t, "shim_versions_command.bats")
	})

	t.Run("shim_versions_command", func(t *testing.T) {
		run_bats_file(t, "shim_versions_command.bats")
	})

	t.Run("uninstall_command", func(t *testing.T) {
		run_bats_file(t, "uninstall_command.bats")
	})

	t.Run("update_command", func(t *testing.T) {
		run_bats_file(t, "update_command.bats")
	})

	t.Run("version_commands", func(t *testing.T) {
		run_bats_file(t, "version_commands.bats")
	})

	t.Run("where_command", func(t *testing.T) {
		run_bats_file(t, "where_command.bats")
	})

	t.Run("which_command", func(t *testing.T) {
		run_bats_file(t, "which_command.bats")
	})
}

func run_bats_file(t *testing.T, filename string) {
	t.Helper()

	cmd := exec.Command("bats", filename)

	// Capture stdout and stderr
	var stdout strings.Builder
	var stderr strings.Builder
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err != nil {
		// If command fails print both stderr and stdout
		fmt.Println("stderr:", stderr.String())
		fmt.Println("stdout:", stdout.String())
		t.Fatal("bats command failed to run test file successfully")

		return
	}
}

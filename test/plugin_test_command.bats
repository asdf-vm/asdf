#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_mock_plugin_repo "dummy"
}

teardown() {
  clean_asdf_dir
}

@test "plugin_test_command with no URL specified prints an error" {
  run asdf plugin-test "elixir"
  [ "$status" -eq 1 ]
  [ "$output" = "FAILED: please provide a plugin name and url" ]
}

@test "plugin_test_command with no name or URL specified prints an error" {
  run asdf plugin-test
  [ "$status" -eq 1 ]
  [ "$output" = "FAILED: please provide a plugin name and url" ]
}

@test "plugin_test_command works with no options provided" {
  run asdf plugin-test dummy "${BASE_DIR}/repo-dummy"
  [ "$status" -eq 0 ]
}

@test "plugin_test_command works with all options provided" {
  run asdf plugin-test dummy "${BASE_DIR}/repo-dummy" --asdf-tool-version 1.0.0 --asdf-plugin-gitref master
  [ "$status" -eq 0 ]
}

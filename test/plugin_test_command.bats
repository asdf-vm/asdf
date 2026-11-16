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
  run asdf plugin test "elixir"
  [ "$status" -eq 1 ]
  [ "$output" = "FAILED: please provide a plugin name and url" ]
}

@test "plugin_test_command with no name or URL specified prints an error" {
  run asdf plugin test
  [ "$status" -eq 1 ]
  [ "$output" = "FAILED: please provide a plugin name and url" ]
}

@test "plugin_test_command works with no options provided" {
  run asdf plugin test dummy "${BASE_DIR}/repo-dummy"
  [ "$status" -eq 0 ]
}

@test "plugin_test_command works with all options provided" {
  run asdf plugin test dummy "${BASE_DIR}/repo-dummy" --asdf-tool-version 1.0.0 --asdf-plugin-gitref master
  [ "$status" -eq 0 ]
}

@test "plugin_test_command resolves latest version when --asdf-tool-version latest is provided" {
  run asdf plugin test dummy "${BASE_DIR}/repo-dummy" --asdf-tool-version latest
  [ "$status" -eq 0 ]
}

@test "plugin_test_command runs the test command with the installed version" {
  run asdf plugin test dummy "${BASE_DIR}/repo-dummy" --asdf-tool-version 1.0.0 dummy first second
  [ "$status" -eq 0 ]
  [[ "$output" == *"This is Dummy 1.0.0! second first"* ]]
}

@test "plugin_test_command runs a single argument as a command line" {
  run asdf plugin test dummy "${BASE_DIR}/repo-dummy" --asdf-tool-version 1.0.0 "dummy first second"
  [ "$status" -eq 0 ]
  [[ "$output" == *"This is Dummy 1.0.0! second first"* ]]
}

@test "plugin_test_command fails when the test command fails" {
  run asdf plugin test dummy "${BASE_DIR}/repo-dummy" --asdf-tool-version 1.0.0 false
  [ "$status" -eq 1 ]
  [[ "$output" == *"FAILED: false failed: exit status 1"* ]]
}

@test "plugin_test_command fails when the test command is not found" {
  run asdf plugin test dummy "${BASE_DIR}/repo-dummy" --asdf-tool-version 1.0.0 not-a-command
  [ "$status" -eq 1 ]
  [[ "$output" == *"FAILED: not-a-command failed"* ]]
}

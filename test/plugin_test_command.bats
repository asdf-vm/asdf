#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
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

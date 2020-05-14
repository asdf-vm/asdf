#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
}

teardown() {
  clean_asdf_dir
}

@test "latest_command shows latest stable version" {
  run asdf latest dummy
  [ "$(echo "2.0")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "latest_command with version shows latest stable version that matches the given string" {
  run asdf latest dummy 1
  [ "$(echo "1.1")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "latest_command with an invalid version should return an error" {
  run asdf latest dummy 3
  [ "$(echo "No compatible versions available (dummy 3)")" == "$output" ]
  [ "$status" -eq 1 ]
}

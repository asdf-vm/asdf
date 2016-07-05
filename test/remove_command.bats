#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/plugin-remove.sh

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "plugin_remove_command removes a plugin" {
  install_dummy_plugin

  run plugin_remove_command "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "plugin_remove_command should exit with 1 when not passed any arguments" {
  run plugin_remove_command
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin" ]
}

@test "plugin_remove_command should exit with 1 when passed invalid plugin name" {
  run plugin_remove_command "does-not-exist"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin" ]
}

#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/plugin-add.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/plugin-list.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/plugin-test.sh

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "plugin_test_command with no URL specified prints an error" {
  run plugin_test_command "elixir"
  [ "$status" -eq 1 ]
  [ "$output" = "FAILED: please provide a plugin name and url" ]
}

@test "plugin_test_command with no name or URL specified prints an error" {
  run plugin_test_command
  [ "$status" -eq 1 ]
  [ "$output" = "FAILED: please provide a plugin name and url" ]
}

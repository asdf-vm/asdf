#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/plugin-add.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/plugin-list.sh

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "plugin_add command with no URL specified adds a plugin using repo" {
  run plugin_add_command "elixir"
  [ "$status" -eq 0 ]

  run plugin_list_command
  [ "$output" = "elixir" ]
}

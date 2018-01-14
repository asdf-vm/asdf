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
  # whitespace between 'elixir' and url is from printf %-15s %s format
  [ "$output" = "elixir          https://github.com/asdf-vm/asdf-elixir" ]
}

@test "plugin_add command with no URL specified fails if the plugin doesn't exist" {
  run plugin_add_command "does-not-exist"
  [ "$status" -eq 1 ]
  echo "$output" | grep "plugin does-not-exist not found in repository"
}

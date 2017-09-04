#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/plugin-list-all.sh

setup() {
  setup_asdf_dir
  setup_repo
}

teardown() {
  clean_asdf_dir
}

@test "plugin_list_all list all plugins in the repository" {
  run plugin_list_all_command
  local expected="bar
foo"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

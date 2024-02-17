#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "plugin_list_command prints help if --help is passed" {
  run asdf plugin list --help
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == 'usage: '* ]]
}

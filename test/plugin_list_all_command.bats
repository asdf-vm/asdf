#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  setup_repo
  install_dummy_plugin
}

teardown() {
  clean_asdf_dir
}

@test "plugin_list_all list all plugins in the repository" {
  run asdf plugin-list-all
  local expected="bar              http://example.com/bar
dummy           *http://example.com/dummy
foo              http://example.com/foo"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "plugin_add command with no URL specified adds a plugin using repo" {
  run asdf plugin-add "elixir"
  [ "$status" -eq 0 ]

  run asdf plugin-list
  # whitespace between 'elixir' and url is from printf %-15s %s format
  [ "$output" = "elixir" ]
}

@test "plugin_add command with no URL specified fails if the plugin doesn't exist" {
  run asdf plugin-add "does-not-exist"
  [ "$status" -eq 1 ]
  echo "$output" | grep "plugin does-not-exist not found in repository"
}

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

@test "plugin_list_all should sync repo when check_duration set to 0" {
  echo 'plugin_repository_last_check_duration = 0' > $HOME/.asdfrc
  run asdf plugin-list-all
  local expected_plugin_repo_sync="updating plugin repository..."
  local expected_plugins_list="\
bar                           http://example.com/bar
dummy                        *http://example.com/dummy
foo                           http://example.com/foo"

  [ "$status" -eq 0 ]
  [[ "$output" =~ "$expected_plugin_repo_sync" ]]
  [[ "$output" =~ "$expected_plugins_list" ]]
}

@test "plugin_list_all no immediate repo sync expected because check_duration is greater than 0" {
  echo 'plugin_repository_last_check_duration = 10' > $HOME/.asdfrc
  run asdf plugin-list-all
  local expected="\
bar                           http://example.com/bar
dummy                        *http://example.com/dummy
foo                           http://example.com/foo"

  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "plugin_list_all skips repo sync because check_duration is set to never" {
  echo 'plugin_repository_last_check_duration = never' > $HOME/.asdfrc
  run asdf plugin-list-all
  local expected="\
bar                           http://example.com/bar
dummy                        *http://example.com/dummy
foo                           http://example.com/foo"

  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "plugin_list_all list all plugins in the repository" {
  run asdf plugin-list-all
  local expected="\
bar                           http://example.com/bar
dummy                        *http://example.com/dummy
foo                           http://example.com/foo"

  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

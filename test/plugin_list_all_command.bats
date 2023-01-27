#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helpers

setup() {
  setup_asdf_dir
  setup_repo
  install_dummy_plugin
}

teardown() {
  clean_asdf_dir
}

@test "plugin_list_all should exit before syncing the plugin repo if disabled" {
  export ASDF_CONFIG_DEFAULT_FILE="$HOME/.asdfrc"
  echo 'disable_plugin_short_name_repository=yes' >"$ASDF_CONFIG_DEFAULT_FILE"
  local expected="Short-name plugin repository is disabled"

  run asdf plugin list all
  [ "$status" -eq 1 ]
  [ "$output" = "$expected" ]
}

@test "plugin_list_all should sync repo when check_duration set to 0" {
  export ASDF_CONFIG_DEFAULT_FILE="$HOME/.asdfrc"
  echo 'plugin_repository_last_check_duration = 0' >"$ASDF_CONFIG_DEFAULT_FILE"
  local expected_plugin_repo_sync="updating plugin repository..."
  local expected_plugins_list="\
bar                           http://example.com/bar
dummy                        *http://example.com/dummy
foo                           http://example.com/foo"

  run asdf plugin list all
  [ "$status" -eq 0 ]
  [[ "$output" == *"$expected_plugin_repo_sync"* ]]
  [[ "$output" == *"$expected_plugins_list"* ]]
}

@test "plugin_list_all no immediate repo sync expected because check_duration is greater than 0" {
  export ASDF_CONFIG_DEFAULT_FILE="$HOME/.asdfrc"
  echo 'plugin_repository_last_check_duration = 10' >"$ASDF_CONFIG_DEFAULT_FILE"
  local expected="\
bar                           http://example.com/bar
dummy                        *http://example.com/dummy
foo                           http://example.com/foo"

  run asdf plugin list all
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "plugin_list_all skips repo sync because check_duration is set to never" {
  export ASDF_CONFIG_DEFAULT_FILE="$HOME/.asdfrc"
  echo 'plugin_repository_last_check_duration = never' >"$ASDF_CONFIG_DEFAULT_FILE"
  local expected="\
bar                           http://example.com/bar
dummy                        *http://example.com/dummy
foo                           http://example.com/foo"

  run asdf plugin list all
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "plugin_list_all list all plugins in the repository" {
  local expected="\
bar                           http://example.com/bar
dummy                        *http://example.com/dummy
foo                           http://example.com/foo"

  run asdf plugin list all
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

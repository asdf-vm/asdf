#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helpers

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "plugin_add command with plugin name matching all valid regex chars succeeds" {
  install_mock_plugin_repo "plugin_with-all-valid-chars-123"

  run asdf plugin add "plugin_with-all-valid-chars-123" "${BASE_DIR}/repo-plugin_with-all-valid-chars-123"
  [ "$status" -eq 0 ]

  run asdf plugin list
  [ "$output" = "plugin_with-all-valid-chars-123" ]
}

@test "plugin_add command with LANG=sv_SE.UTF-8 and plugin name matching all valid regex chars succeeds" {
  ORIGINAL_LANG="$LANG"
  LANG=sv_SE.UTF-8

  install_mock_plugin_repo "plugin-with-w"

  # https://stackoverflow.com/questions/52570103/regular-expression-a-za-z-seems-to-not-include-letter-w-and-wA
  # https://github.com/asdf-vm/asdf/issues/1237
  run asdf plugin add "plugin-with-w" "${BASE_DIR}/repo-plugin-with-w"
  [ "$status" -eq 0 ]

  run asdf plugin-list
  [ "$output" = "plugin-with-w" ]

  LANG="$ORIGINAL_LANG"
}

@test "plugin_add command with plugin name not matching valid regex fails 1" {
  run asdf plugin add "invalid\$plugin\$name"
  [ "$status" -eq 1 ]
  [ "$output" = "invalid\$plugin\$name is invalid. Name may only contain lowercase letters, numbers, '_', and '-'" ]
}

@test "plugin_add command with plugin name not matching valid regex fails 2" {
  run asdf plugin add "#invalid#plugin#name"
  [ "$status" -eq 1 ]
  [ "$output" = "#invalid#plugin#name is invalid. Name may only contain lowercase letters, numbers, '_', and '-'" ]
}

@test "plugin_add command with plugin name not matching valid regex fails 3" {
  run asdf plugin add "Ruby"
  [ "$status" -eq 1 ]
  [ "$output" = "Ruby is invalid. Name may only contain lowercase letters, numbers, '_', and '-'" ]
}

@test "plugin_add command with no URL specified adds a plugin using repo" {
  run asdf plugin add "elixir"
  [ "$status" -eq 0 ]

  run asdf plugin list
  [ "$output" = "elixir" ]
}

@test "plugin_add command with no URL specified adds a plugin when short name repository is enabled" {
  export ASDF_CONFIG_DEFAULT_FILE="$HOME/.asdfrc"
  echo "disable_plugin_short_name_repository=no" >"$ASDF_CONFIG_DEFAULT_FILE"

  run asdf plugin add "elixir"
  [ "$status" -eq 0 ]

  local expected="elixir"
  run asdf plugin list
  [ "$output" = "$expected" ]
}

@test "plugin_add command with no URL specified fails to add a plugin when disabled" {
  export ASDF_CONFIG_DEFAULT_FILE="$HOME/.asdfrc"
  echo "disable_plugin_short_name_repository=yes" >"$ASDF_CONFIG_DEFAULT_FILE"
  local expected="Short-name plugin repository is disabled"

  run asdf plugin add "elixir"
  [ "$status" -eq 1 ]
  [ "$output" = "$expected" ]
}

@test "plugin_add command with URL specified adds a plugin using repo" {
  install_mock_plugin_repo "dummy"

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"
  [ "$status" -eq 0 ]

  run asdf plugin list
  # whitespace between 'elixir' and url is from printf %-15s %s format
  [ "$output" = "dummy" ]
}

@test "plugin_add command with URL specified twice returns success on second time" {
  install_mock_plugin_repo "dummy"

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"
  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "Plugin named dummy already added" ]
}

@test "plugin_add command with no URL specified fails if the plugin doesn't exist" {
  run asdf plugin add "does-not-exist"
  [ "$status" -eq 1 ]
  echo "$output" | grep "plugin does-not-exist not found in repository"
}

@test "plugin_add command executes post-plugin add script" {
  install_mock_plugin_repo "dummy"

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"
  [ "$output" = "plugin add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy" ]
}

@test "plugin_add command executes configured pre hook (generic)" {
  install_mock_plugin_repo "dummy"

  cat >"$HOME/.asdfrc" <<-'EOM'
pre_asdf_plugin_add = echo ADD ${@}
EOM

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="ADD dummy
plugin add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy"
  [ "$output" = "${expected_output}" ]
}

@test "plugin_add command executes configured pre hook (specific)" {
  install_mock_plugin_repo "dummy"

  cat >"$HOME/.asdfrc" <<-'EOM'
pre_asdf_plugin_add_dummy = echo ADD
EOM

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="ADD
plugin add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy"
  [ "$output" = "${expected_output}" ]
}

@test "plugin_add command executes configured post hook (generic)" {
  install_mock_plugin_repo "dummy"

  cat >"$HOME/.asdfrc" <<-'EOM'
post_asdf_plugin_add = echo ADD ${@}
EOM

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="plugin add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy
ADD dummy"
  [ "$output" = "${expected_output}" ]
}

@test "plugin_add command executes configured post hook (specific)" {
  install_mock_plugin_repo "dummy"

  cat >"$HOME/.asdfrc" <<-'EOM'
post_asdf_plugin_add_dummy = echo ADD
EOM

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="plugin add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy
ADD"
  [ "$output" = "${expected_output}" ]
}

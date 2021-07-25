#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "plugin_add command with plugin name matching all valid regex chars succeeds" {
  install_mock_plugin_repo "plugin_with-all-valid-CHARS-123"

  run asdf plugin add "plugin_with-all-valid-CHARS-123" "${BASE_DIR}/repo-plugin_with-all-valid-CHARS-123"
  [ "$status" -eq 0 ]

  run asdf plugin-list
  [ "$output" = "plugin_with-all-valid-CHARS-123" ]
}

@test "plugin_add command with plugin name not matching valid regex fails" {
  run asdf plugin add "invalid\$plugin\$name"
  [ "$status" -eq 1 ]
  [ "$output" = "invalid\$plugin\$name is invalid. Name must match regex ^[a-zA-Z0-9_-]+$" ]
}

@test "plugin_add command with plugin name not matching valid regex fails again" {
  run asdf plugin add "#invalid#plugin#name"
  [ "$status" -eq 1 ]
  [ "$output" = "#invalid#plugin#name is invalid. Name must match regex ^[a-zA-Z0-9_-]+$" ]
}

@test "plugin_add command with no URL specified adds a plugin using repo" {
  run asdf plugin add "elixir"
  [ "$status" -eq 0 ]

  run asdf plugin-list
  # whitespace between 'elixir' and url is from printf %-15s %s format
  [ "$output" = "elixir" ]
}

@test "plugin_add command with URL specified adds a plugin using repo" {
  install_mock_plugin_repo "dummy"

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"
  [ "$status" -eq 0 ]

  run asdf plugin-list
  # whitespace between 'elixir' and url is from printf %-15s %s format
  [ "$output" = "dummy" ]
}

@test "plugin_add command with URL specified run twice returns error second time" {
  install_mock_plugin_repo "dummy"

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"
  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"
  [ "$status" -eq 2 ]
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

  cat > $HOME/.asdfrc <<-'EOM'
pre_asdf_plugin_add = echo ADD ${@}
EOM

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="ADD dummy
plugin add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy"
  [ "$output" = "${expected_output}" ]
}

@test "plugin_add command executes configured pre hook (specific)" {
  install_mock_plugin_repo "dummy"

  cat > $HOME/.asdfrc <<-'EOM'
pre_asdf_plugin_add_dummy = echo ADD
EOM

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="ADD
plugin add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy"
  [ "$output" = "${expected_output}" ]
}

@test "plugin_add command executes configured post hook (generic)" {
  install_mock_plugin_repo "dummy"

  cat > $HOME/.asdfrc <<-'EOM'
post_asdf_plugin_add = echo ADD ${@}
EOM

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="plugin add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy
ADD dummy"
  [ "$output" = "${expected_output}" ]
}

@test "plugin_add command executes configured post hook (specific)" {
  install_mock_plugin_repo "dummy"

  cat > $HOME/.asdfrc <<-'EOM'
post_asdf_plugin_add_dummy = echo ADD
EOM

  run asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="plugin add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy
ADD"
  [ "$output" = "${expected_output}" ]
}

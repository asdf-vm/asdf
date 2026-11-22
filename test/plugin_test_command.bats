#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_mock_plugin_repo "dummy"
}

teardown() {
  clean_asdf_dir
}

@test "plugin_test_command with no URL specified prints an error" {
  run asdf plugin test "elixir"
  [ "$status" -eq 1 ]
  [ "$output" = "FAILED: please provide a plugin name and url" ]
}

@test "plugin_test_command with no name or URL specified prints an error" {
  run asdf plugin test
  [ "$status" -eq 1 ]
  [ "$output" = "FAILED: please provide a plugin name and url" ]
}

@test "plugin_test_command installs the latest stable version by default" {
  cat >"$HOME/.asdfrc" <<-'EOM'
post_asdf_install_asdf-test-dummy = echo Installed $1
EOM

  run asdf plugin test dummy "${BASE_DIR}/repo-dummy"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installed 2.0.0" ]]
}

@test "plugin_test_command works with all options provided" {
  run asdf plugin test dummy "${BASE_DIR}/repo-dummy" --asdf-tool-version 1.0.0 --asdf-plugin-gitref master
  [ "$status" -eq 0 ]
}

@test "plugin_test_command resolves latest version when --asdf-tool-version latest is provided" {
  run asdf plugin test dummy "${BASE_DIR}/repo-dummy" --asdf-tool-version latest
  [ "$status" -eq 0 ]
}

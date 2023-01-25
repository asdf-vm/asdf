#!/usr/bin/env bats
# shellcheck disable=SC2164

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR="$HOME/project"
  mkdir -p "$PROJECT_DIR"
  cd "$PROJECT_DIR"
}

teardown() {
  clean_asdf_dir
}

@test "shim_versions_command should list plugins and versions where command is available" {
  cd "$PROJECT_DIR"
  run asdf install dummy 3.0
  run asdf install dummy 1.0
  run asdf reshim dummy

  run asdf shim-versions dummy
  [ "$status" -eq 0 ]

  echo "$output" | grep "dummy 3.0"
  echo "$output" | grep "dummy 1.0"
}

#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_legacy_plugin
  run asdf install dummy 1.0
  run asdf install dummy 1.1

  PROJECT_DIR="$HOME/project"
  mkdir -p "$PROJECT_DIR"
}

teardown() {
  clean_asdf_dir
}

@test "info should show os, shell and asdf debug information" {
  cd "$PROJECT_DIR"

  run asdf info

  assert_success
  assert_line -p $'OS:'
  assert_line -p $'SHELL:'
  assert_line -p $'BASH VERSION:'
  assert_line -p $'ASDF VERSION:'
  assert_line -p $'ASDF INTERNAL VARIABLES:'
  assert_line -p $'ASDF INSTALLED PLUGINS:'
}

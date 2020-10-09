#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_legacy_plugin
  run asdf install dummy 1.0
  run asdf install dummy 1.1

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "info should show os, shell and asdf debug information" {
  cd $PROJECT_DIR

  run asdf info

  [ "$status" -eq 0 ]
  # TODO: Assert asdf info output is printed
}

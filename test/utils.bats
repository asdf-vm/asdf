#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  mkdir -p $PROJECT_DIR

  echo 'dummy 1.0.0' >> $HOME/.tool-versions
  echo 'other 1.0.0' >> $HOME/.tool-versions
  echo 'dummy 1.1.0' >> $PROJECT_DIR/.tool-versions
}

teardown() {
  clean_asdf_dir
}

@test "check_if_version_exists should exit with 1 if plugin does not exist" {
  mkdir -p $ASDF_DIR/installs
  run check_if_version_exists "foo" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "version 1.0.0 is not installed for foo" ]
}

@test "check_if_version_exists should exit with 1 if version does not exist" {
  mkdir -p $ASDF_DIR/installs/foo
  run check_if_version_exists "foo" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "version 1.0.0 is not installed for foo" ]
}

@test "check_if_version_exists should be noop if version exists" {
  mkdir -p $ASDF_DIR/installs/foo/1.0.0
  run check_if_version_exists "foo" "1.0.0"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "check_if_plugin_exists should exit with 1 when plugin is empty string" {
  run check_if_plugin_exists
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin" ]
}

@test "check_if_plugin_exists should be noop if plugin exists" {
  mkdir -p $ASDF_DIR/plugins/foo_bar
  run check_if_plugin_exists "foo_bar"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "get_asdf_versions_file_path should return closest .tool-versions when no args provided" {
  cd $PROJECT_DIR

  run get_asdf_versions_file_path
  [ "$status" -eq 0 ]
  [ "$output" = "$PROJECT_DIR/.tool-versions" ]
}

@test "get_asdf_versions_file_path should return closest .tool-versions if contains plugin" {
  cd $PROJECT_DIR

  run get_asdf_versions_file_path "dummy"

  [ "$status" -eq 0 ]
  [ "$output" = "$PROJECT_DIR/.tool-versions" ]
}

@test "get_asdf_versions_file_path should return correct .tool-versions if closest does not contain plugin" {
  cd $PROJECT_DIR

  run get_asdf_versions_file_path "other"

  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.tool-versions" ]
}

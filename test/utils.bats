#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version "0.1.0"
  install_dummy_version "0.2.0"

  PROJECT_DIR=$HOME/project
  mkdir -p $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "check_if_version_exists should exit with 1 if plugin does not exist" {
  run check_if_version_exists "inexistent" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "version 1.0.0 is not installed for inexistent" ]
}

@test "check_if_version_exists should exit with 1 if version does not exist" {
  run check_if_version_exists "dummy" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "version 1.0.0 is not installed for dummy" ]
}

@test "check_if_version_exists should be noop if version exists" {
  run check_if_version_exists "dummy" "0.1.0"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "check_if_plugin_exists should exit with 1 when plugin is empty string" {
  run check_if_plugin_exists
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin" ]
}

@test "check_if_plugin_exists should be noop if plugin exists" {
  run check_if_plugin_exists "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "find_version should return .tool-versions if legacy is disabled" {
  echo "dummy 0.1.0" > $PROJECT_DIR/.tool-versions
  echo "0.2.0" > $PROJECT_DIR/.dummy-version

  run find_version "dummy" $PROJECT_DIR
  [ "$status" -eq 0 ]
  [ "$output" = "0.1.0:$PROJECT_DIR/.tool-versions" ]
}

@test "find_version should return the legacy file if supported" {
  echo "legacy_version_file = yes" > $HOME/.asdfrc
  echo "dummy 0.1.0" > $HOME/.tool-versions
  echo "0.2.0" > $PROJECT_DIR/.dummy-version

  run find_version "dummy" $PROJECT_DIR
  [ "$status" -eq 0 ]
  [ "$output" = "0.2.0:$PROJECT_DIR/.dummy-version" ]
}

@test "find_version skips .tool-version file that don't list the plugin" {
  echo "dummy 0.1.0" > $HOME/.tool-versions
  echo "another_plugin 0.3.0" > $PROJECT_DIR/.tool-versions

  run find_version "dummy" $PROJECT_DIR
  [ "$status" -eq 0 ]
  [ "$output" = "0.1.0:$HOME/.tool-versions" ]
}

@test "find_version should return .tool-versions if unsupported" {
  echo "dummy 0.1.0" > $HOME/.tool-versions
  echo "0.2.0" > $PROJECT_DIR/.dummy-version
  echo "legacy_version_file = yes" > $HOME/.asdfrc
  rm $ASDF_DIR/plugins/dummy/bin/list-legacy-filenames

  run find_version "dummy" $PROJECT_DIR
  [ "$status" -eq 0 ]
  [ "$output" = "0.1.0:$HOME/.tool-versions" ]
}

@test "get_preset_version_for returns the current version" {
  cd $PROJECT_DIR
  echo "dummy 0.2.0" > .tool-versions
  run get_preset_version_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "0.2.0" ]
}

@test "get_preset_version_for returns the global version from home when project is outside of home" {
  echo "dummy 0.1.0" > $HOME/.tool-versions
  PROJECT_DIR=$BASE_DIR/project
  mkdir -p $PROJECT_DIR
  run get_preset_version_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "0.1.0" ]
}

@test "get_preset_version_for returns the tool version from env if ASDF_{TOOL}_VERSION is defined" {
  cd $PROJECT_DIR
  echo "dummy 0.2.0" > .tool-versions
  ASDF_DUMMY_VERSION=3.0.0 run get_preset_version_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "3.0.0" ]
}
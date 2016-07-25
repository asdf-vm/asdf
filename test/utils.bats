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

@test "find_version_file_for should return .tool-versions if legacy is disabled" {
  cd $PROJECT_DIR
  touch ".tool-versions"
  touch ".dummy-version"

  run find_version_file_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "$PROJECT_DIR/.tool-versions" ]
}

@test "find_version_file_for should return .tool-versions ++ plugin filenames if supported" {
  cd $PROJECT_DIR
  touch "$HOME/.tool-versions"
  touch ".dummy-version"
  echo 'legacy_version_file = yes' > $HOME/.asdfrc

  run find_version_file_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "$PROJECT_DIR/.dummy-version" ]
}

@test "find_version_file_for should return .tool-versions if unsupported" {
  cd $PROJECT_DIR
  touch "$HOME/.tool-versions"
  touch ".dummy-version"
  echo 'legacy_version_file = yes' > $HOME/.asdfrc
  rm $ASDF_DIR/plugins/dummy/bin/list-legacy-filenames

  run find_version_file_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.tool-versions" ]
}

@test "search_filenames should return the path to the first filename found" {
  touch "$PROJECT_DIR/.dummy-version"
  touch "$PROJECT_DIR/.tool-versions"

  run search_filenames ".tool-versions .dummy-version" $PROJECT_DIR
  [ "$status" -eq 0 ]
  [ "$output" = "$PROJECT_DIR/.tool-versions" ]
}

@test "search_filenames should walk parent directories" {
  touch "$PROJECT_DIR/.dummy-version"
  touch "$HOME/.tool-versions"

  run search_filenames ".tool-versions" $PROJECT_DIR
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.tool-versions" ]
}

@test "search_filenames should return nothing if not found" {
  run search_filenames ".does-not-exist" $PROJECT_DIR
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "parse_version_file parses the version from a .tool-version file" {
  echo "dummy 0.2.0" > $HOME/.tool-versions
  run parse_version_file $HOME/.tool-versions "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "0.2.0" ]
}

@test "parse_version_file calls the plugin's parse-legacy-file if implemented" {
  echo "dummy-0.2.0" > $HOME/.dummy-version
  run parse_version_file $HOME/.dummy-version "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "0.2.0" ]
}

@test "parse_version_file cats the legacy file if parse-legacy-file isn't implemented" {
  echo "0.2.0" > $HOME/.dummy-version
  rm $ASDF_DIR/plugins/dummy/bin/parse-legacy-file
  run parse_version_file $HOME/.dummy-version "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "0.2.0" ]
}

@test "get_preset_version_for returns the current version" {
  cd $PROJECT_DIR
  echo "dummy 0.2.0" > .tool-versions
  run get_preset_version_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "0.2.0" ]
}

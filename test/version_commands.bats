#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/version_commands.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version "1.0.0"
  install_dummy_version "1.1.0"

  PROJECT_DIR=$HOME/project
  mkdir -p $PROJECT_DIR

  cd $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

# Warn users who invoke the old style command without arguments.
@test "local should emit an error when called with incorrect arity" {
  run local_command "dummy"
  [ "$status" -eq 1 ]
  [ "$output" = "Usage: asdf local <name> <version>" ]
}

@test "local should emit an error when plugin does not exist" {
  run local_command "inexistent" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin: inexistent" ]
}

@test "local should emit an error when plugin version does not exist" {
  run local_command "dummy" "0.0.1"
  [ "$status" -eq 1 ]
  [ "$output" = "version 0.0.1 is not installed for dummy" ]
}

@test "local should create a local .tool-versions file if it doesn't exist" {
  run local_command "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $PROJECT_DIR/.tool-versions)" = "dummy 1.1.0" ]
}

@test "local should allow multiple versions" {
  run local_command "dummy" "1.1.0" "1.0.0"
  [ "$status" -eq 0 ]
  [ "$(cat $PROJECT_DIR/.tool-versions)" = "dummy 1.1.0 1.0.0" ]
}

@test "local should create a local .tool-versions file if it doesn't exist when the directory name contains whitespace" {
  WHITESPACE_DIR="$PROJECT_DIR/whitespace\ dir"
  mkdir -p "$WHITESPACE_DIR"
  cd "$WHITESPACE_DIR"

  run local_command "dummy" "1.1.0"

  tool_version_contents=$(cat "$WHITESPACE_DIR/.tool-versions")
  [ "$status" -eq 0 ]
  [ "$tool_version_contents" = "dummy 1.1.0" ]
}

@test "local should not create a duplicate .tool-versions file if such file exists" {
  echo 'dummy 1.0.0' >> $PROJECT_DIR/.tool-versions

  run local_command "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(ls $PROJECT_DIR/.tool-versions* | wc -l)" -eq 1 ]
}

@test "local should overwrite the existing version if it's set" {
  echo 'dummy 1.0.0' >> $PROJECT_DIR/.tool-versions
  run local_command "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $PROJECT_DIR/.tool-versions)" = "dummy 1.1.0" ]
}

@test "local should fail to set a path:dir if dir does not exists " {
    run local_command "dummy" "path:$PROJECT_DIR/local"
    [ "$output" = "version path:$PROJECT_DIR/local is not installed for dummy" ]
    [ "$status" -eq 1 ]
}

@test "local should set a path:dir if dir exists " {
    mkdir -p $PROJECT_DIR/local
    run local_command "dummy" "path:$PROJECT_DIR/local"
    [ "$status" -eq 0 ]
    [ "$(cat $PROJECT_DIR/.tool-versions)" = "dummy path:$PROJECT_DIR/local" ]
}

@test "global should create a global .tool-versions file if it doesn't exist" {
  run global_command "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $HOME/.tool-versions)" = "dummy 1.1.0" ]
}

@test "global should accept multiple versions" {
  run global_command "dummy" "1.1.0" "1.0.0"
  [ "$status" -eq 0 ]
  [ "$(cat $HOME/.tool-versions)" = "dummy 1.1.0 1.0.0" ]
}

@test "global should overwrite the existing version if it's set" {
  echo 'dummy 1.0.0' >> $HOME/.tool-versions
  run global_command "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $HOME/.tool-versions)" = "dummy 1.1.0" ]
}

@test "global should fail to set a path:dir if dir does not exists " {
    run global_command "dummy" "path:$PROJECT_DIR/local"
    [ "$output" = "version path:$PROJECT_DIR/local is not installed for dummy" ]
    [ "$status" -eq 1 ]
}

@test "global should set a path:dir if dir exists " {
    mkdir -p $PROJECT_DIR/local
    run global_command "dummy" "path:$PROJECT_DIR/local"
    [ "$status" -eq 0 ]
    [ "$(cat $HOME/.tool-versions)" = "dummy path:$PROJECT_DIR/local" ]
}

@test "global should write to ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" {
  ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$PROJECT_DIR/global-tool-versions"
  run global_command "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $ASDF_DEFAULT_TOOL_VERSIONS_FILENAME)" = "dummy 1.1.0" ]
  [ "$(cat $HOME/.tool-versions)" = "" ]
}

@test "global should overwrite contents of ASDF_DEFAULT_TOOL_VERSIONS_FILENAME if set" {
  ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$PROJECT_DIR/global-tool-versions"
  echo 'dummy 1.0.0' >> "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"
  run global_command "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $ASDF_DEFAULT_TOOL_VERSIONS_FILENAME)" = "dummy 1.1.0" ]
  [ "$(cat $HOME/.tool-versions)" = "" ]
}

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

  CHILD_DIR=$PROJECT_DIR/child-dir
  mkdir -p $CHILD_DIR

  cd $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

# Warn users who invoke the old style command without arguments.
@test "local should emit an error when called with incorrect arity" {
  run asdf local "dummy"
  [ "$status" -eq 1 ]
  [ "$output" = "Usage: asdf local <name> <version>" ]
}

@test "local should emit an error when plugin does not exist" {
  run asdf local "inexistent" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin: inexistent" ]
}

@test "local should emit an error when plugin version does not exist" {
  run asdf local "dummy" "0.0.1"
  [ "$status" -eq 1 ]
  [ "$output" = "version 0.0.1 is not installed for dummy" ]
}

@test "local should create a local .tool-versions file if it doesn't exist" {
  run asdf local "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $PROJECT_DIR/.tool-versions)" = "dummy 1.1.0" ]
}

@test "local should allow multiple versions" {
  run asdf local "dummy" "1.1.0" "1.0.0"
  [ "$status" -eq 0 ]
  [ "$(cat $PROJECT_DIR/.tool-versions)" = "dummy 1.1.0 1.0.0" ]
}

@test "local should create a local .tool-versions file if it doesn't exist when the directory name contains whitespace" {
  WHITESPACE_DIR="$PROJECT_DIR/whitespace\ dir"
  mkdir -p "$WHITESPACE_DIR"
  cd "$WHITESPACE_DIR"

  run asdf local "dummy" "1.1.0"

  tool_version_contents=$(cat "$WHITESPACE_DIR/.tool-versions")
  [ "$status" -eq 0 ]
  [ "$tool_version_contents" = "dummy 1.1.0" ]
}

@test "local should not create a duplicate .tool-versions file if such file exists" {
  echo 'dummy 1.0.0' >> $PROJECT_DIR/.tool-versions

  run asdf local "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(ls $PROJECT_DIR/.tool-versions* | wc -l)" -eq 1 ]
}

@test "local should overwrite the existing version if it's set" {
  echo 'dummy 1.0.0' >> $PROJECT_DIR/.tool-versions
  run asdf local "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $PROJECT_DIR/.tool-versions)" = "dummy 1.1.0" ]
}

@test "local should fail to set a path:dir if dir does not exists " {
  run asdf local "dummy" "path:$PROJECT_DIR/local"
  [ "$output" = "version path:$PROJECT_DIR/local is not installed for dummy" ]
  [ "$status" -eq 1 ]
}

@test "local should set a path:dir if dir exists " {
  mkdir -p $PROJECT_DIR/local
  run asdf local "dummy" "path:$PROJECT_DIR/local"
  [ "$status" -eq 0 ]
  [ "$(cat $PROJECT_DIR/.tool-versions)" = "dummy path:$PROJECT_DIR/local" ]
}

@test "local -p/--parent should set should emit an error when called with incorrect arity" {
  run asdf local -p "dummy"
  [ "$status" -eq 1 ]
  [ "$output" = "Usage: asdf local <name> <version>" ]
}

@test "local -p/--parent should emit an error when plugin does not exist" {
  run asdf local -p "inexistent" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin: inexistent" ]
}

@test "local -p/--parent should emit an error when plugin version does not exist" {
  run asdf local -p "dummy" "0.0.1"
  [ "$status" -eq 1 ]
  [ "$output" = "version 0.0.1 is not installed for dummy" ]
}

@test "local -p/--parent should allow multiple versions" {
  cd $CHILD_DIR
  touch $PROJECT_DIR/.tool-versions
  run asdf local -p "dummy" "1.1.0" "1.0.0"
  [ "$status" -eq 0 ]
  [ "$(cat $PROJECT_DIR/.tool-versions)" = "dummy 1.1.0 1.0.0" ]
}

@test "local -p/--parent should overwrite the existing version if it's set" {
  cd $CHILD_DIR
  echo 'dummy 1.0.0' >> $PROJECT_DIR/.tool-versions
  run asdf local -p "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $PROJECT_DIR/.tool-versions)" = "dummy 1.1.0" ]
}

@test "local -p/--parent should set the version if it's unset" {
  cd $CHILD_DIR
  touch $PROJECT_DIR/.tool-versions
  run asdf local -p "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $PROJECT_DIR/.tool-versions)" = "dummy 1.1.0" ]
}

@test "global should create a global .tool-versions file if it doesn't exist" {
  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $HOME/.tool-versions)" = "dummy 1.1.0" ]
}

@test "global should accept multiple versions" {
  run asdf global "dummy" "1.1.0" "1.0.0"
  [ "$status" -eq 0 ]
  [ "$(cat $HOME/.tool-versions)" = "dummy 1.1.0 1.0.0" ]
}

@test "global should overwrite the existing version if it's set" {
  echo 'dummy 1.0.0' >> $HOME/.tool-versions
  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $HOME/.tool-versions)" = "dummy 1.1.0" ]
}

@test "global should fail to set a path:dir if dir does not exists " {
  run asdf global "dummy" "path:$PROJECT_DIR/local"
  [ "$output" = "version path:$PROJECT_DIR/local is not installed for dummy" ]
  [ "$status" -eq 1 ]
}

@test "global should set a path:dir if dir exists " {
  mkdir -p $PROJECT_DIR/local
  run asdf global "dummy" "path:$PROJECT_DIR/local"
  [ "$status" -eq 0 ]
  [ "$(cat $HOME/.tool-versions)" = "dummy path:$PROJECT_DIR/local" ]
}

@test "global should write to ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" {
  export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$PROJECT_DIR/global-tool-versions"
  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $ASDF_DEFAULT_TOOL_VERSIONS_FILENAME)" = "dummy 1.1.0" ]
  [ "$(cat $HOME/.tool-versions)" = "" ]
  unset ASDF_DEFAULT_TOOL_VERSIONS_FILENAME
}

@test "global should overwrite contents of ASDF_DEFAULT_TOOL_VERSIONS_FILENAME if set" {
  export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$PROJECT_DIR/global-tool-versions"
  echo 'dummy 1.0.0' >> "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"
  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat $ASDF_DEFAULT_TOOL_VERSIONS_FILENAME)" = "dummy 1.1.0" ]
  [ "$(cat $HOME/.tool-versions)" = "" ]
  unset ASDF_DEFAULT_TOOL_VERSIONS_FILENAME
}

@test "local should preserve symlinks when setting versions" {
  mkdir other-dir
  touch other-dir/.tool-versions
  ln -s other-dir/.tool-versions .tool-versions
  run asdf local "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ -L .tool-versions ]
  [ "$(cat other-dir/.tool-versions)" = "dummy 1.1.0" ]
}

@test "local should preserve symlinks when updating versions" {
  mkdir other-dir
  touch other-dir/.tool-versions
  ln -s other-dir/.tool-versions .tool-versions
  run asdf local "dummy" "1.1.0"
  run asdf local "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ -L .tool-versions ]
  [ "$(cat other-dir/.tool-versions)" = "dummy 1.1.0" ]
}

@test "global should preserve symlinks when setting versions" {
  mkdir other-dir
  touch other-dir/.tool-versions
  ln -s other-dir/.tool-versions $HOME/.tool-versions

  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ -L $HOME/.tool-versions ]
  [ "$(cat other-dir/.tool-versions)" = "dummy 1.1.0" ]
}

@test "global should preserve symlinks when updating versions" {
  mkdir other-dir
  touch other-dir/.tool-versions
  ln -s other-dir/.tool-versions $HOME/.tool-versions

  run asdf global "dummy" "1.1.0"
  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ -L $HOME/.tool-versions ]
  [ "$(cat other-dir/.tool-versions)" = "dummy 1.1.0" ]
}

@test "shell wrapper function should export ENV var" {
  source $(dirname "$BATS_TEST_DIRNAME")/asdf.sh
  asdf shell "dummy" "1.1.0"
  [ $(echo $ASDF_DUMMY_VERSION) = "1.1.0" ]
  unset ASDF_DUMMY_VERSION
}

@test "shell wrapper function should return an error for missing plugins" {
  source $(dirname "$BATS_TEST_DIRNAME")/asdf.sh
  run asdf shell "nonexistent" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin: nonexistent" ]
}

@test "shell should emit an error when wrapper function is not loaded" {
  run asdf shell "dummy" "1.1.0"
  echo $output
  [ "$status" -eq 1 ]
  [ "$output" = "Shell integration is not enabled. Please ensure you source asdf in your shell setup." ]
}

@test "sh-shell should emit an error when plugin does not exist" {
  run asdf sh-shell "nonexistent" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = $'No such plugin: nonexistent\nfalse' ]
}

@test "sh-shell should emit an error when version does not exist" {
  run asdf sh-shell "dummy" "nonexistent"
  [ "$status" -eq 1 ]
  [ "$output" = $'version nonexistent is not installed for dummy\nfalse' ]
}

@test "sh-shell should export version if it exists" {
  run asdf sh-shell "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$output" = "export ASDF_DUMMY_VERSION=\"1.1.0\"" ]
}

@test "sh-shell should use set when shell is fish" {
  ASDF_SHELL=fish run asdf sh-shell "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$output" = "set -gx ASDF_DUMMY_VERSION \"1.1.0\"" ]
}

#!/usr/bin/env bats
# shellcheck disable=SC2012,SC2030,SC2031,SC2164

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version "1.0.0"
  install_dummy_version "1.1.0"
  install_dummy_version "2.0.0"

  install_dummy_legacy_plugin
  install_dummy_legacy_version "1.0.0"
  install_dummy_legacy_version "1.1.0"
  install_dummy_legacy_version "2.0.0"
  install_dummy_legacy_version "5.1.0"

  PROJECT_DIR="$HOME/project"
  mkdir -p "$PROJECT_DIR"

  CHILD_DIR="$PROJECT_DIR/child-dir"
  mkdir -p "$CHILD_DIR"

  cd "$PROJECT_DIR"

  # asdf lib needed to run asdf.sh
  cp -rf "$BATS_TEST_DIRNAME"/../{bin,lib} "$ASDF_DIR/"
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
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "dummy 1.1.0" ]
}

@test "[local - dummy_plugin] with latest should use the latest installed version" {
  run asdf local "dummy" "latest"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "dummy 2.0.0" ]
}

@test "[local - dummy_plugin] with latest:version should use the latest valid installed version" {
  run asdf local "dummy" "latest:1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "dummy 1.0.0" ]
}

@test "[local - dummy_plugin] with latest:version should return an error for invalid versions" {
  run asdf local "dummy" "latest:99"
  [ "$status" -eq 1 ]
  [ "$output" = "No compatible versions available (dummy 99)" ]
}

@test "[local - dummy_legacy_plugin] with latest should use the latest installed version" {
  run asdf local "legacy-dummy" "latest"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "legacy-dummy 5.1.0" ]
}

@test "[local - dummy_legacy_plugin] with latest:version should use the latest valid installed version" {
  run asdf local "legacy-dummy" "latest:1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "legacy-dummy 1.0.0" ]
}

@test "[local - dummy_legacy_plugin] with latest:version should return an error for invalid versions" {
  run asdf local "legacy-dummy" "latest:99"
  [ "$status" -eq 1 ]
  [ "$output" = "No compatible versions available (legacy-dummy 99)" ]
}

@test "local should allow multiple versions" {
  run asdf local "dummy" "1.1.0" "1.0.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "dummy 1.1.0 1.0.0" ]
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
  echo 'dummy 1.0.0' >>"$PROJECT_DIR/.tool-versions"

  run asdf local "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(ls "$PROJECT_DIR/.tool-versions"* | wc -l)" -eq 1 ]
}

@test "local should overwrite the existing version if it's set" {
  echo 'dummy 1.0.0' >>"$PROJECT_DIR/.tool-versions"

  run asdf local "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "dummy 1.1.0" ]
}

@test "local should append trailing newline before appending new version when missing" {
  echo -n 'foobar 1.0.0' >>"$PROJECT_DIR/.tool-versions"

  run asdf local "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = $'foobar 1.0.0\ndummy 1.1.0' ]
}

@test "local should not append trailing newline before appending new version when one present" {
  echo 'foobar 1.0.0' >>"$PROJECT_DIR/.tool-versions"

  run asdf local "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = $'foobar 1.0.0\ndummy 1.1.0' ]
}

@test "local should fail to set a path:dir if dir does not exists " {
  run asdf local "dummy" "path:$PROJECT_DIR/local"
  [ "$output" = "version path:$PROJECT_DIR/local is not installed for dummy" ]
  [ "$status" -eq 1 ]
}

@test "local should set a path:dir if dir exists " {
  mkdir -p "$PROJECT_DIR/local"
  run asdf local "dummy" "path:$PROJECT_DIR/local"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "dummy path:$PROJECT_DIR/local" ]
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
  cd "$CHILD_DIR"
  touch "$PROJECT_DIR/.tool-versions"
  run asdf local -p "dummy" "1.1.0" "1.0.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "dummy 1.1.0 1.0.0" ]
}

@test "local -p/--parent should overwrite the existing version if it's set" {
  cd "$CHILD_DIR"
  echo 'dummy 1.0.0' >>"$PROJECT_DIR/.tool-versions"
  run asdf local -p "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "dummy 1.1.0" ]
}

@test "local -p/--parent should set the version if it's unset" {
  cd "$CHILD_DIR"
  touch "$PROJECT_DIR/.tool-versions"
  run asdf local -p "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "dummy 1.1.0" ]
}

@test "global should create a global .tool-versions file if it doesn't exist" {
  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = "dummy 1.1.0" ]
}

@test "[global - dummy_plugin] with latest should use the latest installed version" {
  run asdf global "dummy" "latest"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = "dummy 2.0.0" ]
}

@test "[global - dummy_plugin] with latest:version should use the latest valid installed version" {
  run asdf global "dummy" "latest:1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = "dummy 1.0.0" ]
}

@test "[global - dummy_plugin] with latest:version should return an error for invalid versions" {
  run asdf global "dummy" "latest:99"
  [ "$status" -eq 1 ]
  [ "$output" = "No compatible versions available (dummy 99)" ]
}

@test "[global - dummy_legacy_plugin] with latest should use the latest installed version" {
  run asdf global "legacy-dummy" "latest"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = "legacy-dummy 5.1.0" ]
}

@test "[global - dummy_legacy_plugin] with latest:version should use the latest valid installed version" {
  run asdf global "legacy-dummy" "latest:1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = "legacy-dummy 1.0.0" ]
}

@test "[global - dummy_legacy_plugin] with latest:version should return an error for invalid versions" {
  run asdf global "legacy-dummy" "latest:99"
  [ "$status" -eq 1 ]
  [ "$output" = "No compatible versions available (legacy-dummy 99)" ]
}

@test "global should accept multiple versions" {
  run asdf global "dummy" "1.1.0" "1.0.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = "dummy 1.1.0 1.0.0" ]
}

@test "global should overwrite the existing version if it's set" {
  echo 'dummy 1.0.0' >>"$HOME/.tool-versions"
  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = "dummy 1.1.0" ]
}

@test "global should append trailing newline before appending new version when missing" {
  echo -n 'foobar 1.0.0' >>"$HOME/.tool-versions"

  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = $'foobar 1.0.0\ndummy 1.1.0' ]
}

@test "global should not append trailing newline before appending new version when one present" {
  echo 'foobar 1.0.0' >>"$HOME/.tool-versions"

  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = $'foobar 1.0.0\ndummy 1.1.0' ]
}

@test "global should fail to set a path:dir if dir does not exists " {
  run asdf global "dummy" "path:$PROJECT_DIR/local"
  [ "$output" = "version path:$PROJECT_DIR/local is not installed for dummy" ]
  [ "$status" -eq 1 ]
}

@test "global should set a path:dir if dir exists " {
  mkdir -p "$PROJECT_DIR/local"
  run asdf global "dummy" "path:$PROJECT_DIR/local"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = "dummy path:$PROJECT_DIR/local" ]
}

@test "local should write to ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" {
  export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="local-tool-versions"
  run asdf local "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME")" = "dummy 1.1.0" ]
  [ -z "$(cat .tool-versions)" ]
  unset ASDF_DEFAULT_TOOL_VERSIONS_FILENAME
}

@test "local should overwrite contents of ASDF_DEFAULT_TOOL_VERSIONS_FILENAME if set" {
  export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="local-tool-versions"
  echo 'dummy 1.0.0' >>"$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"
  run asdf local "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME")" = "dummy 1.1.0" ]
  [ -z "$(cat .tool-versions)" ]
  unset ASDF_DEFAULT_TOOL_VERSIONS_FILENAME
}

@test "global should write to ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" {
  export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="global-tool-versions"
  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME")" = "dummy 1.1.0" ]
  [ -z "$(cat "$HOME/.tool-versions")" ]
  unset ASDF_DEFAULT_TOOL_VERSIONS_FILENAME
}

@test "global should overwrite contents of ASDF_DEFAULT_TOOL_VERSIONS_FILENAME if set" {
  export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="global-tool-versions"
  echo 'dummy 1.0.0' >>"$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"
  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME")" = "dummy 1.1.0" ]
  [ -z "$(cat "$HOME/.tool-versions")" ]
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
  mkdir "$HOME/other-dir"
  touch "$HOME/other-dir/.tool-versions"
  ln -s other-dir/.tool-versions "$HOME/.tool-versions"

  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ -L "$HOME/.tool-versions" ]
  [ "$(cat "$HOME/other-dir/.tool-versions")" = "dummy 1.1.0" ]
}

@test "global should preserve symlinks when updating versions" {
  mkdir "$HOME/other-dir"
  touch "$HOME/other-dir/.tool-versions"
  ln -s other-dir/.tool-versions "$HOME/.tool-versions"

  run asdf global "dummy" "1.1.0"
  run asdf global "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ -L "$HOME/.tool-versions" ]
  [ "$(cat "$HOME/other-dir/.tool-versions")" = "dummy 1.1.0" ]
}

@test "shell wrapper function should export ENV var" {
  . "$(dirname "$BATS_TEST_DIRNAME")/asdf.sh"
  asdf shell "dummy" "1.1.0"
  [ "$ASDF_DUMMY_VERSION" = "1.1.0" ]
  unset ASDF_DUMMY_VERSION
}

@test "shell wrapper function with --unset should unset ENV var" {
  . "$(dirname "$BATS_TEST_DIRNAME")/asdf.sh"
  asdf shell "dummy" "1.1.0"
  [ "$ASDF_DUMMY_VERSION" = "1.1.0" ]
  asdf shell "dummy" --unset
  [ -z "$ASDF_DUMMY_VERSION" ]
  unset ASDF_DUMMY_VERSION
}

@test "shell wrapper function should return an error for missing plugins" {
  . "$(dirname "$BATS_TEST_DIRNAME")/asdf.sh"
  expected="No such plugin: nonexistent
version 1.0.0 is not installed for nonexistent"

  run asdf shell "nonexistent" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "$expected" ]
}

@test "shell should emit an error when wrapper function is not loaded" {
  run asdf shell "dummy" "1.1.0"
  [ "$status" -eq 1 ]
  [ "$output" = "Shell integration is not enabled. Please ensure you source asdf in your shell setup." ]
}

@test "export-shell-version should emit an error when plugin does not exist" {
  expected="No such plugin: nonexistent
version 1.0.0 is not installed for nonexistent
false"

  run asdf export-shell-version sh "nonexistent" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "$expected" ]
}

@test "export-shell-version should emit an error when version does not exist" {
  expected="version nonexistent is not installed for dummy
false"

  run asdf export-shell-version sh "dummy" "nonexistent"
  [ "$status" -eq 1 ]
  [ "$output" = "$expected" ]
}

@test "export-shell-version should export version if it exists" {
  run asdf export-shell-version sh "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$output" = "export ASDF_DUMMY_VERSION=\"1.1.0\"" ]
}

@test "export-shell-version should use set when shell is fish" {
  run asdf export-shell-version fish "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$output" = "set -gx ASDF_DUMMY_VERSION \"1.1.0\"" ]
}

@test "export-shell-version should use set-env when shell is elvish" {
  run asdf export-shell-version elvish "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ "$output" = $'set-env\nASDF_DUMMY_VERSION\n1.1.0' ]
}

@test "export-shell-version should unset when --unset flag is passed" {
  run asdf export-shell-version sh "dummy" "--unset"
  [ "$status" -eq 0 ]
  [ "$output" = "unset ASDF_DUMMY_VERSION" ]
}

@test "export-shell-version should use set -e when --unset flag is passed and shell is fish" {
  run asdf export-shell-version fish "dummy" "--unset"
  [ "$status" -eq 0 ]
  [ "$output" = "set -e ASDF_DUMMY_VERSION" ]
}

@test "export-shell-version should use unset-env when --unset flag is passed and shell is elvish" {
  run asdf export-shell-version elvish "dummy" "--unset"
  [ "$status" -eq 0 ]
  [ "$output" = $'unset-env\nASDF_DUMMY_VERSION' ]
}

@test "[shell - dummy_plugin] wrapper function should support latest" {
  . "$(dirname "$BATS_TEST_DIRNAME")/asdf.sh"
  asdf shell "dummy" "latest"
  [ "$ASDF_DUMMY_VERSION" = "2.0.0" ]
  unset ASDF_DUMMY_VERSION
}

@test "[shell - dummy_legacy_plugin] wrapper function should support latest" {
  . "$(dirname "$BATS_TEST_DIRNAME")/asdf.sh"
  asdf shell "legacy-dummy" "latest"
  [ "$ASDF_LEGACY_DUMMY_VERSION" = "5.1.0" ]
  unset ASDF_LEGACY_DUMMY_VERSION
}

@test "[global - dummy_plugin] should support latest" {
  echo 'dummy 1.0.0' >>"$HOME/.tool-versions"
  run asdf global "dummy" "1.0.0" "latest"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = "dummy 1.0.0 2.0.0" ]
}

@test "[global - dummy_legacy_plugin] should support latest" {
  echo 'legacy-dummy 1.0.0' >>"$HOME/.tool-versions"
  run asdf global "legacy-dummy" "1.0.0" "latest"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.tool-versions")" = "legacy-dummy 1.0.0 5.1.0" ]
}

@test "[local - dummy_plugin] should support latest" {
  echo 'dummy 1.0.0' >>"$PROJECT_DIR/.tool-versions"
  run asdf local "dummy" "1.0.0" "latest"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "dummy 1.0.0 2.0.0" ]
}

@test "[local - dummy_legacy_plugin] should support latest" {
  echo 'legacy-dummy 1.0.0' >>"$PROJECT_DIR/.tool-versions"
  run asdf local "legacy-dummy" "1.0.0" "latest"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT_DIR/.tool-versions")" = "legacy-dummy 1.0.0 5.1.0" ]
}

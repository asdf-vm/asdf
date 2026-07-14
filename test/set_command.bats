#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version "1.0.0"
  install_dummy_version "1.1.0"

  PROJECT_DIR="$HOME/project"
  mkdir -p "$PROJECT_DIR"

  cd "$PROJECT_DIR" || exit
}

teardown() {
  clean_asdf_dir
}

@test "set should emit an error when called with incorrect arity" {
  run asdf set
  [ "$status" -eq 1 ]
  [ "$output" = "tool and version must be provided as arguments" ]
}

@test "set should emit an error when version is not provided" {
  run asdf set "dummy"
  [ "$status" -eq 1 ]
  [ "$output" = "version must be provided as an argument" ]
}

@test "set should create .tool-versions file in current directory" {
  run asdf set "dummy" "1.0.0"
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/.tool-versions" ]
  run cat "$PROJECT_DIR/.tool-versions"
  [ "$output" = "dummy 1.0.0" ]
}

@test "set should create .tool-versions file in home directory when --home flag is used" {
  run asdf set --home "dummy" "1.0.0"
  [ "$status" -eq 0 ]
  [ -f "$HOME/.tool-versions" ]
  run cat "$HOME/.tool-versions"
  [ "$output" = "dummy 1.0.0" ]
}

@test "set -u should be an alias for --home" {
  run asdf set -u "dummy" "1.0.0"
  [ "$status" -eq 0 ]
  [ -f "$HOME/.tool-versions" ]
  run cat "$HOME/.tool-versions"
  [ "$output" = "dummy 1.0.0" ]
}

@test "set should update parent directory .tool-versions when --parent flag is used" {
  echo "dummy 1.0.0" >"$PROJECT_DIR/.tool-versions"

  CHILD_DIR="$PROJECT_DIR/child"
  mkdir -p "$CHILD_DIR"
  cd "$CHILD_DIR"

  run asdf set --parent "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/.tool-versions" ]
  [ ! -f "$CHILD_DIR/.tool-versions" ]
  run cat "$PROJECT_DIR/.tool-versions"
  [ "$output" = "dummy 1.1.0" ]
}

@test "set -p should be an alias for --parent" {
  echo "dummy 1.0.0" >"$PROJECT_DIR/.tool-versions"

  CHILD_DIR="$PROJECT_DIR/child"
  mkdir -p "$CHILD_DIR"
  cd "$CHILD_DIR"

  run asdf set -p "dummy" "1.1.0"
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/.tool-versions" ]
  [ ! -f "$CHILD_DIR/.tool-versions" ]
  run cat "$PROJECT_DIR/.tool-versions"
  [ "$output" = "dummy 1.1.0" ]
}

@test "set should emit an error when both --home and --parent flags are used" {
  run asdf set --home --parent "dummy" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "home and parent flags cannot both be specified; must be one location or the other" ]
}

@test "set should emit an error when --parent is used but no .tool-versions file exists in parent directory" {
  CHILD_DIR="$PROJECT_DIR/child"
  mkdir -p "$CHILD_DIR"
  cd "$CHILD_DIR"

  run asdf set --parent "dummy" "1.0.0"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No .tool-versions version file found in parent directory"* ]]
}

@test "set with -h flag should show error for undefined flag" {
  run asdf set -h "dummy" "1.0.0"
  [ "$status" -eq 1 ]
  [[ "$output" == *"flag provided but not defined: -h"* ]]
}

@test "set should support multiple versions" {
  run asdf set "dummy" "1.0.0" "1.1.0"
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/.tool-versions" ]
  run cat "$PROJECT_DIR/.tool-versions"
  [ "$output" = "dummy 1.0.0 1.1.0" ]
}

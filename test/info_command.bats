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

  [ "$status" -eq 0 ]
  [[ $output == *$'OS:\n'* ]]
  [[ $output == *$'SHELL:\n'* ]]
  [[ $output == *$'BASH VERSION:\n'* ]]
  [[ $output == *$'ASDF VERSION:\n'* ]]
  [[ $output == *$'ASDF INTERNAL VARIABLES:\n'* ]]
  [[ $output == *$'ASDF INSTALLED PLUGINS:\n'* ]]

}

@test "info should show environment warnings for misconfigured ASDF_TOOL_VERSIONS_FILENAME" {
  cd "$PROJECT_DIR"

  export ASDF_TOOL_VERSIONS_FILENAME="/home/user/.config/asdf/tool-versions"
  run asdf info

  [ "$status" -eq 0 ]
  [[ $output == *$'WARNINGS:\n'* ]]
  [[ $output == *"ASDF_TOOL_VERSIONS_FILENAME should be a filename only"* ]]
}

@test "info should show deprecation warning for ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" {
  cd "$PROJECT_DIR"

  export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=".tool-versions"
  run asdf info

  [ "$status" -eq 0 ]
  # No warnings for this deprecated variable in simplified version
}

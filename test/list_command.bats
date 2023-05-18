#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_broken_plugin

  PROJECT_DIR="$HOME/project"
  mkdir -p "$PROJECT_DIR"
}

teardown() {
  clean_asdf_dir
}

@test "list_command should list plugins with installed versions" {
  run asdf install dummy 1.0.0
  run asdf install dummy 1.1.0
  run asdf list
  [[ "$output" == *$'dummy\n  1.0.0\n  1.1.0'* ]]
  [[ "$output" == *$'dummy-broken\n  No versions installed'* ]]
  [ "$status" -eq 0 ]
}

@test "list_command should list plugins with installed versions and any selected versions marked with asterisk" {
  cd "$PROJECT_DIR"
  echo 'dummy 1.1.0' >>"$PROJECT_DIR/.tool-versions"
  run asdf install dummy 1.0.0
  run asdf install dummy 1.1.0

  run asdf list
  [[ "$output" == *$'dummy\n  1.0.0\n *1.1.0'* ]]
  [[ "$output" == *$'dummy-broken\n  No versions installed'* ]]
  [ "$status" -eq 0 ]
}

@test "list_command should continue listing even when no version is installed for any of the plugins" {
  run install_mock_plugin "dummy"
  run install_mock_plugin "mummy"
  run install_mock_plugin "tummy"
  run asdf install dummy 1.0.0
  run asdf install tummy 2.0.0
  run asdf list
  [[ "$output" == *$'dummy\n  1.0.0'* ]]
  [[ "$output" == *$'dummy-broken\n  No versions installed'* ]]
  [[ "$output" == *$'mummy\n  No versions installed'* ]]
  [[ "$output" == *$'tummy\n  2.0.0'* ]]
  [ "$status" -eq 0 ]
}

@test "list_command with plugin should list installed versions" {
  run asdf install dummy 1.0.0
  run asdf install dummy 1.1.0
  run asdf list dummy
  [ $'  1.0.0\n  1.1.0' = "$output" ]
  [ "$status" -eq 0 ]
}

@test "list_command with version filters installed versions" {
  run asdf install dummy 1.0
  run asdf install dummy 1.1
  run asdf install dummy 2.0
  run asdf list dummy 1
  [ $'  1.0\n  1.1' = "$output" ]
  [ "$status" -eq 0 ]
}

@test "list_command with an invalid version should return an error" {
  run asdf install dummy 1.0
  run asdf install dummy 1.1
  run asdf list dummy 2
  [ "No compatible versions installed (dummy 2)" = "$output" ]
  [ "$status" -eq 1 ]
}

@test "list_all_command lists available versions" {
  run asdf list-all dummy
  [ $'1.0.0\n1.1.0\n2.0.0' = "$output" ]
  [ "$status" -eq 0 ]
}

@test "list_all_command with version filters available versions" {
  run asdf list-all dummy 1
  [ $'1.0.0\n1.1.0' = "$output" ]
  [ "$status" -eq 0 ]
}

@test "list_all_command with an invalid version should return an error" {
  run asdf list-all dummy 3
  [ "No compatible versions available (dummy 3)" = "$output" ]
  [ "$status" -eq 1 ]
}

@test "list_all_command fails when list-all script exits with non-zero code" {
  run asdf list-all dummy-broken
  [ "$status" -eq 1 ]
  [[ "$output" == "Plugin dummy-broken's list-all callback script failed with output:"* ]]
}

@test "list_all_command displays stderr then stdout when failing" {
  run asdf list-all dummy-broken
  [[ "$output" == *"List-all failed!"* ]]
  [[ "$output" == *"Attempting to list versions" ]]
}

@test "list_all_command ignores stderr when completing successfully" {
  run asdf list-all dummy
  [[ "$output" != *"ignore this error"* ]]
}

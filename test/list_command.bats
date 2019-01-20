#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
}

teardown() {
  clean_asdf_dir
}

@test "list_command should list plugins with installed versions" {
  run asdf install dummy 1.0
  run asdf install dummy 1.1
  run asdf list
  [ "$(echo -e "dummy\n  1.0\n  1.1")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "list_command should continue listing even when no version is installed for any of the plugins" {
  run install_mock_plugin "dummy"
  run install_mock_plugin "mummy"
  run install_mock_plugin "tummy"
  run asdf install dummy 1.0
  run asdf install tummy 2.0
  run asdf list
  [ "$(echo -e "dummy\n  1.0\nmummy\nNo versions installed\ntummy\n  2.0")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "list_command with plugin should list installed versions" {
  run asdf install dummy 1.0
  run asdf install dummy 1.1
  run asdf list dummy
  [ "$(echo -e "  1.0\n  1.1")" == "$output" ]
  [ "$status" -eq 0 ]
}

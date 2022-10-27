#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
}

teardown() {
  clean_asdf_dir
}

@test "plugin_remove command removes the plugin directory" {
  run asdf install dummy 1.0
  [ "$status" -eq 0 ]
  [ -d "$ASDF_DIR/downloads/dummy" ]

  run asdf plugin-remove "dummy"
  [ "$status" -eq 0 ]
  [ ! -d "$ASDF_DIR/downloads/dummy" ]
}

@test "plugin_remove command fails if the plugin doesn't exist" {
  run asdf plugin-remove "does-not-exist"
  [ "$status" -eq 1 ]
  echo "$output" | grep "No such plugin: does-not-exist"
}

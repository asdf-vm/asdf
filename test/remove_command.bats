#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "plugin_remove_command removes a plugin" {
  install_dummy_plugin

  run asdf plugin-remove "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "plugin_remove_command should exit with 1 when not passed any arguments" {
  run asdf plugin-remove
  [ "$status" -eq 1 ]
  [ "$output" = "No plugin given" ]
}

@test "plugin_remove_command should exit with 1 when passed invalid plugin name" {
  run asdf plugin-remove "does-not-exist"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin: does-not-exist" ]
}

@test "plugin_remove_command should remove installed versions" {
  install_dummy_plugin
  run asdf install dummy 1.0
  [ "$status" -eq 0 ]
  [ -d $ASDF_DIR/installs/dummy ]

  run asdf plugin-remove dummy
  [ "$status" -eq 0 ]
  [ ! -d $ASDF_DIR/installs/dummy ]
}

@test "plugin_remove_command should also remove shims for that plugin" {
  install_dummy_plugin
  run asdf install dummy 1.0
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/shims/dummy ]

  run asdf plugin-remove dummy
  [ "$status" -eq 0 ]
  [ ! -f $ASDF_DIR/shims/dummy ]
}


@test "plugin_remove_command should not remove unrelated shims" {
  install_dummy_plugin
  run asdf install dummy 1.0

  # make an unrelated shim
  echo "# asdf-plugin: gummy" > $ASDF_DIR/shims/gummy

  run asdf plugin-remove dummy
  [ "$status" -eq 0 ]

  # unrelated shim should exist
  [ -f $ASDF_DIR/shims/gummy ]
}

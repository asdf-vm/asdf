#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/reshim.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/install.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}


@test "reshim command should remove shims of removed binaries" {
  run install_command dummy 1.0
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]

  run reshim_command dummy
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]

  run rm "$ASDF_DIR/installs/dummy/1.0/bin/dummy"
  run reshim_command dummy
  [ "$status" -eq 0 ]
  [ ! -f "$ASDF_DIR/shims/dummy" ]
}

@test "reshim should remove metadata of removed binaries" {
  run install_command dummy 1.0
  run install_command dummy 1.1

  run rm "$ASDF_DIR/installs/dummy/1.0/bin/dummy"
  run reshim_command dummy
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]
  run grep "asdf-plugin-version: 1.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 1 ]
  run grep "asdf-plugin-version: 1.1" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]
}

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

@test "install_command installs the correct version" {
  run install_command dummy 1.1
  [ "$status" -eq 0 ]
  [ $(cat $ASDF_DIR/installs/dummy/1.1/version) = "1.1" ]
}

@test "install_command set ASDF_CONCURRENCY" {
  run install_command dummy 1.0
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/installs/dummy/1.0/env ]
  run grep ASDF_CONCURRENCY $ASDF_DIR/installs/dummy/1.0/env
  [ "$status" -eq 0 ]
}

@test "install_command should work in directory containing whitespace" {
  WHITESPACE_DIR="$PROJECT_DIR/whitespace\ dir"
  mkdir -p "$WHITESPACE_DIR"
  cd "$WHITESPACE_DIR"
  echo 'dummy 1.2' >> "$WHITESPACE_DIR/.tool-versions"

  run install_command

  [ "$status" -eq 0 ]
  [ $(cat $ASDF_DIR/installs/dummy/1.2/version) = "1.2" ]
}

@test "install_command should create a shim with metadada" {
  run install_command dummy 1.0
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/installs/dummy/1.0/env ]
  run grep "asdf-plugin: dummy" $ASDF_DIR/shims/dummy
  [ "$status" -eq 0 ]
}


@test "install_command running a shim should call the plugin executable" {
  run install_command dummy 1.0
  [ "$status" -eq 0 ]
  # run the shim which should be on path and expect the plugin's output
  [ "dummy" $(dummy) ]
}

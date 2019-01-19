#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/shim_versions.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/reshim.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/install.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  mkdir -p $PROJECT_DIR
  cd $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "shim_versions_command should list plugins and versions where command is available" {
  cd $PROJECT_DIR
  run install_command dummy 3.0
  run install_command dummy 1.0
  run reshim_command dummy

  run shim_versions_command dummy
  [ "$status" -eq 0 ]

  echo "$output" | grep "dummy 3.0"
  echo "$output" | grep "dummy 1.0"
}

#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/which.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/install.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_mock_plugin "bazbat"
  run install_command dummy 1.0

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "which should show dummy 1.0 main binary path" {
  cd $PROJECT_DIR

  echo 'dummy 1.0' >> $PROJECT_DIR/.tool-versions

  run which_command "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/1.0/bin/dummy" ]
}

@test "which should inform when no version is set" {
  cd $PROJECT_DIR

  local expected
  expected="No version set for bazbat; please run \`asdf <global | local> bazbat <version>\`"

  run which_command "bazbat"
  [ "$status" -eq 1 ]
  [ "$output" = "$expected" ]
}

@test "which should error when the plugin doesn't exist" {
  run which_command "foobar"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin" ]
}

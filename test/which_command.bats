#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/which.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/install.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin
  run install_command dummy 1.0

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
  echo 'dummy 1.0' >> $PROJECT_DIR/.tool-versions
}

teardown() {
  clean_asdf_dir
}

@test "which should show dummy 1.0 main binary" {
  cd $PROJECT_DIR

  run which_command "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/1.0/bin/dummy" ]
}

@test "which should show dummy 1.0 other binary" {
  cd $PROJECT_DIR

  run which_command "other_bin"
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/1.0/bin/subdir/other_bin" ]
}

@test "which should ignore system version" {
  echo 'dummy system 1.0' > $PROJECT_DIR/.tool-versions
  cd $PROJECT_DIR

  run which_command "other_bin"
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/1.0/bin/subdir/other_bin" ]
}

@test "which should inform when no binary is found" {
  cd $PROJECT_DIR

  run which_command "bazbat"
  [ "$status" -eq 1 ]
  [ "$output" = "No executable binary found for bazbat" ]
}

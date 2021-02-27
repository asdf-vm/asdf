#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version "1.1.0"

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "check should return with exit code 0 when installed versions match" {
  cd $PROJECT_DIR
  echo 'dummy 1.1.0' >> $PROJECT_DIR/.tool-versions

  run asdf check
  [ "$status" -eq 0 ]
}

@test "check should return with exit code 1 when installed versions do not match" {
  cd $PROJECT_DIR
  echo "dummy 1.2.0" >> $PROJECT_DIR/.tool-versions

  run asdf check
  [ "$status" -eq 1 ]
}

@test "check should return with exit code 0 when no local versions specified" {
  cd $PROJECT_DIR

  run asdf check
  [ "$status" -eq 0 ]
}

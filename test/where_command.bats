#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/where.sh

function setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version 1.0
  install_dummy_version 2.1
  install_dummy_version ref-master
}

function teardown() {
  clean_asdf_dir
}

@test "where shows install location of selected version" {
  run where_command 'dummy' '1.0'
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/1.0" ]
}

@test "where understands versions installed by ref" {
  run where_command 'dummy' 'ref:master'
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/ref-master" ]
}

@test "where shows install location of current version if no version specified" {
  echo 'dummy 2.1' >> $HOME/.tool-versions

  run where_command 'dummy'

  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/2.1" ]
}

@test "where should error when the plugin doesn't exist" {
  run where_command "foobar"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin: foobar" ]
}

@test "where should error when version is not installed" {
  run where_command 'dummy' '1.6'
  [ "$status" -eq 1 ]
  [ "$output" = "Version not installed" ]
}

@test "where should error when no current version selected and version not specified" {
  run where_command 'dummy'

  local expected
  expected="No version set for dummy; please run \`asdf <global | local> dummy <version>\`"

  [ "$status" -eq 1 ]
  [ "$output" = "$expected" ]
}

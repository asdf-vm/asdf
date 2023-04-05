#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version 1.0
  install_dummy_version 2.1
  install_dummy_version ref-master
}

teardown() {
  clean_asdf_dir
}

@test "where shows install location of selected version" {
  run asdf where 'dummy' '1.0'
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/1.0" ]
}

@test "where understands versions installed by ref" {
  run asdf where 'dummy' 'ref:master'
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/ref-master" ]
}

@test "where shows install location of current version if no version specified" {
  echo 'dummy 2.1' >>"$HOME/.tool-versions"

  run asdf where 'dummy'

  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/2.1" ]
}

@test "where shows install location of first current version if not version specified and multiple current versions" {
  echo 'dummy 2.1 1.0' >>"$HOME/.tool-versions"
  run asdf where 'dummy'
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/2.1" ]
}

@test "where should error when the plugin doesn't exist" {
  run asdf where "foobar"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin: foobar" ]
}

@test "where should error when version is not installed" {
  run asdf where 'dummy' '1.6'
  [ "$status" -eq 1 ]
  [ "$output" = "Version not installed" ]
}

@test "where should error when system version is set" {
  run asdf where 'dummy' 'system'
  [ "$status" -eq 1 ]
  [ "$output" = "System version is selected" ]
}

@test "where should error when no current version selected and version not specified" {
  run asdf where 'dummy'

  local expected
  expected="No version is set for dummy; please run \`asdf <global | shell | local> dummy <version>\`"

  [ "$status" -eq 1 ]
  [ "$output" = "$expected" ]
}

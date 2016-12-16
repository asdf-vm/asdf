#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/install.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/list.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin
}

teardown() {
  clean_asdf_dir
}

@test "list_command should output error when plugin is not installed" {
  run list_command dummy
  [ "No versions installed" == "$output" ]
  [ "$status" -eq 1 ]
}

@test "list_command should list installed versions" {
  run install_command dummy 1.0
  run install_command dummy 1.1
  run list_command dummy
  [ "$(echo -e "1.0\n1.1")" == "$output" ]
  [ "$status" -eq 0 ]
}

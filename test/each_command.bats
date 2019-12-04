#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
}

teardown() {
  clean_asdf_dir
}

@test "each_command should execute given command with all installed versions" {
  run asdf install dummy 1.0
  run asdf install dummy 1.1
  run asdf each dummy sh -c 'echo $ASDF_DUMMY_VERSION'
  [ "$(echo -e "## dummy 1.0 ##\n1.0\n## dummy 1.1 ##\n1.1\n")" == "$output" ]
  [ "$status" -eq 0 ]
}

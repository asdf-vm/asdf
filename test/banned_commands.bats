#!/usr/bin/env bats

load test_helpers

banned_commands=(realpath eval)

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "banned commands are not found in source code" {
  for cmd in "${banned_commands[@]}"; do
      # Assert command is not used in the lib and bin dirs
      run grep -nHR "$cmd" lib bin
      [ "$status" -eq 1 ]
      [ "$output" = "" ]
  done
}

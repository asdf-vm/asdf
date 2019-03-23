#!/usr/bin/env bats

load test_helpers

banned_commands=(
    realpath
    # readlink on OSX behaves differently from readlink on other Unix systems
    readlink
    # It's best to avoid eval as it makes it easier to accidentally execute
    # arbitrary strings
    eval

    # does not work on alpine and should be grep -i either way
    "grep -y"
    )

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

#!/usr/bin/env bats

load test_helpers

banned_commands=(
    realpath
    # readlink on OSX behaves differently from readlink on other Unix systems
    readlink
    # It's best to avoid eval as it makes it easier to accidentally execute
    # arbitrary strings
    eval
    # Command isn't included in the Ubuntu packages asdf depends on. Also not
    # defined in POSIX
    column
    # does not work on alpine and should be grep -i either way
    "grep.* -y"
    # sort -V isn't supported everywhere
    "sort.*-V"
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
      # or expect an explicit comment at end of line, allowing it.
      run bash -c "grep -nHR '$cmd' lib bin | grep -v '# asdf_allow: $cmd'"
      echo "banned command $cmd: $output"
      [ "$status" -eq 1 ]
      [ "" == "$output" ]
  done
}

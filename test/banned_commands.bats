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
    # sort --sort-version isn't supported everywhere
    "sort.*-V"
    "sort.*--sort-versions"
    # echo isn't consistent across operating systems, and sometimes output can
    # be confused with echo flags. printf does everything echo does and more.
    echo
    # Process substitution isn't POSIX compliant and cause trouble
    "<("
    # source isn't POSIX compliant. . behaves the same and is POSIX compliant
    source
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
      # Also ignore matches that are contained in comments or a string or
      # followed by an underscore (indicating it's a variable and not a
      # command).
      run bash -c "grep -nHR '$cmd' lib bin\
        | grep -v '#.*$cmd'\
        | grep -v '\".*$cmd.*\"' \
        | grep -v '${cmd}_'\
        | grep -v '# asdf_allow: $cmd'"

      # Only print output if we've found a banned command
      if [ "$status" -ne 1 ]; then
        echo "banned command $cmd: $output"
      fi

      [ "$status" -eq 1 ]
      [ "" == "$output" ]
  done
}

#!/usr/bin/env bats

load test_helpers

cleaned_path() {
  echo "$PATH" | tr ':' '\n' | grep -v "asdf" | tr '\n' ':'
}

@test "exports ASDF_DIR" {
  output=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    echo "$ASDF_DIR"
  )

  result=$(echo "$output" | grep "asdf")
  [ "$result" != "" ]
}

@test "does not error if nounset is enabled" {
  output=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)
    set -o nounset

    echo "$ASDF_DIR"
  )

  result=$(echo "$output" | grep "asdf")
  [ "$result" != "" ]
}

@test "adds asdf dirs to PATH" {
  output=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    echo "$PATH"
  )

  result=$(echo "$output" | grep "asdf")
  [ "$result" != "" ]
}

@test "does not add paths to PATH more than once" {
  output=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    echo "$PATH"
  )

  result=$(echo "$output" | tr ':' '\n' | grep "asdf" | sort | uniq -d)
  [ "$result" = "" ]
}

@test "defines the asdf function" {
  output=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    type asdf
  )

  [[ "$output" =~ "is a function" ]]
}

@test "function calls asdf command" {
  result=$(
    unset -f asdf
    ASDF_DIR=$PWD
    PATH=$(cleaned_path)

    asdf info
  )

  output=$(echo "$result" | grep "ASDF INSTALLED PLUGINS:")
  [ "$output" != "" ]
}

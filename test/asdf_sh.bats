#!/usr/bin/env bats

load test_helpers

# Helper function to handle sourcing of asdf.sh
source_asdf_sh() {
  . "$(dirname "$BATS_TEST_DIRNAME")/asdf.sh"
}

cleaned_path() {
  echo "$PATH" | tr ':' '\n' | grep -v "asdf" | tr '\n' ':'
}

@test "exports ASDF_DIR" {
  result=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    source_asdf_sh
    echo "$ASDF_DIR"
  )

  run grep 'asdf' <<<"$result"
  [ "$status" -eq 0 ]
  [ "$output" != "" ]
}

@test "does not error if nounset is enabled" {
  result=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)
    set -o nounset

    source_asdf_sh
    echo "$ASDF_DIR"
  )

  run grep 'asdf' <<<"$result"
  [ "$status" -eq 0 ]
  [ "$output" != "" ]
}

@test "adds asdf dirs to PATH" {
  result=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    source_asdf_sh
    echo "$PATH"
  )

  run grep 'asdf' <<<"$result"
  [ "$status" -eq 0 ]
  [ "$output" != "" ]
}

@test "does not add paths to PATH more than once" {
  result=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    source_asdf_sh
    source_asdf_sh
    echo "$PATH"
  )

  output=$(echo "$result" | tr ':' '\n' | grep "asdf" | sort | uniq -d)
  [ "$output" = "" ]
}

@test "defines the asdf function" {
  output=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    source_asdf_sh
    type asdf
  )

  [[ "$output" =~ "is a function" ]]
}

@test "function calls asdf command" {
  result=$(
    unset -f asdf
    ASDF_DIR=$PWD
    PATH=$(cleaned_path)

    source_asdf_sh
    asdf info
  )

  output=$(echo "$result" | grep "ASDF INSTALLED PLUGINS:")
  [ "$output" != "" ]
}

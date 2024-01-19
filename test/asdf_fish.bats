#!/usr/bin/env bats
# shellcheck disable=SC2164

load test_helpers

setup() {
  cd "$(dirname "$BATS_TEST_DIRNAME")"

  if ! command -v fish &>/dev/null && [ -z "$GITHUB_ACTIONS" ]; then
    skip "Fish is not installed"
  fi
}

cleaned_path() {
  echo "$PATH" | tr ':' '\n' | grep -v "asdf" | tr '\n' ' '
}

@test "exports ASDF_DIR" {
  run fish --no-config -c "
    set -e asdf
    set -e ASDF_DIR
    set -e ASDF_DATA_DIR
    set PATH $(cleaned_path)

    . asdf.fish
    echo \$ASDF_DIR"

  [ "$status" -eq 0 ]
  [ "$output" != "" ]
}

@test "adds asdf dirs to PATH" {
  run fish --no-config -c "
    set -e asdf
    set -e ASDF_DIR
    set -e ASDF_DATA_DIR
    set PATH $(cleaned_path)

    . (pwd)/asdf.fish  # if the full path is not passed, status -f will return the relative path
    echo \$PATH"

  [ "$status" -eq 0 ]

  result=$(echo "$output" | grep "asdf")
  [ "$result" != "" ]
}

@test "does not add paths to PATH more than once" {
  run fish --no-config -c "
    set -e asdf
    set -e ASDF_DIR
    set -e ASDF_DATA_DIR
    set PATH $(cleaned_path)

    . asdf.fish
    . asdf.fish
    echo \$PATH"

  [ "$status" -eq 0 ]

  result=$(echo "$output" | tr ' ' '\n' | grep "asdf" | sort | uniq -d)
  [ "$result" = "" ]
}

@test "defines the asdf function" {
  run fish --no-config -c "
    set -e asdf
    set -e ASDF_DIR
    set PATH $(cleaned_path)

    . asdf.fish
    type asdf"

  [ "$status" -eq 0 ]
  [[ "$output" =~ "is a function" ]]
}

@test "function calls asdf command" {
  run fish --no-config -c "
    set -e asdf
    set -x ASDF_DIR $(pwd) # checkstyle-ignore
    set PATH $(cleaned_path)

    . asdf.fish
    asdf info"

  [ "$status" -eq 0 ]

  result=$(echo "$output" | grep "ASDF INSTALLED PLUGINS:")
  [ "$result" != "" ]
}

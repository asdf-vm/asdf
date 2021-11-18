#!/usr/bin/env bats

load test_helpers

setup() {
  cd $(dirname "$BATS_TEST_DIRNAME")
}

cleaned_path() {
  echo $PATH | tr ':' '\n' | grep -v "asdf" | tr '\n' ' '
}

@test "exports ASDF_DIR" {
  output=$(fish -c "
    set -e asdf
    set -e ASDF_DIR
    set -e ASDF_DATA_DIR
    set PATH $(cleaned_path)

    . asdf.fish
    echo \$ASDF_DIR
  ")
  [ "$?" -eq 0 ]
  [ "$output" != "" ]
}

@test "adds asdf dirs to PATH" {
 result=$(fish -c "
   set -e asdf
   set -e ASDF_DIR
   set -e ASDF_DATA_DIR
   set PATH $(cleaned_path)

   . (pwd)/asdf.fish  # if the full path is not passed, status -f will return the relative path
   echo \$PATH
 ")
 [ "$?" -eq 0 ]
 output=$(echo "$result" | grep "asdf")
 [ "$output" != "" ]
}

@test "does not add paths to PATH more than once" {
  result=$(fish -c "
    set -e asdf
    set -e ASDF_DIR
    set -e ASDF_DATA_DIR
    set PATH $(cleaned_path)

    . asdf.fish
    . asdf.fish
    echo \$PATH
  ")
  [ "$?" -eq 0 ]
  output=$(echo $PATH | tr ':' '\n' | grep "asdf" | sort | uniq -d)
  [ "$output" = "" ]
}

@test "defines the asdf function" {
  output=$(fish -c "
    set -e asdf
    set -e ASDF_DIR
    set PATH $(cleaned_path)

    . asdf.fish
    type asdf
  ")
  [ "$?" -eq 0 ]
  [[ "$output" =~ "is a function" ]]
}

@test "function calls asdf command" {
  result=$(fish -c "
    set -e asdf
    set -x ASDF_DIR $(pwd)
    set PATH $(cleaned_path)

    . asdf.fish
    asdf info
  ")
  [ "$?" -eq 0 ]
  output=$(echo "$result" | grep "ASDF INSTALLED PLUGINS:")
  [ "$output" != "" ]
}


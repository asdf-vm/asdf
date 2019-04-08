#!/usr/bin/env bats

load test_helpers

setup() {
  cd $(dirname "$BATS_TEST_DIRNAME")
}

cleaned_path() {
  echo $PATH | tr ':' '\n' | grep -v "asdf" | tr '\n' ' '
}

@test "exports ASDF_DIR" {
  result=$(fish -c "
    set -e asdf
    set -e ASDF_DIR
    set -e ASDF_DATA_DIR
    set PATH $(cleaned_path)

    source asdf.fish
    echo \$ASDF_DIR
  ")

  [ "$?" -eq 0 ]
  [ "$result" != "" ]
}

@test "adds asdf dirs to PATH" {
 result=$(fish -c "
   set -e asdf
   set -e ASDF_DIR
   set -e ASDF_DATA_DIR
   set PATH $(cleaned_path)

   source (pwd)/asdf.fish  # if the full path is not passed, status -f will return the relative path
   echo \$PATH
 ")

 output=$(echo "$result" | grep "asdf")
 [ "$?" -eq 0 ]
 [ "$output" != "" ]
}

@test "does not add paths to PATH more than once" {
  result=$(fish -c "
    set -e asdf
    set -e ASDF_DIR
    set -e ASDF_DATA_DIR
    set PATH $(cleaned_path)

    source asdf.fish
    source asdf.fish
    echo \$PATH
  ")

  output=$(echo $PATH | tr ':' '\n' | grep "asdf" | sort | uniq -d)
  [ "$?" -eq 0 ]
  [ "$output" = "" ]
}

@test "defines the asdf function" {
  output=$(fish -c "
    set -e asdf
    set -e ASDF_DIR
    set PATH $(cleaned_path)

    source asdf.fish
    type asdf
  ")

  echo $output
  [[ "$output" =~ "is a function" ]]
}

#!/usr/bin/env bats

load test_helpers

setup() {
  cd $(dirname "$BATS_TEST_DIRNAME")
  cp ../asdf.elv $HOME/.elvish/lib/asdftest.elv
}

teardown() {
  rm $HOME/.elvish/lib/asdftest.elv
}

cleaned_path() {
  echo $PATH | tr ':' '\n' | grep -v "asdf" | tr '\n' ' '
}

@test "exports ASDF_DIR" {
  result=$(elvish --norc -c "
    unset-env ASDF_DIR ASDF_DATA_DIR
    set-env PATH $(cleaned_path)
    use asdftest _asdf; fn asdf [@args]{_asdf:asdf \$@args}
    get-env ASDF_DIR
  ")

  [ "$?" -eq 0 ]
  [ "$result" != "" ]
}

@test "adds asdf dirs to PATH" {
  result=$(elvish --norc -c "
    unset-env ASDF_DIR ASDF_DATA_DIR
    set-env PATH $(cleaned_path)
    use asdftest _asdf; fn asdf [@args]{_asdf:asdf \$@args}
    get-env PATH
  ")

  output=$(echo "$result" | grep "asdf")
  [ "$?" -eq 0 ]
  [ "$output" != "" ]
}

@test "defines the _asdf namespace" {
  result=$(elvish --norc -c "
    unset-env ASDF_DIR ASDF_DATA_DIR
    set-env PATH $(cleaned_path)
    use asdftest _asdf; fn asdf [@args]{_asdf:asdf \$@args}
    pprint \$_asdf:
  ")

  [[ "$output" =~ "<ns " ]]
}

@test "defines the asdf function" {
  result=$(elvish --norc -c "
    unset-env ASDF_DIR ASDF_DATA_DIR
    set-env PATH $(cleaned_path)
    use asdftest _asdf; fn asdf [@args]{_asdf:asdf \$@args}
    pprint \$asdf~
  ")

  [[ "$output" =~ "<closure " ]]
}

#!/usr/bin/env bats

load test_helpers

setup() {
  cd $(dirname "$BATS_TEST_DIRNAME")
  mkdir -p $HOME/.elvish/lib
  cp ./asdf.elv $HOME/.elvish/lib/asdftest.elv
}

teardown() {
  rm $HOME/.elvish/lib/asdftest.elv
}

cleaned_path() {
  echo $PATH | tr ':' '\n' | grep -v "asdf" | tr '\n' ' '
}

@test "exports ASDF_DIR" {
  output=$(elvish -norc -c "
    unset-env ASDF_DIR
    paths = [$(cleaned_path)]
    use asdftest _asdf; fn asdf [@args]{_asdf:asdf \$@args}
    echo \$E:ASDF_DIR
  ")
  [ "$?" -eq 0 ]
  [ "$output" = "$HOME/.asdf" ]
}

@test "retains ASDF_DIR" {
  output=$(elvish -norc -c "
    set-env ASDF_DIR "/path/to/asdf"
    paths = [$(cleaned_path)]
    use asdftest _asdf; fn asdf [@args]{_asdf:asdf \$@args}
    echo \$E:ASDF_DIR
  ")
  [ "$?" -eq 0 ]
  [ "$output" = "/path/to/asdf" ]
}

@test "retains ASDF_DATA_DIR" {
  output=$(elvish -norc -c "
    set-env ASDF_DATA_DIR "/path/to/asdf-data"
    paths = [$(cleaned_path)]
    use asdftest _asdf; fn asdf [@args]{_asdf:asdf \$@args}
    echo \$E:ASDF_DATA_DIR
  ")
  [ "$?" -eq 0 ]
  [ "$output" = "/path/to/asdf-data" ]
}

@test "adds asdf dirs to PATH" {
  result=$(elvish -norc -c "
    unset-env ASDF_DIR
    paths = [$(cleaned_path)]
    use asdftest _asdf; fn asdf [@args]{_asdf:asdf \$@args}
    echo \$E:PATH
  ")
  [ "$?" -eq 0 ]
  echo "$result"
  output=$(echo "$result" | grep "asdf")
  [ "$output" != "" ]
}

@test "defines the _asdf namespace" {
  output=$(elvish -norc -c "
    unset-env ASDF_DIR
    paths = [$(cleaned_path)]
    use asdftest _asdf; fn asdf [@args]{_asdf:asdf \$@args}
    pprint \$_asdf:
  ")
  [ "$?" -eq 0 ]
  [[ "$output" =~ "<ns " ]]
}

@test "defines the asdf function" {
  output=$(elvish -norc -c "
    unset-env ASDF_DIR
    paths = [$(cleaned_path)]
    use asdftest _asdf; fn asdf [@args]{_asdf:asdf \$@args}
    pprint \$asdf~
  ")
  [ "$?" -eq 0 ]
  echo "$output"
  [[ "$output" =~ "<closure " ]]
}

@test "function calls asdf command" {
  result=$(elvish -norc -c "
    set-env ASDF_DIR $(pwd)
    paths = [$(cleaned_path)]
    use asdftest _asdf; fn asdf [@args]{_asdf:asdf \$@args}
    asdf info
  ")
  [ "$?" -eq 0 ]
  output=$(echo "$result" | grep "ASDF INSTALLED PLUGINS:")
  [ "$output" != "" ]
}

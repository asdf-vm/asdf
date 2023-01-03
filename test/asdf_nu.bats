#!/usr/bin/env bats

load test_helpers

setup() {
  cd $(dirname "$BATS_TEST_DIRNAME")
}

cleaned_path() {
  echo $PATH | tr ':' '\n' | grep -v "asdf" | tr '\n' ':'
}

@test "exports ASDF_DIR" {
  output=$(nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )

    source asdf.nu

    echo \$env.ASDF_DIR
  ")

  [ "$?" -eq 0 ]
  [ "$output" = "$HOME/.asdf" ]
}

@test "adds asdf dirs to PATH" {
  result=$(nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )

    source asdf.nu

    echo \$env.PATH
 ")
  [ "$?" -eq 0 ]
  output=$(echo "$result" | grep "asdf")
  [ "$output" != "" ]
}

@test "does not add paths to PATH more than once" {
  result=$(nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )

    source asdf.nu
    source asdf.nu

    echo \$env.PATH
  ")
  [ "$?" -eq 0 ]
  output=$(echo $result | tr ' ' '\n' | grep "asdf" | sort | uniq -d)
  [ "$output" = "" ]
}

@test "retains ASDF_DIR" {
  output=$(nu -c "
    hide-env -i asdf
    let-env ASDF_DIR = ( pwd )
    let-env PATH = ( '$(cleaned_path)' | split row ':' )

    source asdf.nu

    echo \$env.ASDF_DIR
  ")

  [ "$?" -eq 0 ]
  [ "$output" = "$PWD" ]
}

@test "defines the asdf function" {
  output=$(nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )

    source asdf.nu
    help commands | where name == asdf  | get command_type | to text
  ")
  [ "$?" -eq 0 ]
  [[ "$output" =~ "external" ]]
}

@test "function calls asdf command" {
  result=$(nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )

    source asdf.nu
    asdf info
  ")
  [ "$?" -eq 0 ]
  output=$(echo "$result" | grep "ASDF INSTALLED PLUGINS:")
  [ "$output" != "" ]
}

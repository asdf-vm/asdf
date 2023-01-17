#!/usr/bin/env bats

load test_helpers

setup() {
  cd $(dirname "$BATS_TEST_DIRNAME")

  if ! command -v nu; then
    skip "Nu is not installed"
  fi
}

cleaned_path() {
  echo $PATH | tr ':' '\n' | grep -v "asdf" | tr '\n' ':'
}

@test "exports ASDF_DIR" {
  result=$(nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )
    let-env ASDF_NU_DIR = '$PWD'

    source asdf.nu

    echo \$env.ASDF_DIR
  ")

  [ "$?" -eq 0 ]
  output=$(echo "$result" | grep "asdf")
  [ "$output" = $PWD ]
}

@test "adds asdf dirs to PATH" {
  result=$(nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )
    let-env ASDF_NU_DIR = '$PWD'

    source asdf.nu


    \$env.PATH | to text
 ")
  [ "$?" -eq 0 ]
  output_bin=$(echo "$result" | grep "asdf/bin")
  [ "$output_bin" = "$PWD/bin" ]
  output_shims=$(echo "$result" | grep "/shims")
  [ "$output_shims" = "$HOME/.asdf/shims" ]
}

@test "does not add paths to PATH more than once" {
  result=$(nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )
    let-env ASDF_NU_DIR = '$PWD'

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
    let-env ASDF_NU_DIR = '$PWD'

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
    let-env ASDF_NU_DIR = '$PWD'

    source asdf.nu
    which asdf | get path | to text
  ")
  [ "$?" -eq 0 ]
  [[ "$output" =~ "command" ]]
}

@test "function calls asdf command" {
  result=$(nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )
    let-env ASDF_NU_DIR = '$PWD'

    source asdf.nu
    asdf info
  ")
  [ "$?" -eq 0 ]
  output=$(echo "$result" | grep "ASDF INSTALLED PLUGINS:")
  [ "$output" != "" ]
}

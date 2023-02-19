#!/usr/bin/env bats
# shellcheck disable=SC2164

load test_helpers

setup() {
  cd "$(dirname "$BATS_TEST_DIRNAME")"

  if ! command -v nu; then
    skip "Nu is not installed"
  fi
}

cleaned_path() {
  echo "$PATH" | tr ':' '\n' | grep -v "asdf" | tr '\n' ':'
}

@test "exports ASDF_DIR" {
  run nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )
    let-env ASDF_NU_DIR = '$PWD'

    source asdf.nu

    echo \$env.ASDF_DIR"

  [ "$status" -eq 0 ]
  result=$(echo "$output" | grep "asdf")
  [ "$result" = "$PWD" ]
}

@test "adds asdf dirs to PATH" {
  run nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )
    let-env ASDF_NU_DIR = '$PWD'

    source asdf.nu


    \$env.PATH | to text"

  [ "$status" -eq 0 ]

  [[ "$output" == *"$PWD/bin"* ]]
  [[ "$output" == *"$HOME/.asdf/shims"* ]]
}

@test "does not add paths to PATH more than once" {
  run nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )
    let-env ASDF_NU_DIR = '$PWD'

    source asdf.nu
    source asdf.nu

    echo \$env.PATH"

  [ "$status" -eq 0 ]

  result=$(echo "$output" | tr ' ' '\n' | grep "asdf" | sort | uniq -d)
  [ "$result" = "" ]
}

@test "retains ASDF_DIR" {
  run nu -c "
    hide-env -i asdf
    let-env ASDF_DIR = ( pwd )
    let-env PATH = ( '$(cleaned_path)' | split row ':' )
    let-env ASDF_NU_DIR = '$PWD'

    source asdf.nu

    echo \$env.ASDF_DIR"

  [ "$status" -eq 0 ]
  [ "$output" = "$PWD" ]
}

@test "defines the asdf or main function" {
  run nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )
    let-env ASDF_NU_DIR = '$PWD'

    source asdf.nu
    which asdf | get path | to text"

  [ "$status" -eq 0 ]
}

@test "function calls asdf command" {
  run nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    let-env PATH = ( '$(cleaned_path)' | split row ':' )
    let-env ASDF_NU_DIR = '$PWD'

    source asdf.nu
    asdf info"

  [ "$status" -eq 0 ]

  result=$(echo "$output" | grep "ASDF INSTALLED PLUGINS:")
  [ "$result" != "" ]
}

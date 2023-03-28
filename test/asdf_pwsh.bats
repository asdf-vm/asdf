#!/usr/bin/env bats
# shellcheck disable=SC2164

load test_helpers

setup() {
  cd "$(dirname "$BATS_TEST_DIRNAME")"

  if ! command -v pwsh &>/dev/null && [ -z "$GITHUB_ACTIONS" ]; then
    skip "Powershell Core is not installed"
  fi
}

cleaned_path() {
  echo "$PATH" | tr ':' '\n' | grep -v "asdf" | tr '\n' ':'
}

@test "exports ASDF_DIR" {
  run pwsh -Command "
    function asdf() {} # checkstyle-ignore
    Remove-item Function:asdf
    \$Env:ASDF_DIR = ''
    \$Env:ASDF_DATA_DIR = ''
    \$Env:PATH = \"$(cleaned_path)\"

    . ./asdf.ps1
    Write-Output \"\$env:ASDF_DIR\""

  [ "$status" -eq 0 ]
  [ "$output" != "" ]
}

@test "adds asdf dirs to PATH" {
  run pwsh -Command "
    function asdf() {} # checkstyle-ignore
    Remove-item Function:asdf
    \$Env:ASDF_DIR = ''
    \$Env:ASDF_DATA_DIR = ''
    \$Env:PATH = \"$(cleaned_path)\"

    . ./asdf.ps1
    Write-Output \$Env:PATH"

  [ "$status" -eq 0 ]
  result=$(echo "$output" | grep "asdf")
  [ "$result" != "" ]
}

@test "does not add paths to PATH more than once" {
  run pwsh -Command "
    function asdf() {} # checkstyle-ignore
    Remove-item Function:asdf
    \$Env:ASDF_DIR = ''
    \$Env:ASDF_DATA_DIR = ''
    \$Env:PATH = \"$(cleaned_path)\"

    . ./asdf.ps1
    . ./asdf.ps1
    Write-Output \$Env:PATH"

  [ "$status" -eq 0 ]

  result=$(echo "$output" | tr ' ' '\n' | grep "asdf" | sort | uniq -d)
  [ "$result" = "" ]
}

@test "defines the asdf function" {
  run pwsh -Command "
    function asdf() {} # checkstyle-ignore
    Remove-item Function:asdf
    \$Env:ASDF_DIR = ''
    \$Env:ASDF_DATA_DIR = ''
    \$Env:PATH = \"$(cleaned_path)\"

    ./ asdf.ps1
    \$(Get-Command -CommandType asdf).Name"

  [ "$status" -eq 0 ]
  [[ "$output" =~ "asdf" ]]
}

@test "function calls asdf command" {
  run pwsh -Command "
    function asdf() {} # checkstyle-ignore
    Remove-item Function:asdf
    \$Env:ASDF_DIR = ''
    \$Env:ASDF_DATA_DIR = ''
    \$Env:PATH = \"$(cleaned_path)\"

    . ./asdf.ps1
    asdf info"

  [ "$status" -eq 0 ]
  result=$(echo "$output" | grep "ASDF INSTALLED PLUGINS:")
  [ "$result" != "" ]
}

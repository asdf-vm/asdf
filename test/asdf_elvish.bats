#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helpers

setup() {
  export XDG_CONFIG_HOME=
  export XDG_DATA_HOME=
  export XDG_DATA_DIRS=

  if ! command -v elvish &>/dev/null && [ -z "$GITHUB_ACTIONS" ]; then
    skip 'Elvish not installed'
  fi

  local ver_major=
  local ver_minor=
  local ver_patch=
  IFS='.' read -r ver_major ver_minor ver_patch <<<"$(elvish -version)"

  if ((ver_major == 0 && ver_minor < 18)) && [ -z "$GITHUB_ACTIONS" ]; then
    skip "Elvish version is not at least 0.18. Found ${ver_major}.${ver_minor}.${ver_patch}"
  fi
}

cleaned_path() {
  echo "$PATH" | tr ':' '\n' | grep -v "asdf" | tr '\n' ' '
}

@test "exports ASDF_DIR" {
  run elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:ASDF_DIR"

  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.asdf" ]
}

@test "retains ASDF_DIR" {
  run elvish -norc -c "
    set-env ASDF_DIR \"/path/to/asdf\"
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:ASDF_DIR"

  [ "$status" -eq 0 ]
  [ "$output" = "/path/to/asdf" ]
}

@test "retains ASDF_DATA_DIR" {
  run elvish -norc -c "
    set-env ASDF_DATA_DIR \"/path/to/asdf-data\"
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:ASDF_DATA_DIR"

  [ "$status" -eq 0 ]
  [ "$output" = "/path/to/asdf-data" ]
}

@test "adds asdf dirs to PATH" {
  run elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:PATH"

  [ "$status" -eq 0 ]

  result=$(echo "$output" | grep "asdf")
  [ "$result" != "" ]
}

@test "defines the _asdf namespace" {
  run elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    pprint \$_asdf:"

  [ "$status" -eq 0 ]
  [[ "$output" =~ "<ns " ]]
}

@test "does not add paths to PATH more than once" {
  run elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]

    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:PATH"

  [ "$status" -eq 0 ]

  result=$(echo "$result" | tr ':' '\n' | grep "asdf" | sort | uniq -d)
  [ "$result" = "" ]
}

@test "defines the asdf function" {
  run elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    pprint \$asdf~"

  [ "$status" -eq 0 ]
  [[ "$output" =~ "<closure " ]]
}

@test "function calls asdf command" {
  run elvish -norc -c "
    set-env ASDF_DIR $(pwd) # checkstyle-ignore
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    asdf info"

  [ "$status" -eq 0 ]

  result=$(echo "$output" | grep "ASDF INSTALLED PLUGINS:")
  [ "$result" != "" ]
}

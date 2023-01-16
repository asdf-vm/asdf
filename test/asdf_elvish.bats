#!/usr/bin/env bats

load test_helpers

setup() {
  # shellcheck disable=SC1007
  export XDG_CONFIG_HOME= XDG_DATA_HOME= XDG_DATA_DIRS=

  local version=
  version=$(elvish -version)

  # shellcheck disable=SC1007
  local ver_major= ver_minor= ver_patch=
  # shellcheck disable=SC2034
  IFS='.' read -r ver_major ver_minor ver_patch <<<"$version"

  if ((ver_major == 0 && ver_minor <= 17)); then
    skip "Elvish version is not at least 0.17"
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
  result=$(elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:PATH"
  [ "$status" -eq 0 ]
  echo "$result"
  run echo "$result" | grep "asdf")
  [ "$output" != "" ]
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
  output=$(echo "$result" | tr ':' '\n' | grep "asdf" | sort | uniq -d)
  [ "$output" = "" ]
}

@test "defines the asdf function" {
  run elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    pprint \$asdf~"
  [ "$status" -eq 0 ]
  echo "$output"
  [[ "$output" =~ "<closure " ]]
}

@test "function calls asdf command" {
 run elvish -norc -c "
    set-env ASDF_DIR $(pwd) # checkstyle-ignore
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    asdf info"
  [ "$status" -eq 0 ]
  output=$(echo "$result" | grep "ASDF INSTALLED PLUGINS:")
  [ "$output" != "" ]
}

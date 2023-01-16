#!/usr/bin/env bats

load test_helpers

setup() {
  export XDG_CONFIG_HOME=
  export XDG_DATA_HOME=
  export XDG_DATA_DIRS=

  local ver_major=
  local ver_minor=
  local ver_patch=
  IFS='.' read -r ver_major ver_minor ver_patch <<<"$(elvish -version)"

  if ((ver_major == 0 && ver_minor < 18)); then
    skip "Elvish version is not at least 0.18. Found ${ver_major}.${ver_minor}.${ver_patch}"
  fi
}

cleaned_path() {
  echo $PATH | tr ':' '\n' | grep -v "asdf" | tr '\n' ' '
}

@test "exports ASDF_DIR" {
  output=$(elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:ASDF_DIR
  ")
  [ "$?" -eq 0 ]
  [ "$output" = "$HOME/.asdf" ]
}

@test "retains ASDF_DIR" {
  output=$(elvish -norc -c "
    set-env ASDF_DIR "/path/to/asdf"
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:ASDF_DIR
  ")
  [ "$?" -eq 0 ]
  [ "$output" = "/path/to/asdf" ]
}

@test "retains ASDF_DATA_DIR" {
  output=$(elvish -norc -c "
    set-env ASDF_DATA_DIR "/path/to/asdf-data"
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:ASDF_DATA_DIR
  ")
  [ "$?" -eq 0 ]
  [ "$output" = "/path/to/asdf-data" ]
}

@test "adds asdf dirs to PATH" {
  result=$(elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
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
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    pprint \$_asdf:
  ")
  [ "$?" -eq 0 ]
  [[ "$output" =~ "<ns " ]]
}

@test "does not add paths to PATH more than once" {
  result=$(elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]

    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:PATH
  ")
  [ "$?" -eq 0 ]
  output=$(echo $result | tr ':' '\n' | grep "asdf" | sort | uniq -d)
  [ "$output" = "" ]
}

@test "defines the asdf function" {
  output=$(elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    pprint \$asdf~
  ")
  [ "$?" -eq 0 ]
  echo "$output"
  [[ "$output" =~ "<closure " ]]
}

@test "function calls asdf command" {
  result=$(elvish -norc -c "
    set-env ASDF_DIR $(pwd) # checkstyle-ignore
    set paths = [$(cleaned_path)]
    use ./asdf _asdf; var asdf~ = \$_asdf:asdf~
    asdf info
  ")
  [ "$?" -eq 0 ]
  output=$(echo "$result" | grep "ASDF INSTALLED PLUGINS:")
  [ "$output" != "" ]
}

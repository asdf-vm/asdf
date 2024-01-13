#!/usr/bin/env bats
# shellcheck disable=SC2164

load test_helpers

setup() {
  cd "$(dirname "$BATS_TEST_DIRNAME")"

  if ! command -v nu &>/dev/null && [ -z "$GITHUB_ACTIONS" ]; then
    skip "Nu is not installed"
  fi

  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

cleaned_path() {
  echo "$PATH" | tr ':' '\n' | grep -v "asdf" | tr '\n' ':'
}

run_nushell() {
  run nu -c "
    hide-env -i asdf
    hide-env -i ASDF_DIR
    \$env.PATH = ( '$(cleaned_path)' | split row ':' )
    \$env.ASDF_DIR = '$PWD'

    source asdf.nu
    $1"
}

@test "exports ASDF_DIR" {
  run_nushell "echo \$env.ASDF_DIR"

  [ "$status" -eq 0 ]
  result=$(echo "$output" | grep "asdf")
  [ "$result" = "$PWD" ]
}

@test "adds asdf dirs to PATH" {
  run_nushell "\$env.PATH | to text"

  [ "$status" -eq 0 ]

  [[ "$output" == *"$PWD/bin"* ]]
  [[ "$output" == *"$HOME/.asdf/shims"* ]]
}

@test "does not add paths to PATH more than once" {
  run_nushell "
    source asdf.nu
    echo \$env.PATH"

  [ "$status" -eq 0 ]

  result=$(echo "$output" | tr ' ' '\n' | grep "asdf" | sort | uniq -d)
  [ "$result" = "" ]
}

@test "retains ASDF_DIR (from ASDF_NU_DIR)" {
  run nu -c "
    hide-env -i asdf
    \$env.ASDF_DIR = ( pwd )
    \$env.PATH = ( '$(cleaned_path)' | split row ':' )
    \$env.ASDF_NU_DIR = '$PWD'

    source asdf.nu

    echo \$env.ASDF_DIR"

  [ "$status" -eq 0 ]
  [ "$output" = "$PWD" ]
}

@test "retains ASDF_DIR (from ASDF_DIR)" {
  run nu -c "
    hide-env -i asdf
    \$env.ASDF_DIR = ( pwd )
    \$env.PATH = ( '$(cleaned_path)' | split row ':' )
    \$env.ASDF_DIR = '$PWD'

    source asdf.nu

    echo \$env.ASDF_DIR"

  [ "$status" -eq 0 ]
  [ "$output" = "$PWD" ]
}

@test "defines the asdf or main function" {
  run_nushell "which asdf | get path | to text"

  [ "$status" -eq 0 ]
}

@test "function calls asdf command" {
  run_nushell "asdf info"

  [ "$status" -eq 0 ]

  result=$(echo "$output" | grep "ASDF INSTALLED PLUGINS:")
  [ "$result" != "" ]
}

@test "parses the output of asdf plugin list" {
  setup_repo
  install_dummy_plugin
  run_nushell "asdf plugin list | to csv -n"

  [ "$status" -eq 0 ]
  [ "$output" = "dummy" ]
}

@test "parses the output of asdf plugin list --urls" {
  setup_repo
  install_mock_plugin_repo "dummy"
  asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"

  run_nushell "asdf plugin list --urls | to csv -n"

  [ "$status" -eq 0 ]

  local repo_url
  repo_url=$(get_plugin_remote_url "dummy")

  [ "$output" = "dummy,$repo_url" ]
}

@test "parses the output of asdf plugin list --refs" {
  setup_repo
  install_mock_plugin_repo "dummy"
  asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"

  run_nushell "asdf plugin list --refs | to csv -n"

  [ "$status" -eq 0 ]

  local branch gitref
  branch=$(get_plugin_remote_branch "dummy")
  gitref=$(get_plugin_remote_gitref "dummy")

  [ "$output" = "dummy,$branch,$gitref" ]
}

@test "parses the output of asdf plugin list --urls --refs" {
  setup_repo
  install_mock_plugin_repo "dummy"
  asdf plugin add "dummy" "${BASE_DIR}/repo-dummy"

  run_nushell "asdf plugin list --urls --refs | to csv -n"

  [ "$status" -eq 0 ]

  local repo_url branch gitref
  repo_url=$(get_plugin_remote_url "dummy")
  branch=$(get_plugin_remote_branch "dummy")
  gitref=$(get_plugin_remote_gitref "dummy")

  [ "$output" = "dummy,$repo_url,$branch,$gitref" ]
}

@test "parses the output of asdf plugin list all" {
  setup_repo
  install_dummy_plugin
  run_nushell "asdf plugin list all | to csv -n"

  [ "$status" -eq 0 ]
  [ "$output" = "\
bar,false,http://example.com/bar
dummy,true,http://example.com/dummy
foo,false,http://example.com/foo" ]
}

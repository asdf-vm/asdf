#!/usr/bin/env bash

bats_require_minimum_version 1.7.0

# shellcheck source=lib/utils.bash
. "$(dirname "$BATS_TEST_DIRNAME")"/lib/utils.bash

setup_asdf_dir() {
  if [ "$BATS_TEST_NAME" = 'test_shim_exec_should_use_path_executable_when_specified_version_path-3a-3cpath-3e' ]; then
    BASE_DIR="$BASE_DIR/asdf_with_no_spaces"
  else
    BASE_DIR="$BASE_DIR/w space${BATS_TEST_NAME}"
  fi

  # We don't call mktemp anymore so we need to create this sub directory manually
  mkdir "$BASE_DIR"

  # HOME is now defined by the Golang test code in main_test.go
  HOME="$BASE_DIR"
  export HOME
  ASDF_DIR="$HOME/.asdf"
  mkdir -p "$ASDF_DIR/plugins"
  mkdir -p "$ASDF_DIR/installs"
  mkdir -p "$ASDF_DIR/shims"
  mkdir -p "$ASDF_DIR/tmp"
  # ASDF_BIN is now defined by the Golang test code in main_test.go
  #ASDF_BIN="$(dirname "$BATS_TEST_DIRNAME")/bin"

  ASDF_DATA_DIR="$BASE_DIR/.asdf"
  export ASDF_DATA_DIR

  # shellcheck disable=SC2031,SC2153
  PATH="$ASDF_BIN:$ASDF_DIR/shims:$PATH"
}

install_mock_plugin() {
  local plugin_name=$1
  local location="${2:-$ASDF_DIR}"
  plugin_dir="$location/plugins/$plugin_name"
  cp -r "$BATS_TEST_DIRNAME/fixtures/dummy_plugin" "$plugin_dir"
  init_git_repo "$plugin_dir"
}

install_mock_plugin_no_download() {
  local plugin_name=$1
  local location="${2:-$ASDF_DIR}"
  cp -r "$BATS_TEST_DIRNAME/fixtures/dummy_plugin_no_download" "$location/plugins/$plugin_name"
}

install_mock_legacy_plugin() {
  local plugin_name=$1
  local location="${2:-$ASDF_DIR}"
  plugin_dir="$location/plugins/$plugin_name"
  cp -r "$BATS_TEST_DIRNAME/fixtures/dummy_legacy_plugin" "$plugin_dir"
  init_git_repo "$plugin_dir"
}

install_mock_broken_plugin() {
  local plugin_name=$1
  local location="${2:-$ASDF_DIR}"
  cp -r "$BATS_TEST_DIRNAME/fixtures/dummy_broken_plugin" "$location/plugins/$plugin_name"
}

install_mock_plugin_repo() {
  local plugin_name=$1
  local location="${BASE_DIR}/repo-${plugin_name}"
  cp -r "$BATS_TEST_DIRNAME/fixtures/dummy_plugin" "${location}"
  init_git_repo "${location}"
}

init_git_repo() {
  location="$1"
  remote="${2:-"https://asdf-vm.com/fake-repo"}"
  git -C "${location}" init -q --initial-branch=master
  git -C "${location}" config user.name "Test"
  git -C "${location}" config user.email "test@example.com"
  git -C "${location}" add -A
  git -C "${location}" commit -q -m "asdf ${plugin_name} plugin"
  git -C "${location}" remote add origin "$remote"
}

install_mock_plugin_version() {
  local plugin_name=$1
  local plugin_version=$2
  local location="${3:-$ASDF_DIR}"
  mkdir -p "$location/installs/$plugin_name/$plugin_version"
}

install_dummy_plugin() {
  install_mock_plugin "dummy"
}

install_dummy_plugin_no_download() {
  install_mock_plugin_no_download "dummy-no-download" "$1"
}

install_dummy_legacy_plugin() {
  install_mock_legacy_plugin "legacy-dummy"
}

install_dummy_broken_plugin() {
  install_mock_broken_plugin "dummy-broken"
}

install_dummy_version() {
  install_mock_plugin_version "dummy" "$1"
}

install_dummy_legacy_version() {
  install_mock_plugin_version "legacy-dummy" "$1"
}

install_dummy_exec_path_script() {
  local name=$1
  local exec_path="$ASDF_DIR/plugins/dummy/bin/exec-path"
  local custom_dir="$ASDF_DIR/installs/dummy/1.0/bin/custom"
  mkdir "$custom_dir"
  touch "$custom_dir/$name"
  chmod +x "$custom_dir/$name"
  echo "echo 'bin/custom/$name'" >"$exec_path"
  chmod +x "$exec_path"
}

clean_asdf_dir() {
  rm -rf "$BASE_DIR"
  unset ASDF_DIR
  unset ASDF_DATA_DIR
}

setup_repo() {
  cp -r "$BATS_TEST_DIRNAME/fixtures/dummy_plugins_repo" "$ASDF_DIR/plugin-index"
  cp -r "$BATS_TEST_DIRNAME/fixtures/dummy_plugins_repo" "$ASDF_DIR/plugin-index-2"
  init_git_repo "$ASDF_DIR/plugin-index-2"
  init_git_repo "$ASDF_DIR/plugin-index" "$ASDF_DIR/plugin-index-2"
  touch "$(asdf_dir)/tmp/repo-updated"
}

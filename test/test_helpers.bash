#!/usr/bin/env bash

# shellcheck source=lib/utils.sh
. "$(dirname "$BATS_TEST_DIRNAME")"/lib/utils.sh

setup_asdf_dir() {
  BASE_DIR=$(mktemp -dt asdf.XXXX)
  HOME=$BASE_DIR/home
  ASDF_DIR=$HOME/.asdf
  mkdir -p "$ASDF_DIR/plugins"
  mkdir -p "$ASDF_DIR/installs"
  mkdir -p "$ASDF_DIR/shims"
  mkdir -p "$ASDF_DIR/tmp"
  ASDF_BIN=$(dirname "$BATS_TEST_DIRNAME")/bin

  # shellcheck disable=SC2031
  PATH=$ASDF_BIN:$ASDF_DIR/shims:$PATH
}

install_mock_plugin() {
  local plugin_name=$1
  local location="${2:-$ASDF_DIR}"
  cp -r "$BATS_TEST_DIRNAME/fixtures/dummy_plugin" "$location/plugins/$plugin_name"
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

install_dummy_version() {
  install_mock_plugin_version "dummy" "$1"
}

install_dummy_exec_path_script() {
  local name=$1
  local exec_path="$ASDF_DIR/plugins/dummy/bin/exec-path"
  local custom_dir="$ASDF_DIR/installs/dummy/1.0/bin/custom"
  mkdir "$custom_dir"
  touch "$custom_dir/$name"
  chmod +x "$custom_dir/$name"
  echo "echo 'bin/custom/$name'" > "$exec_path"
  chmod +x "$exec_path"
}

clean_asdf_dir() {
  rm -rf "$BASE_DIR"
  unset ASDF_DIR
  unset ASDF_DATA_DIR
}

setup_repo() {
  cp -r "$BATS_TEST_DIRNAME/fixtures/dummy_plugins_repo" "$ASDF_DIR/repository"
  touch "$(asdf_dir)/tmp/repo-updated"
}


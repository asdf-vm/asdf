#!/usr/bin/env bash

# shellcheck source=lib/utils.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/utils.sh

setup_asdf_dir() {
  BASE_DIR=$(mktemp -dt asdf.XXXX)
  HOME=$BASE_DIR/home
  ASDF_DIR=$HOME/.asdf
  mkdir -p "$ASDF_DIR/plugins"
  mkdir -p "$ASDF_DIR/installs"
  mkdir -p "$ASDF_DIR/shims"
  mkdir -p "$ASDF_DIR/tmp"
  PATH=$ASDF_DIR/shims:$PATH
}

install_mock_plugin() {
  local plugin_name=$1
  cp -r "$BATS_TEST_DIRNAME/fixtures/dummy_plugin" "$ASDF_DIR/plugins/$plugin_name"
}

install_mock_plugin_version() {
  local plugin_name=$1
  local plugin_version=$2
  mkdir -p "$ASDF_DIR/installs/$plugin_name/$plugin_version"
}

install_dummy_plugin() {
  install_mock_plugin "dummy"
}

install_dummy_version() {
  install_mock_plugin_version "dummy" "$1"
}

clean_asdf_dir() {
  rm -rf "$BASE_DIR"
  unset ASDF_DIR
}

setup_repo() {
  cp -r "$BATS_TEST_DIRNAME/fixtures/dummy_plugins_repo" "$ASDF_DIR/repository"
  touch "$(asdf_dir)/tmp/repo-updated"
}

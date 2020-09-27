#!/usr/bin/env bats

load test_helpers

setup() {
  BASE_DIR=$(mktemp -dt asdf.XXXX)
  HOME=$BASE_DIR/home
  ASDF_DIR=$HOME/.asdf
  git clone -o local "$(dirname "$BATS_TEST_DIRNAME")" "$ASDF_DIR"
  git --git-dir "$ASDF_DIR/.git" remote add origin https://github.com/asdf-vm/asdf.git
  mkdir -p "$ASDF_DIR/plugins"
  mkdir -p "$ASDF_DIR/installs"
  mkdir -p "$ASDF_DIR/shims"
  mkdir -p "$ASDF_DIR/tmp"
  ASDF_BIN="$ASDF_DIR/bin"

  # shellcheck disable=SC2031
  PATH=$ASDF_BIN:$ASDF_DIR/shims:$PATH
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "asdf plugin-update should pull latest master branch for plugin" {
  run asdf plugin-update dummy
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Updating dummy..."* ]]
  cd $ASDF_DIR/plugins/dummy
  [ $(git rev-parse --abbrev-ref HEAD) = "master" ]
}

@test "asdf plugin-update should not remove plugin versions" {
  run asdf install dummy 1.1
  [ "$status" -eq 0 ]
  [ $(cat $ASDF_DIR/installs/dummy/1.1/version) = "1.1" ]
  run asdf plugin-update dummy
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/installs/dummy/1.1/version ]
  run asdf plugin-update --all
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/installs/dummy/1.1/version ]
}

@test "asdf plugin-update should not remove plugins" {
  # dummy plugin is already installed
  run asdf plugin-update dummy
  [ "$status" -eq 0 ]
  [ -d $ASDF_DIR/plugins/dummy ]
  run asdf plugin-update --all
  [ "$status" -eq 0 ]
  [ -d $ASDF_DIR/plugins/dummy ]
}

@test "asdf plugin-update should not remove shims" {
  run asdf install dummy 1.1
  [ -f $ASDF_DIR/shims/dummy ]
  run asdf plugin-update dummy
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/shims/dummy ]
  run asdf plugin-update --all
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/shims/dummy ]
}

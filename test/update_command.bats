#!/usr/bin/env bats

load test_helpers

setup() {
  BASE_DIR=$(mktemp -dt asdf.XXXX)
  HOME="$BASE_DIR/home"
  ASDF_DIR="$HOME/.asdf"
  git clone -o local "$(dirname "$BATS_TEST_DIRNAME")" "$ASDF_DIR"
  git --git-dir "$ASDF_DIR/.git" remote add origin https://github.com/asdf-vm/asdf.git
  mkdir -p "$ASDF_DIR/plugins"
  mkdir -p "$ASDF_DIR/installs"
  mkdir -p "$ASDF_DIR/shims"
  mkdir -p "$ASDF_DIR/tmp"
  ASDF_BIN="$ASDF_DIR/bin"

  # shellcheck disable=SC2031
  PATH="$ASDF_BIN:$ASDF_DIR/shims:$PATH"
  install_dummy_plugin

  PROJECT_DIR="$HOME/project"
  mkdir -p "$PROJECT_DIR"
}

teardown() {
  clean_asdf_dir
}

@test "asdf update --head should checkout the master branch" {
  run asdf update --head
  [ "$status" -eq 0 ]
  cd "$ASDF_DIR"
  [ "$(git rev-parse --abbrev-ref HEAD)" = "master" ]
}

@test "asdf update should checkout the latest non-RC tag" {
  local tag=
  tag=$(git tag | grep -vi "rc" | tail -1)
  if [ -n "$tag" ]; then
    run asdf update
    [ "$status" -eq 0 ]
    cd "$ASDF_DIR"
    git tag | grep "$tag"
  fi
}

@test "asdf update should checkout the latest tag when configured with use_release_candidates = yes" {
  local tag=
  tag=$(git tag | tail -1)
  if [ -n "$tag" ]; then
    export ASDF_CONFIG_DEFAULT_FILE="$BATS_TMPDIR/asdfrc_defaults"
    echo "use_release_candidates = yes" >"$ASDF_CONFIG_DEFAULT_FILE"
    run asdf update
    [ "$status" -eq 0 ]
    cd "$ASDF_DIR"
    git tag | grep "$tag"
  fi
}

@test "asdf update is a noop for when updates are disabled" {
  touch "$ASDF_DIR/asdf_updates_disabled"
  run asdf update
  [ "$status" -eq 42 ]
  [ $'Update command disabled. Please use the package manager that you used to install asdf to upgrade asdf.' = "$output" ]
}

@test "asdf update is a noop for non-git repos" {
  rm -rf "$ASDF_DIR/.git/"
  run asdf update
  [ "$status" -eq 42 ]
  [ $'Update command disabled. Please use the package manager that you used to install asdf to upgrade asdf.' = "$output" ]
}

@test "asdf update fails with exit code 1" {
  git --git-dir "$ASDF_DIR/.git" remote set-url origin https://this-host-does-not-exist.xyz
  run asdf update
  [ "$status" -eq 1 ]
}

@test "asdf update should not remove plugin versions" {
  run asdf install dummy 1.1.0
  [ "$status" -eq 0 ]
  [ "$(cat "$ASDF_DIR/installs/dummy/1.1.0/version")" = "1.1.0" ]
  run asdf update
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/installs/dummy/1.1.0/version" ]
  run asdf update --head
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/installs/dummy/1.1.0/version" ]
}

@test "asdf update should not remove plugins" {
  # dummy plugin is already installed
  run asdf update
  [ "$status" -eq 0 ]
  [ -d "$ASDF_DIR/plugins/dummy" ]
  run asdf update --head
  [ "$status" -eq 0 ]
  [ -d "$ASDF_DIR/plugins/dummy" ]
}

@test "asdf update should not remove shims" {
  run asdf install dummy 1.1.0
  [ -f "$ASDF_DIR/shims/dummy" ]
  run asdf update
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]
  run asdf update --head
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]
}

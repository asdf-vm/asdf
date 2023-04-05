#!/usr/bin/env bats
# shellcheck disable=SC2012

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR="$HOME/project"
  mkdir "$PROJECT_DIR"
}

teardown() {
  clean_asdf_dir
}

@test "reshim should allow prefixes of other versions" {
  run asdf install dummy 1.0.1
  run asdf install dummy 1.0

  run asdf reshim
  [ "$status" -eq 0 ]

  run grep "asdf-plugin: dummy 1.0.1" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]
  run grep "asdf-plugin: dummy 1.0\$" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]
}

@test "reshim command should remove shims of removed binaries" {
  run asdf install dummy 1.0
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]

  run asdf reshim dummy
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]

  run rm "$ASDF_DIR/installs/dummy/1.0/bin/dummy"
  run asdf reshim dummy
  [ "$status" -eq 0 ]
  [ ! -f "$ASDF_DIR/shims/dummy" ]
}

@test "reshim should remove metadata of removed binaries" {
  run asdf install dummy 1.0
  run asdf install dummy 1.1

  run rm "$ASDF_DIR/installs/dummy/1.0/bin/dummy"
  run asdf reshim dummy
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]
  run grep "asdf-plugin: dummy 1.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 1 ]
  run grep "asdf-plugin: dummy 1.1" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]
}

@test "reshim should not remove metadata of removed prefix versions" {
  run asdf install dummy 1.0
  run asdf install dummy 1.0.1
  run rm "$ASDF_DIR/installs/dummy/1.0/bin/dummy"
  run asdf reshim dummy
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]
  run grep "asdf-plugin: dummy 1.0.1" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]
}

@test "reshim should not duplicate shims" {
  cd "$PROJECT_DIR"

  run asdf install dummy 1.0
  run asdf install dummy 1.1
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]

  run rm "$ASDF_DIR/shims/"*
  [ "$status" -eq 0 ]
  [ "0" -eq "$(ls "$ASDF_DIR/shims/"dummy* | wc -l)" ]

  run asdf reshim dummy
  [ "$status" -eq 0 ]
  [ "1" -eq "$(ls "$ASDF_DIR/shims/"dummy* | wc -l)" ]

  run asdf reshim dummy
  [ "$status" -eq 0 ]
  [ "1" -eq "$(ls "$ASDF_DIR/shims/"dummy* | wc -l)" ]
}

@test "reshim should create shims only for files and not folders" {
  cd "$PROJECT_DIR"

  run asdf install dummy 1.0
  run asdf install dummy 1.1
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]
  [ ! -f "$ASDF_DIR/shims/subdir" ]

  run rm "$ASDF_DIR/shims/"*
  [ "$status" -eq 0 ]
  [ "0" -eq "$(ls "$ASDF_DIR/shims/"dummy* | wc -l)" ]
  [ "0" -eq "$(ls "$ASDF_DIR/shims/"subdir* | wc -l)" ]

  run asdf reshim dummy
  [ "$status" -eq 0 ]
  [ "1" -eq "$(ls "$ASDF_DIR/shims/"dummy* | wc -l)" ]
  [ "0" -eq "$(ls "$ASDF_DIR/shims/"subdir* | wc -l)" ]

}

@test "reshim without arguments reshims all installed plugins" {
  run asdf install dummy 1.0
  run rm "$ASDF_DIR/shims/"*
  [ "$status" -eq 0 ]
  [ "0" -eq "$(ls "$ASDF_DIR/shims/"dummy* | wc -l)" ]
  run asdf reshim
  [ "$status" -eq 0 ]
  [ "1" -eq "$(ls "$ASDF_DIR/shims/"dummy* | wc -l)" ]
}

@test "reshim command executes configured pre hook" {
  run asdf install dummy 1.0

  cat >"$HOME/.asdfrc" <<-'EOM'
pre_asdf_reshim_dummy = echo RESHIM
EOM

  run asdf reshim dummy 1.0
  [ "$output" = "RESHIM" ]
}

@test "reshim command executes configured post hook" {
  run asdf install dummy 1.0

  cat >"$HOME/.asdfrc" <<-'EOM'
post_asdf_reshim_dummy = echo RESHIM
EOM

  run asdf reshim dummy 1.0
  [ "$output" = "RESHIM" ]
}

# Fixes https://github.com/asdf-vm/asdf/issues/1115
# (Issue with executable_name changing after homebre updates)
@test "reshim should rewrite the shim file except the version list" {
  run asdf install dummy 1.0
  local dummy_shim
  dummy_shim="$ASDF_DIR/shims/dummy"

  sed -i.bak -e 's/exec /exec \/borked_path_due_to_homebrew_update/' "$dummy_shim"
  run grep 'borked_path_due_to_homebrew_update' "$dummy_shim" # Sanity check
  [ "$status" -eq 0 ]

  run asdf reshim dummy "path:$ASDF_DIR/installs/dummy/path"
  run grep -v 'borked_path_due_to_homebrew_update' "$dummy_shim"
  [ "$status" -eq 0 ]
}

@test "reshim should allow local path versions" {
  run asdf install dummy 1.0

  mkdir -p "$ASDF_DIR/installs/dummy/path/bin/"
  touch "$ASDF_DIR/installs/dummy/path/bin/dummy"
  chmod +x "$ASDF_DIR/installs/dummy/path/bin/dummy"

  run asdf reshim dummy "path:$ASDF_DIR/installs/dummy/path"

  [ "$status" -eq 0 ]
  run grep "asdf-plugin: dummy 1.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]
  run grep "asdf-plugin: dummy path:$ASDF_DIR/installs/dummy" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]
}

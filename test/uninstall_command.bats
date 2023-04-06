#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR="$HOME/project"
  mkdir -p "$PROJECT_DIR"
}

teardown() {
  clean_asdf_dir
}

@test "uninstall_command should fail when no such version is installed" {
  run asdf uninstall dummy 3.14
  [ "$output" = "No such version" ]
  [ "$status" -eq 1 ]
}

@test "uninstall_command should remove the plugin with that version from asdf" {
  run asdf install dummy 1.1.0
  [ "$status" -eq 0 ]
  [ "$(cat "$ASDF_DIR/installs/dummy/1.1.0/version")" = "1.1.0" ]
  run asdf uninstall dummy 1.1.0
  [ ! -f "$ASDF_DIR/installs/dummy/1.1.0/version" ]
}

@test "uninstall_command should invoke the plugin bin/uninstall if available" {
  run asdf install dummy 1.1.0
  [ "$status" -eq 0 ]
  mkdir -p "$ASDF_DIR/plugins/dummy/bin"
  printf '%s\n' "echo custom uninstall" >"$ASDF_DIR/plugins/dummy/bin/uninstall"
  chmod 755 "$ASDF_DIR/plugins/dummy/bin/uninstall"
  run asdf uninstall dummy 1.1.0
  [ "$output" = "custom uninstall" ]
  [ "$status" -eq 0 ]
}

@test "uninstall_command should remove the plugin shims if no other version is installed" {
  run asdf install dummy 1.1.0
  [ -f "$ASDF_DIR/shims/dummy" ]
  run asdf uninstall dummy 1.1.0
  [ ! -f "$ASDF_DIR/shims/dummy" ]
}

@test "uninstall_command should leave the plugin shims if other version is installed" {
  run asdf install dummy 1.0.0
  [ -f "$ASDF_DIR/installs/dummy/1.0.0/bin/dummy" ]

  run asdf install dummy 1.1.0
  [ -f "$ASDF_DIR/installs/dummy/1.1.0/bin/dummy" ]

  [ -f "$ASDF_DIR/shims/dummy" ]
  run asdf uninstall dummy 1.0.0
  [ -f "$ASDF_DIR/shims/dummy" ]
}

@test "uninstall_command should remove relevant asdf-plugin metadata" {
  run asdf install dummy 1.0.0
  [ -f "$ASDF_DIR/installs/dummy/1.0.0/bin/dummy" ]

  run asdf install dummy 1.1.0
  [ -f "$ASDF_DIR/installs/dummy/1.1.0/bin/dummy" ]

  run asdf uninstall dummy 1.0.0
  run grep "asdf-plugin: dummy 1.1.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]
  run grep "asdf-plugin: dummy 1.0.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 1 ]
}

@test "uninstall_command should not remove other unrelated shims" {
  run asdf install dummy 1.0.0
  [ -f "$ASDF_DIR/shims/dummy" ]

  touch "$ASDF_DIR/shims/gummy"
  [ -f "$ASDF_DIR/shims/gummy" ]

  run asdf uninstall dummy 1.0.0
  [ -f "$ASDF_DIR/shims/gummy" ]
}

@test "uninstall command executes configured pre hook" {
  cat >"$HOME/.asdfrc" <<-'EOM'
pre_asdf_uninstall_dummy = echo will uninstall dummy $1
EOM

  run asdf install dummy 1.0.0
  run asdf uninstall dummy 1.0.0
  [ "$output" = "will uninstall dummy 1.0.0" ]
}

@test "uninstall command executes configured post hook" {
  cat >"$HOME/.asdfrc" <<-'EOM'
post_asdf_uninstall_dummy = echo removed dummy $1
EOM

  run asdf install dummy 1.0.0
  run asdf uninstall dummy 1.0.0
  [ "$output" = "removed dummy 1.0.0" ]
}

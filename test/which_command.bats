#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  run asdf install dummy 1.0
  run asdf install dummy 1.1

  PROJECT_DIR="$HOME/project"
  mkdir -p "$PROJECT_DIR"
  echo 'dummy 1.0' >>"$PROJECT_DIR/.tool-versions"
}

teardown() {
  clean_asdf_dir
}

@test "which should show dummy 1.0 main binary" {
  cd "$PROJECT_DIR"

  run asdf which "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/1.0/bin/dummy" ]
}

@test "which should fail for unknown binary" {
  cd "$PROJECT_DIR"

  run asdf which "sunny"
  [ "$status" -eq 1 ]
  [ "$output" = "unknown command: sunny. Perhaps you have to reshim?" ]
}

@test "which should show dummy 1.0 other binary" {
  cd "$PROJECT_DIR"

  echo "echo bin bin/subdir" >"$ASDF_DIR/plugins/dummy/bin/list-bin-paths"
  chmod +x "$ASDF_DIR/plugins/dummy/bin/list-bin-paths"
  run asdf reshim dummy 1.0

  run asdf which "other_bin"
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/1.0/bin/subdir/other_bin" ]
}

@test "which should show path of system version" {
  echo 'dummy system' >"$PROJECT_DIR/.tool-versions"
  cd "$PROJECT_DIR"

  mkdir "$PROJECT_DIR/sys"
  touch "$PROJECT_DIR/sys/dummy"
  chmod +x "$PROJECT_DIR/sys/dummy"

  run env "PATH=$PATH:$PROJECT_DIR/sys" asdf which "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "$PROJECT_DIR/sys/dummy" ]
}

@test "which report when missing executable on system version" {
  echo 'dummy system' >"$PROJECT_DIR/.tool-versions"
  cd "$PROJECT_DIR"

  run asdf which "dummy"
  [ "$status" -eq 1 ]
  [ "$output" = "No dummy executable found for dummy system" ]
}

@test "which should inform when no binary is found" {
  cd "$PROJECT_DIR"

  run asdf which "bazbat"
  [ "$status" -eq 1 ]
  [ "$output" = "unknown command: bazbat. Perhaps you have to reshim?" ]
}

@test "which should use path returned by exec-path when present" {
  cd "$PROJECT_DIR"
  install_dummy_exec_path_script "dummy"

  run asdf which "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/1.0/bin/custom/dummy" ]
}

@test "which should return the path set by the legacy file" {
  cd "$PROJECT_DIR"

  echo 'dummy 1.0' >>"$HOME/.tool-versions"
  echo '1.1' >>"$PROJECT_DIR/.dummy-version"
  rm "$PROJECT_DIR/.tool-versions"
  echo 'legacy_version_file = yes' >"$HOME/.asdfrc"

  run asdf which "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/1.1/bin/dummy" ]
}

@test "which should not return shim path" {
  cd "$PROJECT_DIR"
  echo 'dummy 1.0' >"$PROJECT_DIR/.tool-versions"
  rm "$ASDF_DIR/installs/dummy/1.0/bin/dummy"

  run env PATH="$PATH:$ASDF_DIR/shims" asdf which dummy
  [ "$status" -eq 1 ]
  [ "$output" = "No dummy executable found for dummy 1.0" ]
}

#!/usr/bin/env bats
# shellcheck disable=SC2164

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR="$HOME/project"
  mkdir -p "$PROJECT_DIR"
  cd "$PROJECT_DIR"

  # asdf lib needed to run generated shims
  cp -rf "$BATS_TEST_DIRNAME"/../{bin,lib} "$ASDF_DIR/"
}

teardown() {
  clean_asdf_dir
}

@test "asdf env without argument should display help" {
  run asdf env
  [ "$status" -eq 1 ]
  echo "$output" | grep "usage: asdf env <command>"
}

@test "asdf env should execute under the environment used for a shim" {
  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"
  run asdf install

  run asdf env dummy which dummy
  [ "$status" -eq 0 ]
  [ "$output" = "$ASDF_DIR/installs/dummy/1.0/bin/dummy" ]
}

@test "asdf env should execute under plugin custom environment used for a shim" {
  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"
  run asdf install

  echo '#!/usr/bin/env bash
  export FOO=bar' >"$ASDF_DIR/plugins/dummy/bin/exec-env"
  chmod +x "$ASDF_DIR/plugins/dummy/bin/exec-env"

  run asdf env dummy
  [ "$status" -eq 0 ]
  echo "$output" | grep 'FOO=bar'
}

@test "asdf env should print error when plugin version lacks the specified executable" {
  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"
  run asdf install

  echo '#!/usr/bin/env bash
  export FOO=bar' >"$ASDF_DIR/plugins/dummy/bin/exec-env"
  chmod +x "$ASDF_DIR/plugins/dummy/bin/exec-env"

  echo "dummy system" >"$PROJECT_DIR/.tool-versions"

  run asdf env dummy
  [ "$status" -eq 1 ]
  [ "$output" = "No executable dummy found for current version. Please select a different version or install dummy manually for the current version" ]
}

@test "asdf env should ignore plugin custom environment on system version" {
  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"
  run asdf install

  echo '#!/usr/bin/env bash
  export FOO=bar' >"$ASDF_DIR/plugins/dummy/bin/exec-env"
  chmod +x "$ASDF_DIR/plugins/dummy/bin/exec-env"

  # Create a "system" dummy executable
  echo '#!/usr/bin/env bash
  echo "system dummy"' >"$ASDF_BIN/dummy"
  chmod +x "$ASDF_BIN/dummy"

  echo "dummy system" >"$PROJECT_DIR/.tool-versions"

  run asdf env dummy
  [ "$status" -eq 0 ]

  run grep 'FOO=bar' <<<"$output"
  [ "$output" = "" ]
  [ "$status" -eq 1 ]

  run asdf env dummy which dummy
  [ "$output" = "$ASDF_BIN/dummy" ]
  [ "$status" -eq 0 ]
  # Remove "system" dummy executable
  rm "$ASDF_BIN/dummy"
}

@test "asdf env should set PATH correctly" {
  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"
  run asdf install

  run asdf env dummy
  [ "$status" -eq 0 ]

  # Should set path
  path_line=$(echo "$output" | grep '^PATH=')
  [ "$path_line" != "" ]

  # Should not contain duplicate colon
  run grep -q '::' <<<"$path_line"
  [ "$status" -ne 0 ]
}

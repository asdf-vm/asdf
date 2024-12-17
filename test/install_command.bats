#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_legacy_plugin
  install_dummy_plugin
  install_dummy_broken_plugin
  install_dummy_plugin_no_download

  PROJECT_DIR="$HOME/project"
  mkdir -p "$PROJECT_DIR"
}

teardown() {
  clean_asdf_dir
}

@test "install_command installs the correct version" {
  run asdf install dummy 1.1.0
  [ "$status" -eq 0 ]
  [ "$(cat "$ASDF_DIR/installs/dummy/1.1.0/version")" = "1.1.0" ]
}

@test "install_command installs the correct version for plugins without download script" {
  run asdf install legacy-dummy 1.1.0
  [ "$status" -eq 0 ]
  [ "$(cat "$ASDF_DIR/installs/legacy-dummy/1.1.0/version")" = "1.1.0" ]
}

@test "install_command without arguments installs even if the user is terrible and does not use newlines" {
  cd "$PROJECT_DIR"
  echo -n 'dummy 1.2.0' >".tool-versions"
  run asdf install
  [ "$status" -eq 0 ]
  [ "$(cat "$ASDF_DIR/installs/dummy/1.2.0/version")" = "1.2.0" ]
}

@test "install_command with only name installs the version in .tool-versions" {
  cd "$PROJECT_DIR"
  echo -n 'dummy 1.2.0' >".tool-versions"
  run asdf install dummy
  [ "$status" -eq 0 ]
  [ "$(cat "$ASDF_DIR/installs/dummy/1.2.0/version")" = "1.2.0" ]
}

@test "install_command set ASDF_CONCURRENCY" {
  run asdf install dummy 1.0.0
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/installs/dummy/1.0.0/env" ]
  run grep ASDF_CONCURRENCY "$ASDF_DIR/installs/dummy/1.0.0/env"
  [ "$status" -eq 0 ]
}

@test "install_command set ASDF_CONCURRENCY via env var" {
  ASDF_CONCURRENCY=-1 run asdf install dummy 1.0.0
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/installs/dummy/1.0.0/env" ]
  run grep ASDF_CONCURRENCY=-1 "$ASDF_DIR/installs/dummy/1.0.0/env"
  [ "$status" -eq 0 ]
}

@test "install_command set ASDF_CONCURRENCY via asdfrc" {
  cat >"$HOME/.asdfrc" <<-'EOM'
  concurrency = -2
EOM
  run asdf install dummy 1.0.0
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/installs/dummy/1.0.0/env" ]
  run grep ASDF_CONCURRENCY=-2 "$ASDF_DIR/installs/dummy/1.0.0/env"
  [ "$status" -eq 0 ]
}

@test "install_command without arguments should work in directory containing whitespace" {
  WHITESPACE_DIR="$PROJECT_DIR/whitespace\ dir"
  mkdir -p "$WHITESPACE_DIR"
  cd "$WHITESPACE_DIR"
  echo 'dummy 1.2.0' >>"$WHITESPACE_DIR/.tool-versions"

  run asdf install

  [ "$status" -eq 0 ]
  [ "$(cat "$ASDF_DIR/installs/dummy/1.2.0/version")" = "1.2.0" ]
}

@test "install_command should create a shim with asdf-plugin metadata" {
  run asdf install dummy 1.0.0
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/installs/dummy/1.0.0/env" ]
  run grep "asdf-plugin: dummy 1.0.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]
}

@test "install_command should create a shim with asdf-plugin metadata for plugins without download script" {
  run asdf install legacy-dummy 1.0.0
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/installs/legacy-dummy/1.0.0/env" ]
  run grep "asdf-plugin: legacy-dummy 1.0.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]
}

@test "install_command on two versions should create a shim with asdf-plugin metadata" {
  run asdf install dummy 1.1.0
  [ "$status" -eq 0 ]

  run grep "asdf-plugin: dummy 1.1.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]

  run grep "asdf-plugin: dummy 1.0.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 1 ]

  run asdf install dummy 1.0.0
  [ "$status" -eq 0 ]
  run grep "asdf-plugin: dummy 1.0.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]

  run grep "# asdf-plugin: dummy 1.0.0"$'\n'"# asdf-plugin: dummy 1.1.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]

  lines_count=$(grep -c "asdf-plugin: dummy 1.1.0" "$ASDF_DIR/shims/dummy")
  [ "$lines_count" -eq "1" ]
}

@test "install_command without arguments should not generate shim for subdir" {
  cd "$PROJECT_DIR"
  echo 'dummy 1.0.0' >"$PROJECT_DIR/.tool-versions"

  run asdf install
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]
  [ ! -f "$ASDF_DIR/shims/subdir" ]
}

@test "install_command without arguments should generate shim that passes all arguments to executable" {
  # asdf lib needed to run generated shims
  cp -rf "$BATS_TEST_DIRNAME"/../{bin,lib} "$ASDF_DIR/"

  cd "$PROJECT_DIR"
  echo 'dummy 1.0.0' >"$PROJECT_DIR/.tool-versions"
  run asdf install

  # execute the generated shim
  run "$ASDF_DIR/shims/dummy" world hello
  [ "$status" -eq 0 ]
  [ "$output" = "This is Dummy 1.0.0! hello world" ]
}

@test "install_command fails when tool is specified but no version of the tool is configured" {
  run asdf install dummy
  [ "$status" -eq 1 ]
  [ "$output" = "No versions specified for dummy in config files or environment" ]
  [ ! -f "$ASDF_DIR/installs/dummy/1.1.0/version" ]
}

@test "install_command fails if the plugin is not installed" {
  cd "$PROJECT_DIR"
  echo 'other_dummy 1.0.0' >"$PROJECT_DIR/.tool-versions"

  run asdf install
  [ "$status" -eq 1 ]
  [ "$output" = "other_dummy plugin is not installed" ]
}

@test "install_command fails if the plugin is not installed without collisions" {
  cd "$PROJECT_DIR"
  printf "dummy 1.0.0\ndum 1.0.0" >"$PROJECT_DIR/.tool-versions"

  run asdf install
  [ "$status" -eq 1 ]
  [ "$output" = "dum plugin is not installed" ]
}

@test "install_command fails when tool is specified but no version of the tool is configured in config file" {
  echo 'dummy 1.0.0' >"$PROJECT_DIR/.tool-versions"
  run asdf install other-dummy
  [ "$status" -eq 1 ]
  [ "$output" = "No versions specified for other-dummy in config files or environment" ]
  [ ! -f "$ASDF_DIR/installs/dummy/1.0.0/version" ]
}

@test "install_command fails when two tools are specified with no versions" {
  printf 'dummy 1.0.0\nother-dummy 2.0.0' >"$PROJECT_DIR/.tool-versions"
  run asdf install dummy other-dummy
  [ "$status" -eq 1 ]
  [ "$output" = "Dummy couldn't install version: other-dummy (on purpose)" ]
  [ ! -f "$ASDF_DIR/installs/dummy/1.0.0/version" ]
  [ ! -f "$ASDF_DIR/installs/other-dummy/2.0.0/version" ]
}

@test "install_command without arguments uses a parent directory .tool-versions file if present" {
  # asdf lib needed to run generated shims
  cp -rf "$BATS_TEST_DIRNAME"/../{bin,lib} "$ASDF_DIR/"

  echo 'dummy 1.0.0' >"$PROJECT_DIR/.tool-versions"
  mkdir -p "$PROJECT_DIR/child"

  cd "$PROJECT_DIR/child"

  run asdf install

  # execute the generated shim
  [ "$("$ASDF_DIR/shims/dummy" world hello)" = "This is Dummy 1.0.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "install_command installs multiple tool versions when they are specified in a .tool-versions file" {
  echo 'dummy 1.0.0 1.2.0' >"$PROJECT_DIR/.tool-versions"
  cd "$PROJECT_DIR"

  run asdf install
  [ "$status" -eq 0 ]

  [ "$(cat "$ASDF_DIR/installs/dummy/1.0.0/version")" = "1.0.0" ]
  [ "$(cat "$ASDF_DIR/installs/dummy/1.2.0/version")" = "1.2.0" ]
}

@test "install_command doesn't install system version" {
  run asdf install dummy system
  [ "$status" -eq 0 ]
  [ ! -f "$ASDF_DIR/installs/dummy/system/version" ]
}

@test "install command executes configured pre plugin install hook" {
  cat >"$HOME/.asdfrc" <<-'EOM'
pre_asdf_install_dummy = echo will install dummy $1
EOM

  run asdf install dummy 1.0.0
  [ "$output" = "will install dummy 1.0.0" ]
}

@test "install command executes configured post plugin install hook" {
  cat >"$HOME/.asdfrc" <<-'EOM'
post_asdf_install_dummy = echo HEY $version FROM $plugin_name
EOM

  run asdf install dummy 1.0.0
  [ "$output" = "HEY 1.0.0 FROM dummy" ]
}

@test "install command without arguments installs versions from legacy files" {
  echo 'legacy_version_file = yes' >"$HOME/.asdfrc"
  echo '1.2.0' >>"$PROJECT_DIR/.dummy-version"
  cd "$PROJECT_DIR"

  run asdf install
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/installs/dummy/1.2.0/version" ]
}

@test "install command without arguments installs versions from legacy files in parent directories" {
  echo 'legacy_version_file = yes' >"$HOME/.asdfrc"
  echo '1.2.0' >>"$PROJECT_DIR/.dummy-version"

  mkdir -p "$PROJECT_DIR/child"
  cd "$PROJECT_DIR/child"

  run asdf install
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/installs/dummy/1.2.0/version" ]
}

@test "install_command latest installs latest stable version" {
  run asdf install dummy latest
  [ "$status" -eq 0 ]
  [ "$(cat "$ASDF_DIR/installs/dummy/2.0.0/version")" = "2.0.0" ]
}

@test "install_command latest:version installs latest stable version that matches the given string" {
  run asdf install dummy latest:1
  [ "$status" -eq 0 ]
  [ "$(cat "$ASDF_DIR/installs/dummy/1.1.0/version")" = "1.1.0" ]
}

@test "install_command deletes the download directory" {
  run asdf install dummy 1.1.0
  [ "$status" -eq 0 ]
  [ ! -d "$ASDF_DIR/downloads/dummy/1.1.0" ]
  [ "$(cat "$ASDF_DIR/installs/dummy/1.1.0/version")" = "1.1.0" ]
}

@test "install_command keeps the download directory when --keep-download flag is provided" {
  run asdf install dummy 1.1.0 --keep-download
  [ "$status" -eq 0 ]
  [ -d "$ASDF_DIR/downloads/dummy/1.1.0" ]
  [ "$(cat "$ASDF_DIR/installs/dummy/1.1.0/version")" = "1.1.0" ]
}

@test "install_command keeps the download directory when always_keep_download setting is true" {
  echo 'always_keep_download = yes' >"$HOME/.asdfrc"
  run asdf install dummy 1.1.0
  [ "$status" -eq 0 ]
  [ -d "$ASDF_DIR/downloads/dummy/1.1.0" ]
  [ "$(cat "$ASDF_DIR/installs/dummy/1.1.0/version")" = "1.1.0" ]
}

@test "install_command fails when download script exits with non-zero code" {
  run asdf install dummy-broken 1.0.0
  [ "$status" -eq 1 ]
  [ ! -d "$ASDF_DIR/downloads/dummy-broken/1.1.0" ]
  [ ! -d "$ASDF_DIR/installs/dummy-broken/1.1.0" ]
  [ "$output" = "Download failed!" ]
}

@test "install_command prints info message if plugin does not support preserving download data if --keep-download flag is provided" {
  run asdf install dummy-no-download 1.0.0 --keep-download
  [ "$status" -eq 0 ]

  [[ "$output" == *'asdf: Warn:'*'not be preserved'* ]]
}

@test "install_command prints info message if plugin does not support preserving download data if always_keep_download setting is true" {
  echo 'always_keep_download = yes' >"$HOME/.asdfrc"
  run asdf install dummy-no-download 1.0.0
  [ "$status" -eq 0 ]

  [[ "$output" == *'asdf: Warn:'*'not be preserved'* ]]
}

@test "install_command does not print info message if --keep-download flag is not provided and always_keep_download setting is false" {
  run asdf install dummy-no-download 1.0.0
  [ "$status" -eq 0 ]

  [[ "$output" != *'asdf: Warn:'*'not be preserved'* ]]
}

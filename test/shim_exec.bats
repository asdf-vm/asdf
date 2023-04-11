#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2164

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

@test "asdf exec without argument should display help" {
  run asdf exec
  [ "$status" -eq 1 ]
  echo "$output" | grep "usage: asdf exec <command>"
}

@test "asdf exec should pass all arguments to executable" {
  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"
  run asdf install

  run asdf exec dummy world hello
  [ "$output" = "This is Dummy 1.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "asdf exec should pass all arguments to executable even if shim is not in PATH" {
  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"
  run asdf install

  path=$(echo "$PATH" | sed -e "s|$(asdf_data_dir)/shims||g; s|::|:|g")
  run env PATH="$path" which dummy
  [ "$output" = "" ]
  [ "$status" -eq 1 ]

  run env PATH="$path" asdf exec dummy world hello
  [ "$output" = "This is Dummy 1.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "shim exec should pass all arguments to executable" {
  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"
  run asdf install

  run "$ASDF_DIR/shims/dummy" world hello
  [ "$output" = "This is Dummy 1.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "shim exec should pass stdin to executable" {
  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"
  run asdf install

  echo "tr [:lower:] [:upper:]" >"$ASDF_DIR/installs/dummy/1.0/bin/upper"
  chmod +x "$ASDF_DIR/installs/dummy/1.0/bin/upper"

  run asdf reshim dummy 1.0

  run echo "$(echo hello | "$ASDF_DIR/shims/upper")"
  [ "$output" = "HELLO" ]
  [ "$status" -eq 0 ]
}

@test "shim exec should fail if no version is selected" {
  run asdf install dummy 1.0

  touch "$PROJECT_DIR/.tool-versions"

  run "$ASDF_DIR/shims/dummy" world hello
  [ "$status" -eq 126 ]
  echo "$output" | grep -q "No version is set for command dummy" 2>/dev/null
}

@test "shim exec should suggest which plugin to use when no version is selected" {
  run asdf install dummy 1.0
  run asdf install dummy 2.0.0

  touch "$PROJECT_DIR/.tool-versions"

  run "$ASDF_DIR/shims/dummy" world hello
  [ "$status" -eq 126 ]

  echo "$output" | grep -q "No version is set for command dummy" 2>/dev/null
  echo "$output" | grep -q "Consider adding one of the following versions in your config file at $PROJECT_DIR/.tool-versions" 2>/dev/null
  echo "$output" | grep -q "dummy 1.0" 2>/dev/null
  echo "$output" | grep -q "dummy 2.0.0" 2>/dev/null
}

@test "shim exec should suggest different plugins providing same tool when no version is selected" {
  # Another fake plugin with 'dummy' executable
  cp -rf "$ASDF_DIR/plugins/dummy" "$ASDF_DIR/plugins/mummy"

  run asdf install dummy 1.0
  run asdf install mummy 3.0

  touch "$PROJECT_DIR/.tool-versions"

  run "$ASDF_DIR/shims/dummy" world hello
  [ "$status" -eq 126 ]

  echo "$output" | grep -q "No version is set for command dummy" 2>/dev/null
  echo "$output" | grep -q "Consider adding one of the following versions in your config file at $PROJECT_DIR/.tool-versions" 2>/dev/null
  echo "$output" | grep -q "dummy 1.0" 2>/dev/null
  echo "$output" | grep -q "mummy 3.0" 2>/dev/null
}

@test "shim exec should suggest to install missing version" {
  run asdf install dummy 1.0

  echo "dummy 2.0.0 1.3" >"$PROJECT_DIR/.tool-versions"

  run "$ASDF_DIR/shims/dummy" world hello
  [ "$status" -eq 126 ]
  echo "$output" | grep -q "No preset version installed for command dummy" 2>/dev/null
  echo "$output" | grep -q "Please install a version by running one of the following:" 2>/dev/null
  echo "$output" | grep -q "asdf install dummy 2.0.0" 2>/dev/null
  echo "$output" | grep -q "asdf install dummy 1.3" 2>/dev/null
  echo "$output" | grep -q "or add one of the following versions in your config file at $PROJECT_DIR/.tool-versions" 2>/dev/null
  echo "$output" | grep -q "dummy 1.0" 2>/dev/null
}

@test "shim exec should execute first plugin that is installed and set" {
  run asdf install dummy 2.0.0
  run asdf install dummy 3.0

  echo "dummy 1.0 3.0 2.0.0" >"$PROJECT_DIR/.tool-versions"

  run "$ASDF_DIR/shims/dummy" world hello
  [ "$status" -eq 0 ]

  echo "$output" | grep -q "This is Dummy 3.0! hello world" 2>/dev/null
}

@test "shim exec should only use the first version found for a plugin" {
  run asdf install dummy 3.0

  echo "dummy 3.0" >"$PROJECT_DIR/.tool-versions"
  echo "dummy 1.0" >>"$PROJECT_DIR/.tool-versions"

  run "$ASDF_DIR/shims/dummy" world hello
  [ "$status" -eq 0 ]

  echo "$output" | grep -q "This is Dummy 3.0! hello world" 2>/dev/null
}

@test "shim exec should determine correct executable on two projects using different plugins that provide the same tool" {
  # Another fake plugin with 'dummy' executable
  cp -rf "$ASDF_DIR/plugins/dummy" "$ASDF_DIR/plugins/mummy"
  sed -i -e 's/Dummy/Mummy/' "$ASDF_DIR/plugins/mummy/bin/install"

  run asdf install mummy 3.0
  run asdf install dummy 1.0

  mkdir "$PROJECT_DIR"/{A,B}
  echo "dummy 1.0" >"$PROJECT_DIR/A/.tool-versions"
  echo "mummy 3.0" >"$PROJECT_DIR/B/.tool-versions"

  cd "$PROJECT_DIR"/A
  run "$ASDF_DIR/shims/dummy" world hello
  [ "$output" = "This is Dummy 1.0! hello world" ]
  [ "$status" -eq 0 ]

  cd "$PROJECT_DIR"/B
  run "$ASDF_DIR/shims/dummy" world hello
  [ "$output" = "This is Mummy 3.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "shim exec should determine correct executable on a project with two plugins set that provide the same tool" {
  # Another fake plugin with 'dummy' executable
  cp -rf "$ASDF_DIR/plugins/dummy" "$ASDF_DIR/plugins/mummy"
  sed -i -e 's/Dummy/Mummy/' "$ASDF_DIR/plugins/mummy/bin/install"

  run asdf install dummy 1.0
  run asdf install mummy 3.0

  echo "dummy 2.0.0" >"$PROJECT_DIR/.tool-versions"
  echo "mummy 3.0" >>"$PROJECT_DIR/.tool-versions"
  echo "dummy 1.0" >>"$PROJECT_DIR/.tool-versions"

  run "$ASDF_DIR/shims/dummy" world hello
  [ "$output" = "This is Mummy 3.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "shim exec should fallback to system executable when specified version is system" {
  run asdf install dummy 1.0

  echo "dummy system" >"$PROJECT_DIR/.tool-versions"

  mkdir "$PROJECT_DIR/foo/"
  echo "echo System" >"$PROJECT_DIR/foo/dummy"
  chmod +x "$PROJECT_DIR/foo/dummy"

  run env "PATH=$PATH:$PROJECT_DIR/foo" "$ASDF_DIR/shims/dummy" hello
  [ "$output" = "System" ]
}

# NOTE: The name of this test is linked to a condition in `test_helpers.bash. See
# the 'setup_asdf_dir' function for details.
@test "shim exec should use path executable when specified version path:<path>" {
  run asdf install dummy 1.0

  CUSTOM_DUMMY_PATH="$PROJECT_DIR/foo"
  CUSTOM_DUMMY_BIN_PATH="$CUSTOM_DUMMY_PATH/bin"
  mkdir -p "$CUSTOM_DUMMY_BIN_PATH"
  echo "echo System" >"$CUSTOM_DUMMY_BIN_PATH/dummy"
  chmod +x "$CUSTOM_DUMMY_BIN_PATH/dummy"

  echo "dummy path:$CUSTOM_DUMMY_PATH" >"$PROJECT_DIR/.tool-versions"

  run "$ASDF_DIR/shims/dummy" hello
  [ "$output" = "System" ]
}

@test "shim exec should execute system if set first" {
  run asdf install dummy 2.0.0

  echo "dummy system" >"$PROJECT_DIR/.tool-versions"
  echo "dummy 2.0.0" >>"$PROJECT_DIR/.tool-versions"

  mkdir "$PROJECT_DIR/foo/"
  echo "echo System" >"$PROJECT_DIR/foo/dummy"
  chmod +x "$PROJECT_DIR/foo/dummy"

  run env "PATH=$PATH:$PROJECT_DIR/foo" "$ASDF_DIR/shims/dummy" hello
  [ "$output" = "System" ]
}

@test "shim exec should use custom exec-env for tool" {
  run asdf install dummy 2.0.0
  echo "export FOO=sourced" >"$ASDF_DIR/plugins/dummy/bin/exec-env"
  mkdir "$ASDF_DIR/plugins/dummy/shims"
  echo 'echo $FOO custom' >"$ASDF_DIR/plugins/dummy/shims/foo"
  chmod +x "$ASDF_DIR/plugins/dummy/shims/foo"
  run asdf reshim dummy 2.0.0

  echo "dummy 2.0.0" >"$PROJECT_DIR/.tool-versions"
  run "$ASDF_DIR/shims/foo"
  [ "$output" = "sourced custom" ]
}

@test "shim exec with custom exec-env using ASDF_INSTALL_PATH" {
  run asdf install dummy 2.0.0
  echo 'export FOO=$ASDF_INSTALL_PATH/foo' >"$ASDF_DIR/plugins/dummy/bin/exec-env"
  mkdir "$ASDF_DIR/plugins/dummy/shims"
  echo 'echo $FOO custom' >"$ASDF_DIR/plugins/dummy/shims/foo"
  chmod +x "$ASDF_DIR/plugins/dummy/shims/foo"
  run asdf reshim dummy 2.0.0

  echo "dummy 2.0.0" >"$PROJECT_DIR/.tool-versions"
  run "$ASDF_DIR/shims/foo"
  [ "$output" = "$ASDF_DIR/installs/dummy/2.0.0/foo custom" ]
}

@test "shim exec doest not use custom exec-env for system version" {
  run asdf install dummy 2.0.0
  echo "export FOO=sourced" >"$ASDF_DIR/plugins/dummy/bin/exec-env"
  mkdir "$ASDF_DIR/plugins/dummy/shims"
  echo 'echo $FOO custom' >"$ASDF_DIR/plugins/dummy/shims/foo"
  chmod +x "$ASDF_DIR/plugins/dummy/shims/foo"
  run asdf reshim dummy 2.0.0

  echo "dummy system" >"$PROJECT_DIR/.tool-versions"

  mkdir "$PROJECT_DIR/sys/"
  echo 'echo x$FOO System' >"$PROJECT_DIR/sys/foo"
  chmod +x "$PROJECT_DIR/sys/foo"

  run env "PATH=$PATH:$PROJECT_DIR/sys" "$ASDF_DIR/shims/foo"
  [ "$output" = "x System" ]
}

@test "shim exec should prepend the plugin paths on execution" {
  run asdf install dummy 2.0.0

  mkdir "$ASDF_DIR/plugins/dummy/shims"
  echo 'which dummy' >"$ASDF_DIR/plugins/dummy/shims/foo"
  chmod +x "$ASDF_DIR/plugins/dummy/shims/foo"
  run asdf reshim dummy 2.0.0

  echo "dummy 2.0.0" >"$PROJECT_DIR/.tool-versions"

  run "$ASDF_DIR/shims/foo"
  [ "$output" = "$ASDF_DIR/installs/dummy/2.0.0/bin/dummy" ]
}

@test "shim exec should be able to find other shims in path" {
  cp -rf "$ASDF_DIR/plugins/dummy" "$ASDF_DIR/plugins/gummy"

  echo "dummy 2.0.0" >"$PROJECT_DIR/.tool-versions"
  echo "gummy 2.0.0" >>"$PROJECT_DIR/.tool-versions"

  run asdf install

  mkdir "$ASDF_DIR/plugins/"{dummy,gummy}/shims

  echo 'which dummy' >"$ASDF_DIR/plugins/dummy/shims/foo"
  chmod +x "$ASDF_DIR/plugins/dummy/shims/foo"

  echo 'which gummy' >"$ASDF_DIR/plugins/dummy/shims/bar"
  chmod +x "$ASDF_DIR/plugins/dummy/shims/bar"

  touch "$ASDF_DIR/plugins/gummy/shims/gummy"
  chmod +x "$ASDF_DIR/plugins/gummy/shims/gummy"

  run asdf reshim

  run "$ASDF_DIR/shims/foo"
  [ "$output" = "$ASDF_DIR/installs/dummy/2.0.0/bin/dummy" ]

  run "$ASDF_DIR/shims/bar"
  [ "$output" = "$ASDF_DIR/shims/gummy" ]
}

@test "shim exec should remove shim_path from path on system version execution" {
  run asdf install dummy 2.0.0

  echo "dummy system" >"$PROJECT_DIR/.tool-versions"

  mkdir "$PROJECT_DIR/sys/"
  echo 'which dummy' >"$PROJECT_DIR/sys/dummy"
  chmod +x "$PROJECT_DIR/sys/dummy"

  run env "PATH=$PATH:$PROJECT_DIR/sys" "$ASDF_DIR/shims/dummy"
  [ "$output" = "$ASDF_DIR/shims/dummy" ]
}

@test "shim exec can take version from legacy file if configured" {
  run asdf install dummy 2.0.0

  echo "legacy_version_file = yes" >"$HOME/.asdfrc"
  echo "2.0.0" >"$PROJECT_DIR/.dummy-version"

  run "$ASDF_DIR/shims/dummy" world hello
  [ "$output" = "This is Dummy 2.0.0! hello world" ]
}

@test "shim exec can take version from environment variable" {
  run asdf install dummy 2.0.0
  run env ASDF_DUMMY_VERSION=2.0.0 "$ASDF_DIR/shims/dummy" world hello
  [ "$output" = "This is Dummy 2.0.0! hello world" ]
}

@test "shim exec uses plugin list-bin-paths" {
  exec_path="$ASDF_DIR/plugins/dummy/bin/list-bin-paths"
  custom_path="$ASDF_DIR/installs/dummy/1.0/custom"

  echo "echo bin custom" >"$exec_path"
  chmod +x "$exec_path"

  run asdf install dummy 1.0
  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"

  mkdir "$custom_path"
  echo "echo CUSTOM" >"$custom_path/foo"
  chmod +x "$custom_path/foo"

  run asdf reshim dummy 1.0

  run "$ASDF_DIR/shims/foo"
  [ "$output" = "CUSTOM" ]
}

@test "shim exec uses plugin custom exec-path hook" {
  run asdf install dummy 1.0

  exec_path="$ASDF_DIR/plugins/dummy/bin/exec-path"
  custom_dummy="$ASDF_DIR/installs/dummy/1.0/custom/dummy"

  echo "echo custom/dummy" >"$exec_path"
  chmod +x "$exec_path"

  mkdir "$(dirname "$custom_dummy")"
  echo "echo CUSTOM" >"$custom_dummy"
  chmod +x "$custom_dummy"

  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"

  run "$ASDF_DIR/shims/dummy"
  [ "$output" = "CUSTOM" ]
}

@test "shim exec uses plugin custom exec-path hook that defaults" {
  run asdf install dummy 1.0

  exec_path="$ASDF_DIR/plugins/dummy/bin/exec-path"
  echo 'echo $3 # always same path' >"$exec_path"
  chmod +x "$exec_path"

  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"

  run "$ASDF_DIR/shims/dummy"
  [ "$output" = "This is Dummy 1.0!" ]
}

@test "shim exec executes configured pre-hook" {
  run asdf install dummy 1.0
  echo dummy 1.0 >"$PROJECT_DIR/.tool-versions"

  cat >"$HOME/.asdfrc" <<-'EOM'
pre_dummy_dummy = echo PRE $version $1 $2
EOM

  run "$ASDF_DIR/shims/dummy" hello world
  [ "$status" -eq 0 ]
  echo "$output" | grep "PRE 1.0 hello world"
  echo "$output" | grep "This is Dummy 1.0! world hello"
}

@test "shim exec doesnt execute command if pre-hook failed" {
  run asdf install dummy 1.0
  echo dummy 1.0 >"$PROJECT_DIR/.tool-versions"

  mkdir "$HOME/hook"
  pre_cmd="$HOME/hook/pre"
  echo 'echo $* && false' >"$pre_cmd"
  chmod +x "$pre_cmd"

  cat >"$HOME/.asdfrc" <<'EOM'
pre_dummy_dummy = pre $1 no $plugin_name $2
EOM

  run env PATH="$PATH:$HOME/hook" "$ASDF_DIR/shims/dummy" hello world
  [ "$output" = "hello no dummy world" ]
  [ "$status" -eq 1 ]
}

# From @tejanium in https://github.com/asdf-vm/asdf/issues/581#issuecomment-635337727
@test "asdf exec should not crash when POSIXLY_CORRECT=1" {
  export POSIXLY_CORRECT=1

  echo "dummy 1.0" >"$PROJECT_DIR/.tool-versions"
  run asdf install

  run asdf exec dummy world hello
  [ "$output" = "This is Dummy 1.0! hello world" ]
  [ "$status" -eq 0 ]
}

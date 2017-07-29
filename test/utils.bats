#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version "0.1.0"
  install_dummy_version "0.2.0"

  PROJECT_DIR=$HOME/project
  mkdir -p $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "check_if_version_exists should exit with 1 if plugin does not exist" {
  run check_if_version_exists "inexistent" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin" ]
}

@test "check_if_version_exists should exit with 1 if version does not exist" {
  run check_if_version_exists "dummy" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "version 1.0.0 is not installed for dummy" ]
}

@test "check_if_version_exists should be noop if version exists" {
  run check_if_version_exists "dummy" "0.1.0"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "check_if_version_exists should be noop if version is system" {
  mkdir -p $ASDF_DIR/plugins/foo
  run check_if_version_exists "foo" "system"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "check_if_version_exists should be ok for ref:version install" {
  mkdir -p $ASDF_DIR/plugins/foo
  mkdir -p $ASDF_DIR/installs/foo/ref-master
  run check_if_version_exists "foo" "ref:master"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "check_if_plugin_exists should exit with 1 when plugin is empty string" {
  run check_if_plugin_exists
  [ "$status" -eq 1 ]
  [ "$output" = "No plugin given" ]
}

@test "check_if_plugin_exists should be noop if plugin exists" {
  run check_if_plugin_exists "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "parse_asdf_version_file should output version" {
  echo "dummy 0.1.0" > $PROJECT_DIR/.tool-versions
  run parse_asdf_version_file $PROJECT_DIR/.tool-versions dummy
  [ "$status" -eq 0 ]
  [ "$output" == "0.1.0" ]
}

@test "parse_asdf_version_file should output path version with spaces" {
    echo "dummy path:/some/dummy path" > $PROJECT_DIR/.tool-versions
    run parse_asdf_version_file $PROJECT_DIR/.tool-versions dummy
    [ "$status" -eq 0 ]
    [ "$output" == "path:/some/dummy path" ]
}

@test "find_version should return .tool-versions if legacy is disabled" {
  echo "dummy 0.1.0" > $PROJECT_DIR/.tool-versions
  echo "0.2.0" > $PROJECT_DIR/.dummy-version

  run find_version "dummy" $PROJECT_DIR
  [ "$status" -eq 0 ]
  [ "$output" = "0.1.0|$PROJECT_DIR/.tool-versions" ]
}

@test "find_version should return the legacy file if supported" {
  echo "legacy_version_file = yes" > $HOME/.asdfrc
  echo "dummy 0.1.0" > $HOME/.tool-versions
  echo "0.2.0" > $PROJECT_DIR/.dummy-version

  run find_version "dummy" $PROJECT_DIR
  [ "$status" -eq 0 ]
  [ "$output" = "0.2.0|$PROJECT_DIR/.dummy-version" ]
}

@test "find_version skips .tool-version file that don't list the plugin" {
  echo "dummy 0.1.0" > $HOME/.tool-versions
  echo "another_plugin 0.3.0" > $PROJECT_DIR/.tool-versions

  run find_version "dummy" $PROJECT_DIR
  [ "$status" -eq 0 ]
  [ "$output" = "0.1.0|$HOME/.tool-versions" ]
}

@test "find_version should return .tool-versions if unsupported" {
  echo "dummy 0.1.0" > $HOME/.tool-versions
  echo "0.2.0" > $PROJECT_DIR/.dummy-version
  echo "legacy_version_file = yes" > $HOME/.asdfrc
  rm $ASDF_DIR/plugins/dummy/bin/list-legacy-filenames

  run find_version "dummy" $PROJECT_DIR
  [ "$status" -eq 0 ]
  [ "$output" = "0.1.0|$HOME/.tool-versions" ]
}

@test "get_preset_version_for returns the current version" {
  cd $PROJECT_DIR
  echo "dummy 0.2.0" > .tool-versions
  run get_preset_version_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "0.2.0" ]
}

@test "get_preset_version_for returns the global version from home when project is outside of home" {
  echo "dummy 0.1.0" > $HOME/.tool-versions
  PROJECT_DIR=$BASE_DIR/project
  mkdir -p $PROJECT_DIR
  run get_preset_version_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "0.1.0" ]
}

@test "get_preset_version_for returns the tool version from env if ASDF_{TOOL}_VERSION is defined" {
  cd $PROJECT_DIR
  echo "dummy 0.2.0" > .tool-versions
  ASDF_DUMMY_VERSION=3.0.0 run get_preset_version_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "3.0.0" ]
}

@test "get_preset_version_for should return branch reference version" {
  cd $PROJECT_DIR
  echo "dummy ref:master" > $PROJECT_DIR/.tool-versions
  run get_preset_version_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "ref:master" ]
}

@test "get_preset_version_for should return path version" {
  cd $PROJECT_DIR
  echo "dummy path:/some/place with spaces" > $PROJECT_DIR/.tool-versions
  run get_preset_version_for "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "path:/some/place with spaces" ]
}

@test "get_executable_path for system version should return system path" {
  mkdir -p $ASDF_DIR/plugins/foo
  run get_executable_path "foo" "system" "ls"
  [ "$status" -eq 0 ]
  [ "$output" = $(which ls) ]
}

@test "get_executable_path for system version should not use asdf shims" {
  mkdir -p $ASDF_DIR/plugins/foo
  touch $ASDF_DIR/shims/dummy_executable
  chmod +x $ASDF_DIR/shims/dummy_executable

  run which dummy_executable
  [ "$status" -eq 0 ]

  run get_executable_path "foo" "system" "dummy_executable"
  [ "$status" -eq 1 ]
}

@test "get_executable_path for non system version should return relative path from plugin" {
  mkdir -p $ASDF_DIR/plugins/foo
  mkdir -p $ASDF_DIR/installs/foo/1.0.0/bin
  executable_path=$ASDF_DIR/installs/foo/1.0.0/bin/dummy
  touch $executable_path
  chmod +x $executable_path

  run get_executable_path "foo" "1.0.0" "bin/dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "$executable_path" ]
}

@test "get_executable_path for ref:version installed version should resolve to ref-version" {
  mkdir -p $ASDF_DIR/plugins/foo
  mkdir -p $ASDF_DIR/installs/foo/ref-master/bin
  executable_path=$ASDF_DIR/installs/foo/ref-master/bin/dummy
  touch $executable_path
  chmod +x $executable_path

  run get_executable_path "foo" "ref:master" "bin/dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "$executable_path" ]
}

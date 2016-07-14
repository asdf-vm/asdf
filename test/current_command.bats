#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/current.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  OTHER_DIR=$HOME/other
  mkdir -p $ASDF_DIR/installs/dummy/1.0.0 $ASDF_DIR/installs/dummy/1.1.0 $PROJECT_DIR $OTHER_DIR

  echo 'dummy 1.0.0' >> $HOME/.tool-versions
  echo 'dummy 1.1.0' >> $PROJECT_DIR/.tool-versions
  echo '1.2.0' >> $OTHER_DIR/.dummy-version
}

teardown() {
  clean_asdf_dir
}

@test "current should derive from the local .tool_versions when it exists" {
  cd $PROJECT_DIR

  run current_command "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "1.1.0 (set by $PROJECT_DIR/.tool-versions)" ]
}

@test "current should derive from the global .tool_versions when local doesn't exist" {
  cd $OTHER_DIR

  run current_command "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "1.0.0 (set by $HOME/.tool-versions)" ]
}

@test "current should derive from the legacy file if enabled and hide the file path" {
  echo 'legacy_version_file = yes' > $HOME/.asdfrc
  cd $OTHER_DIR

  run current_command "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.0" ]
}

@test "current should error when the plugin doesn't exist" {
  run current_command "foobar"
  [ "$status" -eq 1 ]
}

@test "current should error when no version is set" {
  cd $OTHER_DIR
  rm $HOME/.tool-versions

  run current_command "dummy"
  [ "$status" -eq 1 ]
  [ "$output" = "No version set for dummy" ]
}

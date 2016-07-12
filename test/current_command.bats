#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/current.sh

setup() {
  setup_asdf_dir

  PROJECT_DIR=$HOME/project
  OTHER_DIR=$HOME/other
  mkdir -p $ASDF_DIR/plugins/foo $ASDF_DIR/installs/foo/1.0.0 $ASDF_DIR/installs/foo/1.1.0 $PROJECT_DIR $OTHER_DIR

  echo 'foo 1.0.0' >> $HOME/.tool-versions
  echo 'foo 1.1.0' >> $PROJECT_DIR/.tool-versions
}

teardown() {
  clean_asdf_dir
}

@test "current should output the version the local .tool_versions path" {
  cd $PROJECT_DIR

  run current_command "foo"
  [ "$status" -eq 0 ]
  [ "$output" = "1.1.0 (set by $PROJECT_DIR/.tool-versions)" ]
}

@test "current should output the version the global .tool_versions path" {
  cd $OTHER_DIR

  run current_command "foo"
  [ "$status" -eq 0 ]
  [ "$output" = "1.0.0 (set by $HOME/.tool-versions)" ]
}

@test "current should error when the plugin doesn't exist" {
  run current_command "bar"
  [ "$status" -eq 1 ]
}

@test "current should error when no version is set" {
    cd $OTHER_DIR
    rm $HOME/.tool-versions

    run current_command "foo"
    [ "$status" -eq 1 ]
    [ "$output" = "No version set for foo" ]
}

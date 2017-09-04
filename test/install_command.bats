#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/reshim.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/install.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "install_command installs the correct version" {
  run install_command dummy 1.1
  [ "$status" -eq 0 ]
  [ $(cat $ASDF_DIR/installs/dummy/1.1/version) = "1.1" ]
}

@test "install_command set ASDF_CONCURRENCY" {
  run install_command dummy 1.0
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/installs/dummy/1.0/env ]
  run grep ASDF_CONCURRENCY $ASDF_DIR/installs/dummy/1.0/env
  [ "$status" -eq 0 ]
}

@test "install_command should work in directory containing whitespace" {
  WHITESPACE_DIR="$PROJECT_DIR/whitespace\ dir"
  mkdir -p "$WHITESPACE_DIR"
  cd "$WHITESPACE_DIR"
  echo 'dummy 1.2' >> "$WHITESPACE_DIR/.tool-versions"

  run install_command

  [ "$status" -eq 0 ]
  [ $(cat $ASDF_DIR/installs/dummy/1.2/version) = "1.2" ]
}

@test "install_command should create a shim with asdf-plugin metadata" {
  run install_command dummy 1.0
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/installs/dummy/1.0/env ]
  run grep "asdf-plugin: dummy" $ASDF_DIR/shims/dummy
  [ "$status" -eq 0 ]

  run grep "asdf-plugin-version: 1.0" $ASDF_DIR/shims/dummy
  [ "$status" -eq 0 ]
}

@test "install_command should create a shim with asdf-plugin-version metadata" {
  run install_command dummy 1.1
  [ "$status" -eq 0 ]
  run grep "asdf-plugin-version: 1.1" $ASDF_DIR/shims/dummy
  [ "$status" -eq 0 ]

  run grep "asdf-plugin-version: 1.0" $ASDF_DIR/shims/dummy
  [ "$status" -eq 1 ]

  run install_command dummy 1.0
  [ "$status" -eq 0 ]
  run grep "asdf-plugin-version: 1.0" $ASDF_DIR/shims/dummy
  [ "$status" -eq 0 ]

  lines_count=$(grep "asdf-plugin-version: 1.1" $ASDF_DIR/shims/dummy | wc -l)
  [ "$lines_count" -eq "1" ]
}


@test "install_command generated shim should pass all arguments to executable" {
  # asdf lib needed to run generated shims
  cp -rf $BATS_TEST_DIRNAME/../{bin,lib} $ASDF_DIR/

  cd $PROJECT_DIR
  echo 'dummy 1.0' > $PROJECT_DIR/.tool-versions
  run install_command

  # execute the generated shim
  [ "$($ASDF_DIR/shims/dummy world hello)" == "This is Dummy 1.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "install_command fails when the name or version are not specified" {
  run install_command dummy
  [ "$status" -eq 1 ]
  [ "$output" = "You must specify a name and a version to install" ]
  [ ! -f $ASDF_DIR/installs/dummy/1.1/version ]

  run install_command 1.1
  [ "$status" -eq 1 ]
  [ "$output" = "You must specify a name and a version to install" ]
  [ ! -f $ASDF_DIR/installs/dummy/1.1/version ]
}

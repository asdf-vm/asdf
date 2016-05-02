#!/usr/bin/env bats

. $(dirname $BATS_TEST_DIRNAME)/lib/utils.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/version_commands.sh

setup() {
  BASE_DIR=$(mktemp -dt asdf.XXXX)
  HOME=$BASE_DIR/home
  ASDF_DIR=$HOME/.asdf
  OTHER_DIR=$BASE_DIR/other
  mkdir -p $ASDF_DIR/plugins/foo $ASDF_DIR/plugins/bar $ASDF_DIR/installs/foo/1.0.0 $ASDF_DIR/installs/foo/1.1.0 $ASDF_DIR/installs/foo/1.2.0 $ASDF_DIR/installs/bar/1.0.0 $OTHER_DIR

  cd $OTHER_DIR
  echo 'foo 1.0.0' >> $HOME/.tool-versions
  echo 'foo 1.1.0' >> .tool-versions
}

teardown() {
  rm -rf $BASE_DIR
}


@test "local should emit an error when run in lookup mode and file does not exist" {
  rm .tool-versions
  run local_command
  [ "$status" -eq 1 ]
  [ "$output" = ".tool-versions does not exist" ]
}

@test "global should emit an error when run in lookup mode and file does not exist" {
  rm $HOME/.tool-versions
  run global_command "foo"
  [ "$status" -eq 1 ]
  [ "$output" = "version not set for foo" ]
}

@test "local should emit an error when plugin does not exist" {
  run local_command "inexistent" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin" ]
}

@test "local should emit an error when plugin version does not exist" {
  run local_command "foo" "0.0.1"
  [ "$status" -eq 1 ]
  [ "$output" = "version 0.0.1 is not installed for foo" ]
}

@test "local should return and set the local version" {

  run local_command
  [ "$status" -eq 0 ]
  [ "$output" = "foo 1.1.0" ]

  run local_command foo "1.2.0"

  run local_command foo
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.0" ]

  run local_command bar
  [ "$status" -eq 1 ]

  run local_command bar 1.0.0
  [ "$status" -eq 0 ]

  run local_command bar
  [ "$status" -eq 0 ]
  [ "$output" = "1.0.0" ]
}

@test "local should fallback to legacy-file when enabled" {
    echo 'legacy_version_file = yes' > $HOME/.asdfrc
    mkdir -p $ASDF_DIR/plugins/foo/bin
    echo 'echo 1.0.0' > $ASDF_DIR/plugins/foo/bin/get-version-from-legacy-file
    rm .tool-versions

    run local_command foo

    [ "$status" -eq 0 ]
    [ "$output" = "1.0.0" ]
}

@test "local should ignore legacy-file when disabled" {
    mkdir -p $ASDF_DIR/plugins/foo/bin
    echo 'cat 1.0.0' > $ASDF_DIR/plugins/foo/bin/get-version-from-legacy-file
    rm .tool-versions

    run local_command foo

    [ "$status" -eq 1 ]
    [ "$output" = "version not set for foo" ]
}


@test "global should return and set the global version" {
  run global_command
  [ "$status" -eq 0 ]
  [ "$output" = "foo 1.0.0" ]

  run global_command foo 1.2.0
  [ "$status" -eq 0 ]

  run global_command foo
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.0" ]
}

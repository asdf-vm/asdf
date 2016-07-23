#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/version_commands.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version "1.0.0"
  install_dummy_version "1.1.0"
  install_dummy_version "1.2.0"

  PROJECT_DIR=$BASE_DIR/project
  mkdir -p $PROJECT_DIR

  echo 'dummy 1.0.0' >> $HOME/.tool-versions
  echo 'dummy 1.1.0' >> $PROJECT_DIR/.tool-versions

  cd $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}


@test "local should emit an error when run in lookup mode and file does not exist" {
  rm .tool-versions
  run local_command
  [ "$status" -eq 1 ]
  [ "$output" = ".tool-versions does not exist" ]
}

@test "global should emit an error when run in lookup mode and file does not exist" {
  rm $HOME/.tool-versions
  run global_command "dummy"
  [ "$status" -eq 1 ]
  [ "$output" = "version not set for dummy" ]
}

@test "local should emit an error when plugin does not exist" {
  run local_command "inexistent" "1.0.0"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin" ]
}

@test "local should emit an error when plugin version does not exist" {
  run local_command "dummy" "0.0.1"
  [ "$status" -eq 1 ]
  [ "$output" = "version 0.0.1 is not installed for dummy" ]
}

@test "local should return and set the local version" {

  run local_command
  [ "$status" -eq 0 ]
  [ "$output" = "dummy 1.1.0" ]

  run local_command dummy "1.2.0"

  run local_command dummy
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.0" ]

  rm .tool-versions
  run local_command dummy 1.2.0
  [ -f .tool-versions ]

  run local_command dummy
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.0" ]
  run global_command dummy
  [ "$output" = "1.0.0" ]

  mkdir $BASE_DIR/other && cd $BASE_DIR/other

  run local_command dummy
  [ "$status" -eq 1 ]

  run local_command dummy 1.0.0
  [ "$status" -eq 0 ]

  run local_command dummy
  [ "$status" -eq 0 ]
  [ "$output" = "1.0.0" ]
}

@test "local should fallback to legacy-file when enabled" {
    echo 'legacy_version_file = yes' > $HOME/.asdfrc
    echo '1.3.0' > .dummy-version
    rm .tool-versions
    run local_command dummy

    [ "$status" -eq 0 ]
    [ "$output" = "1.3.0" ]
}

@test "local should ignore legacy-file when disabled" {
    rm .tool-versions
    run local_command dummy

    [ "$status" -eq 1 ]
    [ "$output" = "version not set for dummy" ]
}


@test "global should return and set the global version" {
  run global_command
  [ "$status" -eq 0 ]
  [ "$output" = "dummy 1.0.0" ]

  run global_command dummy 1.2.0
  [ "$status" -eq 0 ]

  run global_command dummy
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.0" ]
}

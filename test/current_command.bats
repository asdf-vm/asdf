#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/current.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/plugin-list.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version "1.1.0"
  install_dummy_version "1.2.0"

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "current should derive from the current .tool-versions" {
  cd $PROJECT_DIR
  echo 'dummy 1.1.0' >> $PROJECT_DIR/.tool-versions

  run current_command "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "1.1.0   (set by $PROJECT_DIR/.tool-versions)" ]
}

@test "current should derive from the legacy file if enabled" {
  cd $PROJECT_DIR
  echo 'legacy_version_file = yes' > $HOME/.asdfrc
  echo '1.2.0' >> $PROJECT_DIR/.dummy-version

  run current_command "dummy"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.0   (set by $PROJECT_DIR/.dummy-version)" ]
}

@test "current should error when the plugin doesn't exist" {
  run current_command "foobar"
  [ "$status" -eq 1 ]
  [ "$output" = "No such plugin" ]
}

@test "current should error when no version is set" {
  cd $PROJECT_DIR

  run current_command "dummy"
  [ "$status" -eq 1 ]
}

@test "current should error when a version is set that isn't installed" {
  cd $PROJECT_DIR
  echo 'dummy 9.9.9' >> $PROJECT_DIR/.tool-versions

  run current_command "dummy"
  [ "$status" -eq 1 ]
  [ "$output" = "version 9.9.9 is not installed for dummy" ]
}

@test "should output all plugins when no plugin passed" {

  install_dummy_plugin
  install_dummy_version "1.1.0"

  install_mock_plugin "foobar"
  install_mock_plugin_version "foobar" "1.0.0"

  install_mock_plugin "baz"

  cd $PROJECT_DIR
  echo 'dummy 1.1.0' >> $PROJECT_DIR/.tool-versions
  echo 'foobar 1.0.0' >> $PROJECT_DIR/.tool-versions

  run current_command
  expected="baz            No version set for baz; please run \`asdf <global | local> baz <version>\`
dummy          1.1.0   (set by $PROJECT_DIR/.tool-versions)
foobar         1.0.0   (set by $PROJECT_DIR/.tool-versions)"

  [ "$expected" = "$output" ]
}

@test "should always match the tool name exactly" {
  install_dummy_plugin
  install_dummy_version "1.1.0"

  install_mock_plugin "y"
  install_mock_plugin_version "y" "2.1.0"

  cd $PROJECT_DIR
  echo 'dummy 1.1.0' >> $PROJECT_DIR/.tool-versions
  echo 'y 2.1.0' >> $PROJECT_DIR/.tool-versions

  run current_command "y"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "2.1.0" ]]
}



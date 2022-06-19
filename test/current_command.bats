#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version "1.1.0"
  install_dummy_version "1.2.0"
  install_dummy_version "nightly-2000-01-01"

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "current should derive from the current .tool-versions" {
  cd $PROJECT_DIR
  echo "dummy 1.1.0" >>$PROJECT_DIR/.tool-versions

  run asdf current "dummy"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "dummy" ]]
  [[ "$output" =~ "1.1.0" ]]
  [[ "$output" =~ "$PROJECT_DIR/.tool-versions" ]]
}

@test "current should handle long version name" {
  cd $PROJECT_DIR
  echo "dummy nightly-2000-01-01" >>$PROJECT_DIR/.tool-versions

  run asdf current "dummy"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "dummy" ]]
  [[ "$output" =~ "nightly-2000-01-01" ]]
  [[ "$output" =~ "$PROJECT_DIR/.tool-versions" ]]
}

@test "current should handle multiple versions" {
  cd $PROJECT_DIR
  echo "dummy 1.2.0 1.1.0" >>$PROJECT_DIR/.tool-versions

  run asdf current "dummy"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "dummy" ]]
  [[ "$output" =~ "1.2.0 1.1.0" ]]
  [[ "$output" =~ "$PROJECT_DIR/.tool-versions" ]]
}

@test "current should derive from the legacy file if enabled" {
  cd $PROJECT_DIR
  echo 'legacy_version_file = yes' >$HOME/.asdfrc
  echo '1.2.0' >>$PROJECT_DIR/.dummy-version
  expected="dummy 1.2.0 $PROJECT_DIR/.dummy-version"

  run asdf current "dummy"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "dummy" ]]
  [[ "$output" =~ "1.2.0" ]]
  [[ "$output" =~ "$PROJECT_DIR/.dummy-version" ]]
}

# TODO: Need to fix plugin error as well
@test "current should error when the plugin doesn't exist" {

  run asdf current "foobar"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "No such plugin" ]]
}

@test "current should error when no version is set" {
  cd $PROJECT_DIR

  run asdf current "dummy"
  [ "$status" -eq 126 ]
  [[ "$output" =~ "dummy" ]]
  [[ "$output" =~ "______" ]]
  [[ "$output" =~ "No version is set" ]]
}

@test "current should error when a version is set that isn't installed" {
  cd $PROJECT_DIR
  echo 'dummy 9.9.9' >>$PROJECT_DIR/.tool-versions

  run asdf current "dummy"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "dummy" ]]
  [[ "$output" =~ "9.9.9" ]]
  [[ "$output" =~ "Not installed" ]]
}

@test "should output all plugins when no plugin passed" {

  install_dummy_plugin
  install_dummy_version "1.1.0"

  install_mock_plugin "foobar"
  install_mock_plugin_version "foobar" "1.0.0"

  install_mock_plugin "baz"

  cd $PROJECT_DIR
  echo 'dummy 1.1.0' >>$PROJECT_DIR/.tool-versions
  echo 'foobar 1.0.0' >>$PROJECT_DIR/.tool-versions

  run asdf current
  [[ "${lines[0]}" =~ "baz" ]]
  [[ "${lines[0]}" =~ "______" ]]
  [[ "${lines[0]}" =~ "No version is set" ]]

  [[ "${lines[1]}" =~ "dummy" ]]
  [[ "${lines[1]}" =~ "1.1.0" ]]
  [[ "${lines[1]}" =~ "$PROJECT_DIR/.tool-versions" ]]

  [[ "${lines[2]}" =~ "foobar" ]]
  [[ "${lines[2]}" =~ "1.0.0" ]]
  [[ "${lines[2]}" =~ "$PROJECT_DIR/.tool-versions" ]]
}

@test "should always match the tool name exactly" {
  install_dummy_plugin
  install_dummy_version "1.1.0"

  install_mock_plugin "y"
  install_mock_plugin_version "y" "2.1.0"

  cd $PROJECT_DIR
  echo 'dummy 1.1.0' >>$PROJECT_DIR/.tool-versions
  echo 'y 2.1.0' >>$PROJECT_DIR/.tool-versions

  run asdf current "y"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "2.1.0" ]]
}

@test "with no plugins prints an error" {
  clean_asdf_dir
  expected="No plugins installed"

  run asdf current
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "current should handle comments" {
  cd $PROJECT_DIR
  echo "dummy 1.2.0  # this is a comment" >>$PROJECT_DIR/.tool-versions
  expected="dummy 1.2.0 $PROJECT_DIR/.tool-versions"

  run asdf current "dummy"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "dummy" ]]
  [[ "$output" =~ "1.2.0" ]]
  [[ "$output" =~ "$PROJECT_DIR/.tool-versions" ]]
}

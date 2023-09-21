load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version "1.1.0"
  install_dummy_version "1.2.0"
  install_dummy_version "nightly-2000-01-01"
}
teardown() {
  clean_asdf_dir
}

@test "shell_command with 'latest' version" {
  run asdf plugin add ruby
  run asdf install ruby 3.2.0
  run asdf shell ruby 3.2.0
  echo "Actual Output: $output"
  echo "Actual Exit Status: $status"
  [ "$status" -eq 0 ]
}

@test "asdf shell --unset-all removes all ASDF_{PLUGIN}_VERSION" {
  # mock data
  run export ASDF_DUMMY_VERSION="1.1.0"
  run asdf shell --unset-all
  echo "Actual Output: $output"
  echo "Actual Exit Status: $status"
  [ "$status" -eq 0 ]
}

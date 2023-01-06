#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_legacy_plugin
}

teardown() {
  clean_asdf_dir
}

####################################################
####       plugin with bin/latest-stable        ####
####################################################
@test "[latest_command - dummy_plugin] shows latest stable version" {
  run asdf latest dummy
  [ "$(echo "2.0.0")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "[latest_command - dummy_plugin] shows latest stable version that matches the given string" {
  run asdf latest dummy 1
  [ "$(echo "1.1.0")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "[latest_command - dummy_plugin] an invalid version should return an error" {
  run asdf latest dummy 3
  [ "$(echo "No compatible versions available (dummy 3)")" == "$output" ]
  [ "$status" -eq 1 ]
}

####################################################
####      plugin without bin/latest-stable      ####
####################################################
@test "[latest_command - dummy_legacy_plugin] shows latest stable version" {
  run asdf latest legacy-dummy
  echo "status: $status"
  echo "output: $output"
  [ "$(echo "5.1.0")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "[latest_command - dummy_legacy_plugin] shows latest stable version that matches the given string" {
  run asdf latest legacy-dummy 1
  echo "status: $status"
  echo "output: $output"
  [ "$(echo "1.1.0")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "[latest_command - dummy_legacy_plugin] No stable version should return an error" {
  run asdf latest legacy-dummy 3
  echo "status: $status"
  echo "output: $output"
  [ -z "$output" ]
  [ "$status" -eq 1 ]
}

@test "[latest_command - dummy_legacy_plugin] do not show latest unstable version that matches the given string" {
  run asdf latest legacy-dummy 4
  echo "status: $status"
  echo "output: $output"
  [ "$(echo "4.0.0")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "[latest_command - dummy_legacy_plugin] do not show latest unstable version with capital characters that matches the given string" {
  run asdf latest legacy-dummy 5
  echo "status: $status"
  echo "output: $output"
  [ "$(echo "5.1.0")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "[latest_command - dummy_legacy_plugin] an invalid version should return an error" {
  run asdf latest legacy-dummy 6
  echo "status: $status"
  echo "output: $output"
  [ "$(echo "No compatible versions available (legacy-dummy 6)")" == "$output" ]
  [ "$status" -eq 1 ]
}

################################
####      latest --all      ####
################################
@test "[latest_command - all plugins] shows the latest stable version of all plugins" {
  run asdf install dummy 2.0.0
  run asdf install legacy-dummy 4.0.0
  run asdf latest --all
  echo "output $output"
  [ "$(echo -e "dummy\t2.0.0\tinstalled\nlegacy-dummy\t5.1.0\tmissing\n")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "[latest_command - all plugins] not installed plugin should return missing" {
  run asdf latest --all
  [ "$(echo -e "dummy\t2.0.0\tmissing\nlegacy-dummy\t5.1.0\tmissing\n")" == "$output" ]
  [ "$status" -eq 0 ]
}

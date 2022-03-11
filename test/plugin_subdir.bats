#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "plugin_add install subdirectory plugin" {
  install_mock_subdir_plugin "dummy-subdir"

  run asdf plugin-list
  # whitespace between 'elixir' and url is from printf %-15s %s format
  [ "$output" = "dummy-subdir" ]
}

@test "plugin_remove command removes the subdirectory plugin directory" {
  install_mock_subdir_plugin "dummy-subdir"

  run asdf plugin-remove "dummy-subdir"
  [ "$status" -eq 0 ]
  [ ! -d "$ASDF_DIR/plugins/dummy-subdir" ]
}

@test "list_all_command lists available versions" {
  install_mock_subdir_plugin "dummy-subdir"

  run asdf list-all dummy-subdir
  [ "$(echo -e "1.0.0\n1.1.0\n2.0.0")" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "install_command installs the correct version" {
  install_mock_subdir_plugin "dummy-subdir"

  run asdf install dummy-subdir 1.1.0
  # whitespace between 'elixir' and url is from printf %-15s %s format
  [ "$(cat "$ASDF_DIR/installs/dummy-subdir/1.1.0/version")" = "1.1.0" ]
}

@test "list_command should list plugins with installed versions" {
  install_mock_subdir_plugin "dummy-subdir"

  run asdf install dummy-subdir 1.0.0
  run asdf install dummy-subdir 1.1.0
  run asdf list
  [[ "$output" == "$(echo -e "dummy-subdir\n  1.0.0\n  1.1.0")"* ]]
  [ "$status" -eq 0 ]
}

@test "[latest_command - dummy_plugin] shows latest stable version" {
  install_mock_subdir_plugin "dummy-subdir"

  run asdf latest "dummy-subdir"
  [ "2.0.0" == "$output" ]
  [ "$status" -eq 0 ]
}

@test "plugin_test_command works with no options provided for subdirectory plugin" {
  install_mock_subdir_plugin_repo dummy-subdir

  run asdf plugin-test dummy-subdir "${BASE_DIR}/repo-dummy-subdir"
  echo "status = ${status}"
  echo "output = ${output}"
  [ "$status" -eq 0 ]
}

@test "asdf plugin-update should pull latest default branch (refs/remotes/origin/HEAD) for subdirectory plugin" {
  install_mock_subdir_plugin_repo dummy-subdir
  run asdf plugin add "dummy-subdir" "${BASE_DIR}/repo-dummy-subdir"

  run asdf plugin-update dummy-subdir
  repo_head="$(git --git-dir "$ASDF_DIR/plugins/dummy-subdir/.git" --work-tree "$ASDF_DIR/plugins/dummy-subdir" rev-parse --abbrev-ref HEAD)"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Updating dummy-subdir to master"* ]]
  [ "$repo_head" = "master" ]
}

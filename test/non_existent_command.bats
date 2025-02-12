#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir

  PROJECT_DIR="$HOME/project"
  mkdir -p "$PROJECT_DIR"
}

@test "should show help when no valid command is provided" {
  cd "$PROJECT_DIR"

  run asdf non-existent-command

  [ "$status" -eq 1 ]
  [[ $output == 'invalid command provided:'* ]]
  [[ $output == *$'version: v'* ]]
  [[ $output == *$'MANAGE PLUGINS\n'* ]]
  [[ $output == *$'MANAGE TOOLS\n'* ]]
  [[ $output == *$'UTILS\n'* ]]
  [[ $output == *$'"Late but latest"\n-- Rajinikanth' ]]
}

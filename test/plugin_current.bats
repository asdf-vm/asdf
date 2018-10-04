#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/plugin-list.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/current.sh

@test "plugin_current command with no plugins errors" {
  run current_command
  [ "$status" -eq 0 ]
  echo "$output" | grep "Oohes nooes ~! No plugins installed"
}

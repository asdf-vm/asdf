#!/usr/bin/env bats

. $(dirname $BATS_TEST_DIRNAME)/test/helper.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/list-all.sh

setup() {
  prepare

  mkdir -p $ASDF_DIR/plugins/foo/bin
  echo 'echo 0.9 1.0 1.1' > $ASDF_DIR/plugins/foo/bin/list-all
  chmod +x $ASDF_DIR/plugins/foo/bin/list-all
}

@test "sort versions from the latest to the oldest" {
  run list_all_command foo
  expected=$(echo -e "1.1\n1.0\n0.9\n")
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

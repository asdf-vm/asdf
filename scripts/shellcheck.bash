#!/usr/bin/env bash

set -euo pipefail

# check .sh files
shellcheck --shell sh --external-sources \
  asdf.sh

# check .bash files
shellcheck --shell bash --external-sources \
  completions/*.bash \
  bin/asdf \
  bin/private/asdf-exec \
  lib/utils.bash \
  lib/commands/*.bash \
  lib/functions/*.bash \
  scripts/*.bash \
  test/test_helpers.bash \
  test/fixtures/dummy_broken_plugin/bin/* \
  test/fixtures/dummy_legacy_plugin/bin/* \
  test/fixtures/dummy_plugin/bin/*

shellcheck --shell bats --external-source \
  test/*.bats

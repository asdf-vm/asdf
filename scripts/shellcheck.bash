#!/usr/bin/env bash

set -euo pipefail

# check .sh files
# TODO(jthegedus): unlock this check later
# TODO  shellcheck --shell sh --external-sources \
# TODO  asdf.sh \
# TODO  lib/*.sh

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

#!/usr/bin/env bash

set -euo pipefail

# check .bash files
shfmt --language-dialect bash --indent 2 --write \
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

# check .bats files
shfmt --language-dialect bats --indent 2 --write \
  test/*.bats

# check .fish files
fish_indent --write ./**/*.fish

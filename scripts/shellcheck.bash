#!/usr/bin/env bash

set -euo pipefail

exec shellcheck -s bash -x \
  asdf.sh \
  completions/*.bash \
  bin/asdf \
  bin/private/asdf-exec \
  lib/utils.bash \
  lib/commands/*.bash \
  scripts/*.bash \
  test/test_helpers.bash \
  test/fixtures/dummy_plugin/bin/*

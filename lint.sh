#!/usr/bin/env bash
exec shellcheck -s bash -x \
     asdf.sh lint.sh release.sh \
     bin/asdf bin/private/asdf-exec \
     lib/utils.sh lib/commands/*.sh \
     completions/*.bash \
     test/test_helpers.bash \
     test/fixtures/dummy_plugin/bin/*

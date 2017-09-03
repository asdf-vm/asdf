#!/usr/bin/env bash

shellcheck -x asdf.sh lint.sh release.sh bin/asdf bin/private/asdf-exec completions/asdf.bash test/test_helpers.bash test/fixtures/dummy_plugin/bin/* lib/utils.sh # lib/commands/*.sh

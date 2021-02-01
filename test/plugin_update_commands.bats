#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

# INVALID COMMAND USAGE
# asdf plugin update
# errors, no provided plugin

# asdf plugin update <name> --all
# silent error, --all is ignored

# asdf plugin update <name> <gitref> --all
# silent error, --all is ignored

# TESTS FOR <NAME>
# asdf plugin update <name>
# success

# asdf plugin update <name>
# errors, plugin with name does not exist

# TESTS FOR <name> <gitref>
# asdf plugin update <name> <gitref>
# success

# asdf plugin update <name> <gitref>
# error, git ref does not exist

# TESTS FOR --all
# asdf plugin update --all
# multiple plugins are updated (plugins are on master branch as default)

# asdf plugin update --all
# multiple plugins are updated (plugins are on non-master branch as default)

#!/usr/bin/env bats
# shellcheck disable=SC2164

load test_helpers

setup() {
  cd "$BATS_TMPDIR"
  ASDF_CONFIG_FILE="$BATS_TMPDIR/asdfrc"
  cat >"$ASDF_CONFIG_FILE" <<-EOM
key1 = value1
legacy_version_file = yes
EOM

  ASDF_CONFIG_DEFAULT_FILE="$BATS_TMPDIR/asdfrc_defaults"
  cat >"$ASDF_CONFIG_DEFAULT_FILE" <<-EOM
# i have  a comment, it's ok
key2 = value2
legacy_version_file = no
EOM
}

teardown() {
  rm "$ASDF_CONFIG_FILE"
  rm "$ASDF_CONFIG_DEFAULT_FILE"
  unset ASDF_CONFIG_DEFAULT_FILE
  unset ASDF_CONFIG_FILE
}

@test "get_config returns default when config file does not exist" {
  result=$(ASDF_CONFIG_FILE="/some/fake/path" get_asdf_config_value "legacy_version_file")
  [ "$result" = "no" ]
}

@test "get_config returns default value when the key does not exist" {
  [ "$(get_asdf_config_value "key2")" = "value2" ]
}

@test "get_config returns config file value when key exists" {
  [ "$(get_asdf_config_value "key1")" = "value1" ]
  [ "$(get_asdf_config_value "legacy_version_file")" = "yes" ]
}

@test "get_config returns config file complete value including '=' symbols" {
  cat >>"$ASDF_CONFIG_FILE" <<-'EOM'
key3 = VAR=val
EOM

  [ "$(get_asdf_config_value "key3")" = "VAR=val" ]
}

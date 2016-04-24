#!/usr/bin/env bats

. $(dirname $BATS_TEST_DIRNAME)/lib/utils.sh

setup() {
    AZDF_CONFIG_FILE=$BATS_TMPDIR/asdfrc
    cat > $AZDF_CONFIG_FILE <<-EOM
key1 = value1
legacy_version_file = yes
EOM

    AZDF_CONFIG_DEFAULT_FILE=$BATS_TMPDIR/asdfrc_defaults
    cat > $AZDF_CONFIG_DEFAULT_FILE <<-EOM
# i have  a comment, it's ok
key2 = value2
legacy_version_file = no
EOM
}

teardown() {
    rm $AZDF_CONFIG_FILE
    rm $AZDF_CONFIG_DEFAULT_FILE
    unset AZDF_CONFIG_DEFAULT_FILE
    unset AZDF_CONFIG_FILE
}

@test "get_config returns default when config file does not exist" {
    result=$(AZDF_CONFIG_FILE="/some/fake/path" get_asdf_config_value "legacy_version_file")
    [ "$result" = "no" ]
}

@test "get_config returns default value when the key does not exist" {
    [ $(get_asdf_config_value "key2") = "value2" ]
}

@test "get_config returns config file value when key exists" {
    [ $(get_asdf_config_value "key1") = "value1" ]
    [ $(get_asdf_config_value "legacy_version_file") = "yes" ]
}

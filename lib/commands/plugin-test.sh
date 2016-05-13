fail_test() {
    echo "FAILED: $1"
    rm -rf $ASDF_DIR
    exit 1
}

plugin_test_command() {
    export ASDF_DIR=$(mktemp -dt asdf.XXXX)

    local plugin_name=$1
    local plugin_url=$2

    if [ -z "$plugin_name" -o -z "$plugin_url" ]; then
        fail_test "please provide a plugin name and url"
    fi

    (asdf plugin-add $plugin_name $plugin_url)
    if [ $? -ne 0 ]; then
        fail_test "could not install $plugin_name from $plugin_url"
    fi

    if ! asdf plugin-list | grep $plugin_name > /dev/null; then
        fail_test "$plugin_name was not properly installed"
    fi

    read -a versions <<< $(asdf list-all $plugin_name)

    if [ $? -ne 0 ]; then
        fail_test "list-all exited with an error"
    fi

    if [ ${#versions} -eq 0 ]; then
        fail_test "list-all did not return any version"
    fi

    (asdf install $plugin_name ${versions[0]})

    if [ $? -ne 0 ]; then
        fail_test "install exited with an error"
    fi

    rm -rf $ASDF_DIR
}

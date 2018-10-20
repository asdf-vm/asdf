plugin_test_command() {

    local plugin_name=$1
    local plugin_url=$2
    local plugin_command_array=()
    local plugin_command
    local tool_version
    # shellcheck disable=SC2086
    set -- ${*:3}

    while [[ $# -gt 0 ]]
    do
      case $1 in
        --asdf-tool-version)
          tool_version=$2
          shift # past flag
          shift # past value
          ;;
        *)
          plugin_command_array+=("$1") # save it in an array for later
          shift # past argument
          ;;
      esac
    done

    plugin_command="${plugin_command_array[*]}"

    local exit_code
    local TEST_DIR

    fail_test() {
        echo "FAILED: $1"
        rm -rf "$TEST_DIR"
        exit 1
    }

    if [ -z "$plugin_name" ] || [ -z "$plugin_url" ]; then
      fail_test "please provide a plugin name and url"
    fi

    TEST_DIR=$(mktemp -dt asdf.XXXX)
    git clone "$ASDF_DIR/.git" "$TEST_DIR"

    plugin_test() {
        export ASDF_DIR=$TEST_DIR
        export ASDF_DATA_DIR=$TEST_DIR

        # shellcheck disable=SC1090
        source "$ASDF_DIR/asdf.sh"

        if ! (asdf plugin-add "$plugin_name" "$plugin_url"); then
            fail_test "could not install $plugin_name from $plugin_url"
        fi

        if ! (asdf plugin-list | grep "^$plugin_name$" > /dev/null); then
            fail_test "$plugin_name was not properly installed"
        fi


        local plugin_path
        plugin_path=$(get_plugin_path "$plugin_name")
        local list_all="$plugin_path/bin/list-all"
        if grep api.github.com "$list_all" >/dev/null; then
            if ! grep Authorization "$list_all" >/dev/null; then
                echo
                echo "Looks like ${plugin_name}/bin/list-all relies on GitHub releases"
                echo "but it does not properly sets an Authorization header to prevent"
                echo "GitHub API rate limiting."
                echo
                echo "See https://github.com/asdf-vm/asdf/blob/master/docs/creating-plugins.md#github-api-rate-limiting"

                fail_test "$plugin_name/bin/list-all does not set GitHub Authorization token"
            fi

            # test for most common token names we have on plugins
            if [ -z "$OAUTH_TOKEN" ] || [ -z "$GITHUB_API_TOKEN" ] ; then
                echo "$plugin_name/bin/list-all is using GitHub API, just be sure you provide an API Authorization token"
                echo "via your travis settings. This is the current rate_limit:"
                echo
                curl -s https://api.github.com/rate_limit
                echo
            fi
        fi

        local versions
        # shellcheck disable=SC2046
        if ! read -r -a versions <<< $(asdf list-all "$plugin_name"); then
            fail_test "list-all exited with an error"
        fi

        if [ ${#versions} -eq 0 ]; then
            fail_test "list-all did not return any version"
        fi

        local version

        # Use the version passed in if it was set. Otherwise grab the latest
        # version from the versions list
        if [ -n "$tool_version" ]; then
          version="$tool_version"
        else
          version=${versions[${#versions[@]} - 1]}
        fi

        if ! (asdf install "$plugin_name" "$version"); then
            fail_test "install exited with an error"
        fi

        cd "$TEST_DIR" || fail_test "could not cd $TEST_DIR"

        if ! (asdf local "$plugin_name" "$version"); then
            fail_test "install did not add the requested version"
        fi

        if ! (asdf reshim "$plugin_name"); then
            fail_test "could not reshim plugin"
        fi

        if [ -n "$plugin_command" ]; then
            $plugin_command
            exit_code=$?
            if [ $exit_code != 0 ]; then
                fail_test "$plugin_command failed with exit code $?"
            fi
        fi

        # Assert the scripts in bin are executable by asdf
        for filename in "$ASDF_DIR/plugins/$plugin_name/bin"/*
        do
            if [ ! -x "$filename" ]; then
                fail_test "Incorrect permissions on $filename. Must be executable by asdf"
            fi
        done

        # Assert that a license file exists in the plugin repo and is not empty
        license_file="$ASDF_DIR/plugins/$plugin_name/LICENSE"
        if [ -f "$license_file" ]; then
            if [ ! -s "$license_file" ]; then
                fail_test "LICENSE file in the plugin repository must not be empty"
            fi
        else
            fail_test "LICENSE file must be present in the plugin repository"
        fi
    }

    # run test in a subshell
    (plugin_test)
    exit_code=$?
    rm -rf "$TEST_DIR"
    exit $exit_code
}

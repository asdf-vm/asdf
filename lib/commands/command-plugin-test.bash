# -*- sh -*-

plugin_test_command() {

  local plugin_name="$1"
  local plugin_url="$2"
  shift 2

  local plugin_gitref="master"
  local tool_version
  local interpret_args_literally
  local skip_next_arg

  for arg; do
    shift
    if [ -n "${skip_next_arg}" ]; then
      skip_next_arg=
    elif [ -n "${interpret_args_literally}" ]; then
      set -- "$@" "${arg}"
    else
      case "${arg}" in
      --asdf-plugin-gitref)
        plugin_gitref="$1"
        skip_next_arg=true
        ;;
      --asdf-tool-version)
        tool_version="$1"
        skip_next_arg=true
        ;;
      --)
        interpret_args_literally=true
        ;;
      *)
        set -- "$@" "${arg}"
        ;;
      esac
    fi
  done

  if [ "$#" -eq 1 ]; then
    set -- "${SHELL:-sh}" -c "$1"
  fi

  local exit_code
  local TEST_DIR

  fail_test() {
    printf "FAILED: %s\\n" "$1"
    rm -rf "$TEST_DIR"
    exit 1
  }

  if [ -z "$plugin_name" ] || [ -z "$plugin_url" ]; then
    fail_test "please provide a plugin name and url"
  fi

  TEST_DIR=$(mktemp -dt asdf.XXXX)
  cp -R "$(asdf_dir)/bin" "$TEST_DIR"
  cp -R "$(asdf_dir)/lib" "$TEST_DIR"
  cp "$(asdf_dir)/asdf.sh" "$TEST_DIR"

  plugin_test() {
    export ASDF_DIR=$TEST_DIR
    export ASDF_DATA_DIR=$TEST_DIR

    # shellcheck disable=SC1090
    . "$ASDF_DIR/asdf.sh"

    if ! (asdf plugin add "$plugin_name" "$plugin_url"); then
      fail_test "could not install $plugin_name from $plugin_url"
    fi

    if ! (asdf plugin-list | grep "^$plugin_name$" >/dev/null); then
      fail_test "$plugin_name was not properly installed"
    fi

    if ! (asdf plugin-update "$plugin_name" "$plugin_gitref"); then
      fail_test "failed to checkout $plugin_name gitref: $plugin_gitref"
    fi

    local plugin_path
    plugin_path=$(get_plugin_path "$plugin_name")
    local list_all="$plugin_path/bin/list-all"
    if grep api.github.com "$list_all" >/dev/null; then
      if ! grep Authorization "$list_all" >/dev/null; then
        printf "\\nLooks like %s/bin/list-all relies on GitHub releases\\n" "$plugin_name"
        printf "but it does not properly sets an Authorization header to prevent\\n"
        printf "GitHub API rate limiting.\\n\\n"
        printf "See https://github.com/asdf-vm/asdf/blob/master/docs/creating-plugins.md#github-api-rate-limiting\\n"

        fail_test "$plugin_name/bin/list-all does not set GitHub Authorization token"
      fi

      # test for most common token names we have on plugins. If both are empty show this warning
      if [ -z "$OAUTH_TOKEN" ] && [ -z "$GITHUB_API_TOKEN" ]; then
        printf "%s/bin/list-all is using GitHub API, just be sure you provide an API Authorization token\\n" "$plugin_name"
        printf "via your CI env GITHUB_API_TOKEN. This is the current rate_limit:\\n\\n"
        curl -s https://api.github.com/rate_limit
        printf "\\n"
      fi
    fi

    local versions
    # shellcheck disable=SC2046
    if ! read -r -a versions <<<$(asdf list-all "$plugin_name"); then
      fail_test "list-all exited with an error"
    fi

    if [ ${#versions} -eq 0 ]; then
      fail_test "list-all did not return any version"
    fi

    local version

    # Use the version passed in if it was set. Otherwise grab the latest
    # version from the versions list
    if [ -z "$tool_version" ] || [[ "$tool_version" == *"latest"* ]]; then
      version="$(asdf latest "$plugin_name" "$(sed -e 's#latest##;s#^:##' <<<"$tool_version")")"
      if [ -z "$version" ]; then
        fail_test "could not get latest version"
      fi
    else
      version="$tool_version"
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

    if [ "$#" -gt 0 ]; then
      "$@"
      exit_code=$?
      if [ $exit_code != 0 ]; then
        fail_test "$* failed with exit code $?"
      fi
    fi

    # Assert the scripts in bin are executable by asdf
    for filename in "$ASDF_DIR/plugins/$plugin_name/bin"/*; do
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
  (plugin_test "$@")
  exit_code=$?
  rm -rf "$TEST_DIR"
  exit $exit_code
}

plugin_test_command "$@"

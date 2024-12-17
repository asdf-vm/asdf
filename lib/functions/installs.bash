handle_failure() {
  local install_path="$1"
  rm -rf "$install_path"
  exit 1
}

handle_cancel() {
  local install_path="$1"
  printf "\nreceived sigint, cleaning up"
  handle_failure "$install_path"
}

install_command() {
  local plugin_name=$1
  local full_version=$2
  local extra_args="${*:3}"

  if [ "$plugin_name" = "" ] && [ "$full_version" = "" ]; then
    install_local_tool_versions "$extra_args"
  elif [[ $# -eq 1 ]]; then
    install_one_local_tool "$plugin_name"
  else
    install_tool_version "$plugin_name" "$full_version" "$extra_args"
  fi
}

get_concurrency() {
  local asdf_concurrency=

  if [ -n "$ASDF_CONCURRENCY" ]; then
    asdf_concurrency="$ASDF_CONCURRENCY"
  else
    asdf_concurrency=$(get_asdf_config_value 'concurrency')
  fi

  if [ "$asdf_concurrency" = 'auto' ]; then
    if command -v nproc &>/dev/null; then
      asdf_concurrency=$(nproc)
    elif command -v sysctl &>/dev/null && sysctl hw.ncpu &>/dev/null; then
      asdf_concurrency=$(sysctl -n hw.ncpu)
    elif [ -f /proc/cpuinfo ]; then
      asdf_concurrency=$(grep -c processor /proc/cpuinfo)
    else
      asdf_concurrency="1"
    fi
  fi

  printf "%s\n" "$asdf_concurrency"
}

install_one_local_tool() {
  local plugin_name=$1
  local search_path
  search_path=$PWD

  local plugin_versions

  local plugin_version

  local plugin_version_and_path
  plugin_version_and_path="$(find_versions "$plugin_name" "$search_path")"

  if [ -n "$plugin_version_and_path" ]; then
    local plugin_version
    plugin_versions=$(cut -d '|' -f 1 <<<"$plugin_version_and_path")
    for plugin_version in $plugin_versions; do
      install_tool_version "$plugin_name" "$plugin_version"
    done
  else
    printf "No versions specified for %s in config files or environment\n" "$plugin_name"
    exit 1
  fi
}

install_local_tool_versions() {
  local plugins_path
  plugins_path=$(get_plugin_path)

  local search_path
  search_path=$PWD

  local some_tools_installed
  local some_plugin_not_installed

  local tool_versions_path
  tool_versions_path=$(find_tool_versions)

  # Locate all the plugins installed in the system
  local plugins_installed
  if find "$plugins_path" -mindepth 1 -type d &>/dev/null; then
    for plugin_path in "$plugins_path"/*/; do
      local plugin_name
      plugin_name=$(basename "$plugin_path")
      plugins_installed="$plugins_installed $plugin_name"
    done
    plugins_installed=$(printf "%s" "$plugins_installed" | tr " " "\n")
  fi

  if [ -z "$plugins_installed" ]; then
    printf "Install plugins first to be able to install tools\n"
    exit 1
  fi

  # Locate all the plugins defined in the versions file.
  local tools_file
  if [ -f "$tool_versions_path" ]; then
    tools_file=$(strip_tool_version_comments "$tool_versions_path" | cut -d ' ' -f 1)
    for plugin_name in $tools_file; do
      if ! printf '%s\n' "${plugins_installed[@]}" | grep -q "^$plugin_name\$"; then
        printf "%s plugin is not installed\n" "$plugin_name"
        some_plugin_not_installed='yes'
      fi
    done
  fi

  if [ -n "$some_plugin_not_installed" ]; then
    exit 1
  fi

  if [ -n "$plugins_installed" ]; then
    for plugin_name in $plugins_installed; do
      local plugin_version_and_path
      plugin_version_and_path="$(find_versions "$plugin_name" "$search_path")"

      if [ -n "$plugin_version_and_path" ]; then
        local plugin_version
        some_tools_installed='yes'
        plugin_versions=$(cut -d '|' -f 1 <<<"$plugin_version_and_path")
        for plugin_version in $plugin_versions; do
          install_tool_version "$plugin_name" "$plugin_version"
        done
      fi
    done
  fi

  if [ -z "$some_tools_installed" ]; then
    printf "Either specify a tool & version in the command\n"
    printf "OR add .tool-versions file in this directory\n"
    printf "or in a parent directory\n"
    exit 1
  fi
}

install_tool_version() {
  local plugin_name=$1
  local full_version=$2
  local flags=$3
  local keep_download
  local plugin_path

  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"

  for flag in $flags; do
    case "$flag" in
    "--keep-download")
      keep_download=true
      shift
      ;;
    *)
      shift
      ;;
    esac
  done

  if [ "$full_version" = "system" ]; then
    return
  fi

  IFS=':' read -r -a version_info <<<"$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"

    if [ "${version_info[0]}" = "latest" ]; then
      local version
      version=$(latest_command "$plugin_name" "${version_info[1]}")
      full_version=$version
    else
      local version="${version_info[0]}"
    fi
  fi

  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")
  local download_path
  download_path=$(get_download_path "$plugin_name" "$install_type" "$version")
  local concurrency
  concurrency=$(get_concurrency)
  trap 'handle_cancel $install_path' INT

  if [ -d "$install_path" ]; then
    printf "%s %s is already installed\n" "$plugin_name" "$full_version"
  else

    if [ -f "${plugin_path}/bin/download" ]; then
      # Not a legacy plugin
      # Run the download script
      (
        # shellcheck disable=SC2030
        export ASDF_INSTALL_TYPE=$install_type
        # shellcheck disable=SC2030
        export ASDF_INSTALL_VERSION=$version
        # shellcheck disable=SC2030
        export ASDF_INSTALL_PATH=$install_path
        # shellcheck disable=SC2030
        export ASDF_DOWNLOAD_PATH=$download_path
        mkdir -p "$download_path"
        asdf_run_hook "pre_asdf_download_${plugin_name}" "$full_version"
        "${plugin_path}"/bin/download
      )
    fi

    local download_exit_code=$?
    if [ $download_exit_code -eq 0 ]; then
      (
        # shellcheck disable=SC2031
        export ASDF_INSTALL_TYPE=$install_type
        # shellcheck disable=SC2031
        export ASDF_INSTALL_VERSION=$version
        # shellcheck disable=SC2031
        export ASDF_INSTALL_PATH=$install_path
        # shellcheck disable=SC2031
        export ASDF_DOWNLOAD_PATH=$download_path
        # shellcheck disable=SC2031
        export ASDF_CONCURRENCY=$concurrency
        mkdir "$install_path"
        asdf_run_hook "pre_asdf_install_${plugin_name}" "$full_version"
        "${plugin_path}"/bin/install
      )
    fi

    local install_exit_code=$?
    if [ $install_exit_code -eq 0 ] && [ $download_exit_code -eq 0 ]; then
      # If the download directory should be kept, but isn't available, warn the user
      always_keep_download=$(get_asdf_config_value "always_keep_download")
      if [ "$keep_download" = "true" ] || [ "$always_keep_download" = "yes" ]; then
        if [ ! -d "$download_path" ]; then
          printf '%s\n' "asdf: Warn: You have configured asdf to preserve downloaded files (with always_keep_download=yes or --keep-download). But" >&2
          printf '%s\n' "asdf: Warn: the current plugin ($plugin_name) does not support that. Downloaded files will not be preserved." >&2
        fi
      # Otherwise, remove the download directory if it exists
      elif [ -d "$download_path" ]; then
        rm -r "$download_path"
      fi

      reshim_command "$plugin_name" "$full_version"

      asdf_run_hook "post_asdf_install_${plugin_name}" "$full_version"
    else
      handle_failure "$install_path"
    fi
  fi
}

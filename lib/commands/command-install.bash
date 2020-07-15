# -*- sh -*-

handle_failure() {
  local install_path="$1"
  rm -rf "$install_path"
  exit 1
}

handle_cancel() {
  local install_path="$1"
  echo -e "\\nreceived sigint, cleaning up"
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
  if command -v nproc >/dev/null 2>&1; then
    nproc
  elif command -v sysctl >/dev/null 2>&1 && sysctl hw.ncpu >/dev/null 2>&1; then
    sysctl -n hw.ncpu
  elif [ -f /proc/cpuinfo ]; then
    grep -c processor /proc/cpuinfo
  else
    echo "1"
  fi
}

install_one_local_tool() {
  local plugin_name=$1
  local search_path
  search_path=$(pwd)

  local plugin_versions

  local plugin_version

  local plugin_version_and_path
  plugin_version_and_path="$(find_versions "$plugin_name" "$search_path")"

  if [ -n "$plugin_version_and_path" ]; then
    local plugin_version
    some_tools_installed='yes'
    plugin_versions=$(cut -d '|' -f 1 <<<"$plugin_version_and_path")
    for plugin_version in $plugin_versions; do
      install_tool_version "$plugin_name" "$plugin_version"
    done
  else
    echo "No versions specified for $plugin_name in config files or environment"
    exit 1
  fi
}
install_local_tool_versions() {
  local plugins_path
  plugins_path=$(get_plugin_path)

  local search_path
  search_path=$(pwd)

  local some_tools_installed

  if ls "$plugins_path" &>/dev/null; then
    for plugin_path in "$plugins_path"/*; do
      local plugin_name
      plugin_name=$(basename "$plugin_path")

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
  else
    echo "Install plugins first to be able to install tools"
    exit 1
  fi

  if [ -z "$some_tools_installed" ]; then
    echo "Either specify a tool & version in the command"
    echo "OR add .tool-versions file in this directory"
    echo "or in a parent directory"
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
      version=$(asdf latest "$plugin_name" "${version_info[1]}")
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
    echo "$plugin_name $full_version is already installed"
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
        mkdir "$download_path"
        asdf_run_hook "pre_asdf_download_${plugin_name}" "$full_version"
        bash "${plugin_path}"/bin/download
      )
    fi

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
      bash "${plugin_path}"/bin/install
    )

    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
      # Remove download directory if --keep-download flag or always_keep_download config setting are not set
      always_keep_download=$(get_asdf_config_value "always_keep_download")
      if [ ! "$keep_download" = "true" ] && [ ! "$always_keep_download" = "yes" ] && [ -d "$download_path" ]; then
        rm -r "$download_path"
      fi

      asdf reshim "$plugin_name" "$full_version"

      asdf_run_hook "post_asdf_install_${plugin_name}" "$full_version"
    else
      handle_failure "$install_path"
    fi
  fi
}

install_command "$@"

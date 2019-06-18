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

  if [ "$plugin_name" = "" ] && [ "$full_version" = "" ]; then
    install_local_tool_versions
  elif [[ $# -eq 1 ]]; then
    display_error "You must specify a name and a version to install"
    exit 1
  else
    install_tool_version "$plugin_name" "$full_version"
  fi
}

get_concurrency() {
  if command -v nproc > /dev/null 2>&1; then
    nproc
  elif command -v sysctl > /dev/null 2>&1 && sysctl hw.ncpu > /dev/null 2>&1; then
    sysctl -n hw.ncpu
  elif [ -f /proc/cpuinfo ]; then
    grep -c processor /proc/cpuinfo
  else
    echo "1"
  fi
}

install_local_tool_versions() {
  local plugins_path
  plugins_path=$(get_plugin_path)

  local search_path
  search_path=$(pwd)

  local some_tools_installed

  if ls "$plugins_path" &> /dev/null; then
    for plugin_path in "$plugins_path"/* ; do
      local plugin_name
      plugin_name=$(basename "$plugin_path")

      local plugin_version_and_path
      plugin_version_and_path="$(find_version "$plugin_name" "$search_path")"

      if [ -n "$plugin_version_and_path" ]; then
        local plugin_version
        some_tools_installed='yes'
        plugin_version=$(cut -d '|' -f 1 <<< "$plugin_version_and_path")
        install_tool_version "$plugin_name" "$plugin_version"
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
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"

  if [ "$full_version" = "system" ]; then
    return
  fi

  IFS=':' read -r -a version_info <<< "$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi


  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")
  local concurrency
  concurrency=$(get_concurrency)
  trap 'handle_cancel $install_path' INT

  if [ -d "$install_path" ]; then
    echo "$plugin_name $full_version is already installed"
  else
    (
      export ASDF_INSTALL_TYPE=$install_type
      export ASDF_INSTALL_VERSION=$version
      export ASDF_INSTALL_PATH=$install_path
      export ASDF_CONCURRENCY=$concurrency
      mkdir "$install_path"
      asdf_run_hook "pre_asdf_install_${plugin_name}" "$full_version"
      bash "${plugin_path}"/bin/install
    )

    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
      reshim_command "$plugin_name" "$full_version"
      asdf_run_hook "post_asdf_install_${plugin_name}" "$full_version"
    else
      handle_failure "$install_path"
    fi
  fi
}

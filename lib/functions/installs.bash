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
  # This just checks the current directory
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

  local tools_installed
  if [ -n "$plugins_installed" ]; then
    plugins_installed=$(printf "%s" "$plugins_installed" | tr "\n" " " | awk '{$1=$1};1')
    display_debug "install_local_tool_versions: plugins_installed='$plugins_installed'"
    tools_installed=$(install_directory_tools_recursive "$search_path" "$plugins_installed")
  fi

  if [ -z "$tools_installed" ]; then
    printf "Either specify a tool & version in the command\n"
    printf "OR add .tool-versions file in this directory\n"
    printf "or in a parent directory\n"
    exit 1
  fi
}

install_directory_tools_recursive() {
  local search_path=$1
  local plugins_installed=$2
  local tools_installed=""

  display_debug "install_directory_tools_recursive '$search_path': entered with plugins_installed='$plugins_installed'"

  while [ "$search_path" != "/" ]; do
    # install tools from files in current directory
    display_debug "--------------------------------------------------------------------------------------------------------------"
    tools_installed=$(install_directory_tools "$search_path" "$plugins_installed" "$tools_installed")
    display_debug "install_directory_tools_recursive '$search_path': install_directory_tools returned tools_installed='$tools_installed'"

    # terminate if all tools are installed
    if [[ -n $(stringlist_same_length "$plugins_installed" "$tools_installed") ]]; then
      display_debug "install_directory_tools_recursive '$search_path': exiting as tools_installed has same length as plugins_installed: tools_installed='$tools_installed', plugins_installed='$plugins_installed'"
      printf "%s\n" "$tools_installed"
      return 0
    fi

    # go up a directory
    search_path=$(dirname "$search_path")
  done

  # still got some tools to install...
  # lets see if $ASDF_DEFAULT_TOOL_VERSIONS_FILENAME as actually
  # an absolute path
  if [ -f "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" ]; then
    display_debug "--------------------------------------------------------------------------------------------------------------"
    display_debug "attempting to treat \$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME as an absolute path: $ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"
    tools_installed=$(install_directory_tools_tools_versions "" "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" "$plugins_installed" "$tools_installed")
    display_debug "install_directory_tools_recursive '$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME': install_directory_tools returned tools_installed='$tools_installed'"
  fi

  printf "%s\n" "$tools_installed"
}

install_directory_tools() {
  local search_path=$1
  local plugins_installed=$2
  local tools_installed=$3
  display_debug "install_directory_tools '$search_path': starting install. tools_installed='$tools_installed'"

  # install tools from .tool-versions
  # install order is the order listed in .tool-versions
  file_name=$(asdf_tool_versions_filename)
  tools_installed=$(install_directory_tools_tools_versions "$search_path" "$file_name" "$plugins_installed" "$tools_installed")

  # install tools from legacy version files
  # install order is plugin order which is alphabetical
  local legacy_config
  legacy_config=$(get_asdf_config_value "legacy_version_file")
  if [ "$legacy_config" = "yes" ]; then
    tools_installed=$(install_directory_tools_legacy_versions "$search_path" "$plugins_installed" "$tools_installed")
  fi

  printf "%s\n" "$tools_installed"
}

install_directory_tools_tools_versions() {
  local search_path=$1
  local file_name=$2
  local plugins_installed=$3
  local tools_installed=$4
  # TODO when should we resolve tool version from the environment ?

  local tool_versions
  if ! [[ -f "$search_path/$file_name" ]]; then
    display_debug "install_directory_tools_tools_versions '$search_path': exiting early... $file_name file not found"
    printf "%s\n" "$tools_installed"
    return 0
  fi

  tool_versions=$(strip_tool_version_comments "$search_path/$file_name" | awk '{$1=$1};1')
  if [[ -z $tool_versions ]]; then
    display_debug "install_directory_tools_tools_versions '$search_path': exiting early... no tools found in directory"
    printf "%s\n" "$tools_installed"
    return 0
  fi
  while IFS=' ' read -r tool_version; do
    display_debug "install_directory_tools_tools_versions '$search_path': found '$tool_version'"

    # read one version from the file
    IFS=' ' read -ra parts <<< "$tool_version"
    local plugin_name
    plugin_name=${parts[0]}
    local plugin_version
    plugin_version=${parts[1]}

    # skip if plugin is installed already
    if [[ -n $(stringlist_contains "$tools_installed" "$plugin_name") ]]; then
      display_debug "install_directory_tools_tools_versions '$search_path': '$plugin_name' is already installed... skipping"
      continue
    fi

    # check if there is an environment override for it
    # if so take the environment version
    local env_version
    env_version=$(get_version_from_env "$plugin_name")
    if [ -n "$env_version" ]; then
      display_debug "install_directory_tools_tools_versions '$search_path': $plugin_name: using environment override $env_version"
      plugin_version=$env_version
    fi

    # install the version
    display_none $(install_tool_version "$plugin_name" "$plugin_version")
    tools_installed=$(echo "$tools_installed $plugin_name" | awk '{$1=$1};1')

    display_debug "install_directory_tools_tools_versions '$search_path': installed '$plugin_name':'$plugin_version' new state of tools_installed='$tools_installed'"
  done <<< $tool_versions

  printf "%s\n" "$tools_installed"
}

install_directory_tools_legacy_versions() {
  local search_path=$1
  local plugins_installed=$2
  local tools_installed=$3

  display_debug "install_directory_tools_legacy_versions '$search_path': resolving legacy files"
  local plugin_name
  for plugin_name in $plugins_installed; do
    # skip if plugin is installed already
    if [[ -n $(stringlist_contains "$tool_versions" "$plugin_name") ]]; then
      display_debug "install_directory_tools_legacy_versions '$search_path': legacy_install $plugin_name: skipping as tool was already installed"
      continue
    fi

    # extract plugin legacy information
    local plugin_path
    plugin_path=$(get_plugin_path "$plugin_name")
    local legacy_list_filenames_script
    legacy_list_filenames_script="${plugin_path}/bin/list-legacy-filenames"

    # skip if no legacy_list_filenames_script available
    if ! [[ -f "$legacy_list_filenames_script" ]]; then
      display_debug "install_directory_tools_legacy_versions '$search_path': legacy_install $plugin_name: skipping as legacy files are not supported"
      continue
    fi

    # extract plugin legacy filenames
    local legacy_filenames=""
    legacy_filenames=$("$legacy_list_filenames_script")

    # lookup plugin version in current dir
    local plugin_version
    plugin_version=$(get_legacy_version_in_dir "$plugin_name" "$search_path" "$legacy_filenames")

    # check if there is an environment override for it
    # if so take the environment version
    local env_version
    env_version=$(get_version_from_env "$plugin_name")
    if [ -n "$env_version" ]; then
      display_debug "install_directory_tools_legacy_versions '$search_path': legacy_install $plugin_name: using environment override $env_version"
      plugin_version=$env_version
    fi

    # skip if version cannot be found
    if [ -z "$plugin_version" ]; then
      display_debug "install_directory_tools_legacy_versions '$search_path': legacy_install $plugin_name: skipping as version cannot be found"
      continue
    fi

    display_debug "install_directory_tools_legacy_versions '$search_path': legacy_install $plugin_name: plugin_version='$plugin_version'"
    display_none $(install_tool_version "$plugin_name" "$plugin_version")

    tools_installed=$(echo "$tools_installed $plugin_name" | awk '{$1=$1};1')
    display_debug "install_directory_tools_legacy_versions '$search_path': legacy_install $plugin_name: installed '$plugin_version' new state of tools_installed='$tools_installed'"
  done

  printf "%s\n" "$tools_installed"
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
      # Remove download directory if --keep-download flag or always_keep_download config setting are not set
      always_keep_download=$(get_asdf_config_value "always_keep_download")
      if [ ! "$keep_download" = "true" ] && [ ! "$always_keep_download" = "yes" ]; then
        if [ -d "$download_path" ]; then
          rm -r "$download_path"
        else
          printf '%s\n' "asdf: Warn: You have configured asdf to preserve downloaded files (with always_keep_download=yes or --keep-download). But" >&2
          printf '%s\n' "asdf: Warn: the current plugin ($plugin_name) does not support that. Downloaded files will not be preserved." >&2
        fi
      fi

      reshim_command "$plugin_name" "$full_version"

      asdf_run_hook "post_asdf_install_${plugin_name}" "$full_version"
    else
      handle_failure "$install_path"
    fi
  fi
}

get_legacy_version_in_dir() {
  local plugin_name=$1
  local search_path=$2
  local legacy_filenames=$3

  local asdf_version
  for filename in $legacy_filenames; do
    local legacy_version
    legacy_version=$(parse_legacy_version_file "$search_path/$filename" "$plugin_name")

    if [ -n "$legacy_version" ]; then
      printf "%s\n" "$legacy_version"
      return 0
    fi
  done
}


stringlist_same_length() {
  IFS=' ' read -r -a array1 <<< "$1"
  IFS=' ' read -r -a array2 <<< "$2"
  if [[ ${#array1[@]} -eq ${#array2[@]} ]]; then
    printf "true\n"
    return 0
  fi
}

stringlist_contains() {
  local list=$1
  local search=$2
  local array
  IFS=' ' read -r -a array <<< "$list"
  for item in "${array[@]}"; do
    if [ $item = $search ]; then
      printf "true\n"
      return 0
    fi
  done
}

display_debug() {
  if [[ $DEBUG = "true" ]]; then
    printf "debug: %s\n" "$1" >&2
  fi
}

display_none() {
  printf ""
}

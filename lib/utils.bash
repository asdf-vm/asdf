# We shouldn't rely on the user's grep settings to be correct. If we set these
# here anytime asdf invokes grep it will be invoked with these options
# shellcheck disable=SC2034
GREP_OPTIONS="--color=never"
# shellcheck disable=SC2034
GREP_COLORS=

asdf_version() {
  local version git_rev
  version="v$(cat "$(asdf_dir)/version.txt")"
  if [ -d "$(asdf_dir)/.git" ]; then
    git_rev="$(git --git-dir "$(asdf_dir)/.git" rev-parse --short HEAD)"
    printf "%s-%s\n" "$version" "$git_rev"
  else
    printf "%s\n" "$version"
  fi
}

asdf_tool_versions_filename() {
  printf '%s\n' "${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME:-.tool-versions}"
}

asdf_config_file() {
  printf '%s\n' "${ASDF_CONFIG_FILE:-$HOME/.asdfrc}"
}

asdf_data_dir() {
  local data_dir

  if [ -n "${ASDF_DATA_DIR}" ]; then
    data_dir="${ASDF_DATA_DIR}"
  elif [ -n "$HOME" ]; then
    data_dir="$HOME/.asdf"
  else
    data_dir=$(asdf_dir)
  fi

  printf "%s\n" "$data_dir"
}

asdf_dir() {
  if [ -z "$ASDF_DIR" ]; then
    local current_script_path=${BASH_SOURCE[0]}
    printf '%s\n' "$(
      cd -- "$(dirname "$(dirname "$current_script_path")")" || exit
      printf '%s\n' "$PWD"
    )"
  else
    printf '%s\n' "$ASDF_DIR"
  fi
}

asdf_plugin_repository_url() {
  printf "https://github.com/asdf-vm/asdf-plugins.git\n"
}

get_install_path() {
  local plugin=$1
  local install_type=$2
  local version=$3

  local install_dir
  install_dir="$(asdf_data_dir)/installs"

  [ -d "${install_dir}/${plugin}" ] || mkdir -p "${install_dir}/${plugin}"

  if [ "$install_type" = "version" ]; then
    printf "%s/%s/%s\n" "$install_dir" "$plugin" "$version"
  elif [ "$install_type" = "path" ]; then
    printf "%s\n" "$version"
  else
    printf "%s/%s/%s-%s\n" "$install_dir" "$plugin" "$install_type" "$version"
  fi
}

get_download_path() {
  local plugin=$1
  local install_type=$2
  local version=$3

  local download_dir
  download_dir="$(asdf_data_dir)/downloads"

  [ -d "${download_dir}/${plugin}" ] || mkdir -p "${download_dir}/${plugin}"

  if [ "$install_type" = "version" ]; then
    printf "%s/%s/%s\n" "$download_dir" "$plugin" "$version"
  elif [ "$install_type" = "path" ]; then
    return
  else
    printf "%s/%s/%s-%s\n" "$download_dir" "$plugin" "$install_type" "$version"
  fi
}

list_installed_versions() {
  local plugin_name=$1
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  local plugin_installs_path
  plugin_installs_path="$(asdf_data_dir)/installs/${plugin_name}"

  if [ -d "$plugin_installs_path" ]; then
    for install in "${plugin_installs_path}"/*/; do
      [[ -e "$install" ]] || break
      basename "$install" | sed 's/^ref-/ref:/'
    done
  fi
}

check_if_plugin_exists() {
  local plugin_name=$1

  # Check if we have a non-empty argument
  if [ -z "${1}" ]; then
    display_error "No plugin given"
    exit 1
  fi

  if [ ! -d "$(asdf_data_dir)/plugins/$plugin_name" ]; then
    display_error "No such plugin: $plugin_name"
    exit 1
  fi
}

check_if_version_exists() {
  local plugin_name=$1
  local version=$2

  check_if_plugin_exists "$plugin_name"

  local install_path
  install_path=$(find_install_path "$plugin_name" "$version")

  if [ "$version" != "system" ] && [ ! -d "$install_path" ]; then
    exit 1
  fi
}

version_not_installed_text() {
  local plugin_name=$1
  local version=$2

  printf "version %s is not installed for %s\n" "$version" "$plugin_name"
}

get_plugin_path() {
  if [ -n "$1" ]; then
    printf "%s\n" "$(asdf_data_dir)/plugins/$1"
  else
    printf "%s\n" "$(asdf_data_dir)/plugins"
  fi
}

display_error() {
  printf "%s\n" "$1" >&2
}

get_version_in_dir() {
  local plugin_name=$1
  local search_path=$2
  local legacy_filenames=$3

  local asdf_version

  file_name=$(asdf_tool_versions_filename)
  asdf_version=$(parse_asdf_version_file "$search_path/$file_name" "$plugin_name")

  if [ -n "$asdf_version" ]; then
    printf "%s\n" "$asdf_version|$search_path/$file_name"
    return 0
  fi

  for filename in $legacy_filenames; do
    local legacy_version
    legacy_version=$(parse_legacy_version_file "$search_path/$filename" "$plugin_name")

    if [ -n "$legacy_version" ]; then
      printf "%s\n" "$legacy_version|$search_path/$filename"
      return 0
    fi
  done
}

find_versions() {
  local plugin_name=$1
  local search_path=$2

  local version
  version=$(get_version_from_env "$plugin_name")
  if [ -n "$version" ]; then
    local upcase_name
    upcase_name=$(printf "%s\n" "$plugin_name" | tr '[:lower:]-' '[:upper:]_')
    local version_env_var="ASDF_${upcase_name}_VERSION"

    printf "%s\n" "$version|$version_env_var environment variable"
    return 0
  fi

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  local legacy_config
  legacy_config=$(get_asdf_config_value "legacy_version_file")
  local legacy_list_filenames_script
  legacy_list_filenames_script="${plugin_path}/bin/list-legacy-filenames"
  local legacy_filenames=""

  if [ "$legacy_config" = "yes" ] && [ -f "$legacy_list_filenames_script" ]; then
    legacy_filenames=$("$legacy_list_filenames_script")
  fi

  while [ "$search_path" != "/" ]; do
    version=$(get_version_in_dir "$plugin_name" "$search_path" "$legacy_filenames")
    if [ -n "$version" ]; then
      printf "%s\n" "$version"
      return 0
    fi
    search_path=$(dirname "$search_path")
  done

  get_version_in_dir "$plugin_name" "$HOME" "$legacy_filenames"

  if [ -f "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" ]; then
    versions=$(parse_asdf_version_file "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" "$plugin_name")
    if [ -n "$versions" ]; then
      printf "%s\n" "$versions|$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"
      return 0
    fi
  fi
}

display_no_version_set() {
  local plugin_name=$1
  printf "No version is set for %s; please run \`asdf <global | shell | local> %s <version>\`\n" "$plugin_name" "$plugin_name"
}

get_version_from_env() {
  local plugin_name=$1
  local upcase_name
  upcase_name=$(printf "%s\n" "$plugin_name" | tr '[:lower:]-' '[:upper:]_')
  local version_env_var="ASDF_${upcase_name}_VERSION"
  local version=${!version_env_var:-}
  printf "%s\n" "$version"
}

find_install_path() {
  local plugin_name=$1
  local version=$2

  # shellcheck disable=SC2162
  IFS=':' read -a version_info <<<"$version"

  if [ "$version" = "system" ]; then
    printf "\n"
  elif [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
    get_install_path "$plugin_name" "$install_type" "$version"
  elif [ "${version_info[0]}" = "path" ]; then
    # This is for people who have the local source already compiled
    # Like those who work on the language, etc
    # We'll allow specifying path:/foo/bar/project in .tool-versions
    # And then use the binaries there
    local install_type="path"
    local version="path"

    util_resolve_user_path "${version_info[1]}"
    printf "%s\n" "${util_resolve_user_path_reply}"
  else
    local install_type="version"
    local version="${version_info[0]}"
    get_install_path "$plugin_name" "$install_type" "$version"
  fi
}

get_custom_executable_path() {
  local plugin_path=$1
  local install_path=$2
  local executable_path=$3

  # custom plugin hook for executable path
  if [ -x "${plugin_path}/bin/exec-path" ]; then
    cmd=$(basename "$executable_path")
    local relative_path
    # shellcheck disable=SC2001
    relative_path=$(printf "%s\n" "$executable_path" | sed -e "s|${install_path}/||")
    relative_path="$("${plugin_path}/bin/exec-path" "$install_path" "$cmd" "$relative_path")"
    executable_path="$install_path/$relative_path"
  fi

  printf "%s\n" "$executable_path"
}

get_executable_path() {
  local plugin_name=$1
  local version=$2
  local executable_path=$3

  check_if_version_exists "$plugin_name" "$version"

  if [ "$version" = "system" ]; then
    path=$(remove_path_from_path "$PATH" "$(asdf_data_dir)/shims")
    cmd=$(basename "$executable_path")
    cmd_path=$(PATH=$path command -v "$cmd" 2>&1)
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
      return 1
    fi
    printf "%s\n" "$cmd_path"
  else
    local install_path
    install_path=$(find_install_path "$plugin_name" "$version")
    printf "%s\n" "${install_path}"/"${executable_path}"
  fi
}

parse_asdf_version_file() {
  local file_path=$1
  local plugin_name=$2

  if [ -f "$file_path" ]; then
    local version
    version=$(strip_tool_version_comments "$file_path" | grep "^${plugin_name} " | sed -e "s/^${plugin_name} //")

    if [ -n "$version" ]; then
      if [[ "$version" == path:* ]]; then
        util_resolve_user_path "${version#path:}"
        printf "%s\n" "path:${util_resolve_user_path_reply}"
      else
        printf "%s\n" "$version"
      fi

      return 0
    fi
  fi
}

parse_legacy_version_file() {
  local file_path=$1
  local plugin_name=$2

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  local parse_legacy_script
  parse_legacy_script="${plugin_path}/bin/parse-legacy-file"

  if [ -f "$file_path" ]; then
    if [ -f "$parse_legacy_script" ]; then
      "$parse_legacy_script" "$file_path"
    else
      cat "$file_path"
    fi
  fi
}

get_preset_version_for() {
  local plugin_name=$1
  local search_path
  search_path=$PWD
  local version_and_path
  version_and_path=$(find_versions "$plugin_name" "$search_path")
  local version
  version=$(cut -d '|' -f 1 <<<"$version_and_path")

  printf "%s\n" "$version"
}

get_asdf_config_value_from_file() {
  local config_path=$1
  local key=$2

  if [ ! -f "$config_path" ]; then
    return 1
  fi

  util_validate_no_carriage_returns "$config_path"

  local result
  result=$(grep -E "^\s*$key\s*=\s*" "$config_path" | head | sed -e 's/^[^=]*= *//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  if [ -n "$result" ]; then
    printf "%s\n" "$result"
    return 0
  fi

  return 2
}

get_asdf_config_value() {
  local key=$1
  local config_path=
  config_path=$(asdf_config_file)
  local default_config_path=${ASDF_CONFIG_DEFAULT_FILE:-"$(asdf_dir)/defaults"}

  local local_config_path
  local_config_path="$(find_file_upwards ".asdfrc")"

  get_asdf_config_value_from_file "$local_config_path" "$key" ||
    get_asdf_config_value_from_file "$config_path" "$key" ||
    get_asdf_config_value_from_file "$default_config_path" "$key"
}

# Whether the plugin shortname repo needs to be synced
# 0: if no sync needs to occur
# 1: if sync needs to occur
repository_needs_update() {
  local plugin_repository_last_check_duration
  local sync_required

  plugin_repository_last_check_duration="$(get_asdf_config_value "plugin_repository_last_check_duration")"

  if [ "never" != "$plugin_repository_last_check_duration" ]; then
    local update_file_dir
    local update_file_name
    update_file_dir="$(asdf_data_dir)/tmp"
    update_file_name="repo-updated"
    # `find` outputs filename if it has not been modified in plugin_repository_last_check_duration setting.
    sync_required=$(find "$update_file_dir" -name "$update_file_name" -type f -mmin +"${plugin_repository_last_check_duration:-60}" -print)
  fi

  [ "$sync_required" ]
}

initialize_or_update_plugin_repository() {
  local repository_url
  local repository_path

  disable_plugin_short_name_repo="$(get_asdf_config_value "disable_plugin_short_name_repository")"
  if [ "yes" = "$disable_plugin_short_name_repo" ]; then
    printf "Short-name plugin repository is disabled\n" >&2
    exit 1
  fi

  repository_url=$(asdf_plugin_repository_url)
  repository_path=$(asdf_data_dir)/repository

  if [ ! -d "$repository_path" ]; then
    printf "initializing plugin repository..."
    git clone "$repository_url" "$repository_path"
  elif repository_needs_update; then
    printf "updating plugin repository..."
    git -C "$repository_path" fetch
    git -C "$repository_path" reset --hard origin/master
  fi

  [ -d "$(asdf_data_dir)/tmp" ] || mkdir -p "$(asdf_data_dir)/tmp"
  touch "$(asdf_data_dir)/tmp/repo-updated"
}

get_plugin_source_url() {
  local plugin_name=$1
  local plugin_config

  plugin_config="$(asdf_data_dir)/repository/plugins/$plugin_name"

  if [ -f "$plugin_config" ]; then
    grep "repository" "$plugin_config" | awk -F'=' '{print $2}' | sed 's/ //'
  fi
}

find_tool_versions() {
  find_file_upwards "$(asdf_tool_versions_filename)"
}

find_file_upwards() {
  local name="$1"
  local search_path
  search_path=$PWD
  while [ "$search_path" != "/" ]; do
    if [ -f "$search_path/$name" ]; then
      util_validate_no_carriage_returns "$search_path/$name"

      printf "%s\n" "${search_path}/$name"
      return 0
    fi
    search_path=$(dirname "$search_path")
  done
}

resolve_symlink() {
  local symlink
  symlink="$1"

  # This seems to be the only cross-platform way to resolve symlink paths to
  # the real file path.
  # shellcheck disable=SC2012
  resolved_path=$(ls -l "$symlink" | sed -e 's|.*-> \(.*\)|\1|') # asdf_allow: ls '

  # Check if resolved path is relative or not by looking at the first character.
  # If it is a slash we can assume it's root and absolute. Otherwise we treat it
  # as relative
  case $resolved_path in
  /*)
    printf "%s\n" "$resolved_path"
    ;;
  *)
    (
      cd "$(dirname "$symlink")" || exit 1
      printf "%s\n" "$PWD/$resolved_path"
    )
    ;;
  esac
}

list_plugin_bin_paths() {
  local plugin_name=$1
  local version=$2
  local install_type=$3
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

  if [ -f "${plugin_path}/bin/list-bin-paths" ]; then
    local space_separated_list_of_bin_paths

    # shellcheck disable=SC2030
    space_separated_list_of_bin_paths=$(
      export ASDF_INSTALL_TYPE=$install_type
      export ASDF_INSTALL_VERSION=$version
      export ASDF_INSTALL_PATH=$install_path
      "${plugin_path}/bin/list-bin-paths"
    )
  else
    local space_separated_list_of_bin_paths="bin"
  fi
  printf "%s\n" "$space_separated_list_of_bin_paths"
}

list_plugin_exec_paths() {
  local plugin_name=$1
  local full_version=$2
  check_if_plugin_exists "$plugin_name"

  IFS=':' read -r -a version_info <<<"$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  elif [ "${version_info[0]}" = "path" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  local plugin_shims_path
  plugin_shims_path=$(get_plugin_path "$plugin_name")/shims
  if [ -d "$plugin_shims_path" ]; then
    printf "%s\n" "$plugin_shims_path"
  fi

  space_separated_list_of_bin_paths="$(list_plugin_bin_paths "$plugin_name" "$version" "$install_type")"
  IFS=' ' read -r -a all_bin_paths <<<"$space_separated_list_of_bin_paths"

  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

  for bin_path in "${all_bin_paths[@]}"; do
    printf "%s\n" "$install_path/$bin_path"
  done
}

with_plugin_env() {
  local plugin_name=$1
  local full_version=$2
  local callback=$3

  IFS=':' read -r -a version_info <<<"$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  if [ "$version" = "system" ]; then
    # execute as is for system
    "$callback"
    return $?
  fi

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  # add the plugin listed exec paths to PATH
  local path exec_paths
  exec_paths="$(list_plugin_exec_paths "$plugin_name" "$full_version")"

  # exec_paths contains a trailing newline which is converted to a colon, so no
  # colon is needed between the subshell and the PATH variable in this string
  path="$(tr '\n' ':' <<<"$exec_paths")$PATH"

  # If no custom exec-env transform, just execute callback
  if [ ! -f "${plugin_path}/bin/exec-env" ]; then
    PATH=$path "$callback"
    return $?
  fi

  # Load the plugin custom environment
  local install_path
  install_path=$(find_install_path "$plugin_name" "$full_version")

  # shellcheck source=/dev/null
  ASDF_INSTALL_TYPE=$install_type \
    ASDF_INSTALL_VERSION=$version \
    ASDF_INSTALL_PATH=$install_path \
    . "${plugin_path}/bin/exec-env"

  PATH=$path "$callback"
}

plugin_executables() {
  local plugin_name=$1
  local full_version=$2
  local all_bin_paths
  IFS=$'\n' read -rd '' -a all_bin_paths <<<"$(list_plugin_exec_paths "$plugin_name" "$full_version")"
  for bin_path in "${all_bin_paths[@]}"; do
    for executable_file in "$bin_path"/*; do
      if is_executable "$executable_file"; then
        printf "%s\n" "$executable_file"
      fi
    done
  done
}

is_executable() {
  local executable_path=$1
  if [[ (-f "$executable_path") && (-x "$executable_path") ]]; then
    return 0
  fi
  return 1
}

plugin_shims() {
  local plugin_name=$1
  local full_version=$2
  grep -lx "# asdf-plugin: $plugin_name $full_version" "$(asdf_data_dir)/shims"/* 2>/dev/null
}

shim_plugin_versions() {
  local executable_name
  executable_name=$(basename "$1")
  local shim_path
  shim_path="$(asdf_data_dir)/shims/${executable_name}"
  if [ -x "$shim_path" ]; then
    grep "# asdf-plugin: " "$shim_path" 2>/dev/null | sed -e "s/# asdf-plugin: //" | uniq
  else
    printf "asdf: unknown shim %s\n" "$executable_name"
    return 1
  fi
}

shim_plugins() {
  local executable_name
  executable_name=$(basename "$1")
  local shim_path
  shim_path="$(asdf_data_dir)/shims/${executable_name}"
  if [ -x "$shim_path" ]; then
    grep "# asdf-plugin: " "$shim_path" 2>/dev/null | sed -e "s/# asdf-plugin: //" | cut -d' ' -f 1 | uniq
  else
    printf "asdf: unknown shim %s\n" "$executable_name"
    return 1
  fi
}

strip_tool_version_comments() {
  local tool_version_path="$1"
  # Use sed to strip comments from the tool version file
  # Breakdown of sed command:
  # This command represents 3 steps, separated by a semi-colon (;), that run on each line.
  # 1. Delete line if it starts with any blankspace and a #.
  # 2. Find a # and delete it and everything after the #.
  # 3. Remove any whitespace from the end of the line.
  # Finally, the command will print the lines that are not empty.
  sed '/^[[:blank:]]*#/d;s/#.*//;s/[[:blank:]]*$//' "$tool_version_path"
}

asdf_run_hook() {
  local hook_name=$1
  local hook_cmd
  hook_cmd="$(get_asdf_config_value "$hook_name")"
  if [ -n "$hook_cmd" ]; then
    asdf_hook_fun() {
      unset asdf_hook_fun
      ev'al' "$hook_cmd" # ignore banned command just here
    }
    asdf_hook_fun "${@:2}"
  fi
}

get_shim_versions() {
  shim_name=$1
  shim_plugin_versions "${shim_name}"
  shim_plugin_versions "${shim_name}" | cut -d' ' -f 1 | awk '{print$1" system"}'
}

preset_versions() {
  shim_name=$1
  shim_plugin_versions "${shim_name}" | cut -d' ' -f 1 | uniq | xargs -IPLUGIN bash -c ". $(asdf_dir)/lib/utils.bash; printf \"%s %s\n\" PLUGIN \$(get_preset_version_for PLUGIN)"
}

select_from_preset_version() {
  local shim_name=$1
  local shim_versions
  local preset_versions

  shim_versions=$(get_shim_versions "$shim_name")
  if [ -n "$shim_versions" ]; then
    preset_versions=$(preset_versions "$shim_name")
    grep -F "$shim_versions" <<<"$preset_versions" | head -n 1 | xargs -IVERSION printf "%s\n" VERSION
  fi
}

select_version() {
  shim_name=$1
  # First, we get the all the plugins where the
  # current shim is available.
  # Then, we iterate on all versions set for each plugin
  # Note that multiple plugin versions can be set for a single plugin.
  # These are separated by a space. e.g. python 3.7.2 2.7.15
  # For each plugin/version pair, we check if it is present in the shim
  local search_path
  search_path=$PWD
  local shim_versions
  IFS=$'\n' read -rd '' -a shim_versions <<<"$(get_shim_versions "$shim_name")"

  local plugins
  IFS=$'\n' read -rd '' -a plugins <<<"$(shim_plugins "$shim_name")"

  for plugin_name in "${plugins[@]}"; do
    local version_and_path
    local version_string
    local usable_plugin_versions
    local _path
    version_and_path=$(find_versions "$plugin_name" "$search_path")
    IFS='|' read -r version_string _path <<<"$version_and_path"
    IFS=' ' read -r -a usable_plugin_versions <<<"$version_string"
    for plugin_version in "${usable_plugin_versions[@]}"; do
      for plugin_and_version in "${shim_versions[@]}"; do
        local plugin_shim_name
        local plugin_shim_version
        IFS=' ' read -r plugin_shim_name plugin_shim_version <<<"$plugin_and_version"
        if [[ "$plugin_name" == "$plugin_shim_name" ]]; then
          if [[ "$plugin_version" == "$plugin_shim_version" ]]; then
            printf "%s\n" "$plugin_name $plugin_version"
            return
          elif [[ "$plugin_version" == "path:"* ]]; then
            printf "%s\n" "$plugin_name $plugin_version"
            return
          fi
        fi
      done
    done
  done
}

with_shim_executable() {
  local shim_name
  shim_name=$(basename "$1")
  local shim_exec="${2}"

  if [ ! -f "$(asdf_data_dir)/shims/${shim_name}" ]; then
    printf "%s %s %s\n" "unknown command:" "${shim_name}." "Perhaps you have to reshim?" >&2
    return 1
  fi

  local selected_version
  selected_version="$(select_version "$shim_name")"

  if [ -z "$selected_version" ]; then
    selected_version="$(select_from_preset_version "$shim_name")"
  fi

  if [ -n "$selected_version" ]; then
    local plugin_name
    local full_version
    local plugin_path

    IFS=' ' read -r plugin_name full_version <<<"$selected_version"
    plugin_path=$(get_plugin_path "$plugin_name")

    # This function does get invoked, but shellcheck sees it as unused code
    # shellcheck disable=SC2317
    run_within_env() {
      local path
      path=$(remove_path_from_path "$PATH" "$(asdf_data_dir)/shims")

      executable_path=$(PATH=$path command -v "$shim_name")

      if [ -x "${plugin_path}/bin/exec-path" ]; then
        install_path=$(find_install_path "$plugin_name" "$full_version")
        executable_path=$(get_custom_executable_path "${plugin_path}" "${install_path}" "${executable_path:-${shim_name}}")
      fi

      "$shim_exec" "$plugin_name" "$full_version" "$executable_path"
    }

    with_plugin_env "$plugin_name" "$full_version" run_within_env
    return $?
  fi

  (
    local preset_plugin_versions
    preset_plugin_versions=()
    local closest_tool_version
    closest_tool_version=$(find_tool_versions)

    local shim_plugins
    IFS=$'\n' read -rd '' -a shim_plugins <<<"$(shim_plugins "$shim_name")"
    for shim_plugin in "${shim_plugins[@]}"; do
      local shim_versions
      local version_string
      version_string=$(get_preset_version_for "$shim_plugin")
      IFS=' ' read -r -a shim_versions <<<"$version_string"
      local usable_plugin_versions
      for shim_version in "${shim_versions[@]}"; do
        preset_plugin_versions+=("$shim_plugin $shim_version")
      done
    done

    if [ -n "${preset_plugin_versions[*]}" ]; then
      printf "%s %s\n" "No preset version installed for command" "$shim_name"
      printf "%s\n\n" "Please install a version by running one of the following:"
      for preset_plugin_version in "${preset_plugin_versions[@]}"; do
        printf "%s %s\n" "asdf install" "$preset_plugin_version"
      done
      printf "\n%s %s\n" "or add one of the following versions in your config file at" "$closest_tool_version"
    else
      printf "%s %s\n" "No version is set for command" "$shim_name"
      printf "%s %s\n" "Consider adding one of the following versions in your config file at" "$closest_tool_version"
    fi
    shim_plugin_versions "${shim_name}"
  ) >&2

  return 126
}

substitute() {
  # Use Bash substitution rather than sed as it will handle escaping of all
  # strings for us.
  local input=$1
  local find_str=$2
  local replace=$3
  printf "%s" "${input//"$find_str"/"$replace"}"
}

remove_path_from_path() {
  # A helper function for removing an arbitrary path from the PATH variable.
  # Output is a new string suitable for assignment to PATH
  local PATH=$1
  local path=$2
  substitute "$PATH" "$path" "" | sed -e "s|::|:|g"
}

# @description Strings that began with a ~ are always paths. In
# that case, then ensure ~ it handled like a shell
util_resolve_user_path() {
  util_resolve_user_path_reply=
  local path="$1"

  # shellcheck disable=SC2088
  if [ "${path::2}" = '~/' ]; then
    util_resolve_user_path_reply="${HOME}/${path:2}"
  else
    util_resolve_user_path_reply="$path"
  fi
}

# @description Check if a file contains carriage returns. If it does, print a warning.
util_validate_no_carriage_returns() {
  local file_path="$1"

  if grep -qr $'\r' "$file_path"; then
    printf '%s\n' "asdf: Warning: File $file_path contains carriage returns. Please remove them." >&2
  fi
}

get_plugin_remote_url() {
  local plugin_name="$1"
  local plugin_path
  plugin_path="$(get_plugin_path "$plugin_name")"
  git --git-dir "$plugin_path/.git" remote get-url origin 2>/dev/null
}

get_plugin_remote_branch() {
  local plugin_name="$1"
  local plugin_path
  plugin_path="$(get_plugin_path "$plugin_name")"
  git --git-dir "$plugin_path/.git" rev-parse --abbrev-ref HEAD 2>/dev/null
}

get_plugin_remote_gitref() {
  local plugin_name="$1"
  local plugin_path
  plugin_path="$(get_plugin_path "$plugin_name")"
  git --git-dir "$plugin_path/.git" rev-parse --short HEAD 2>/dev/null
}

# We shouldn't rely on the user's grep settings to be correct. If we set these
# here anytime asdf invokes grep it will be invoked with these options
# shellcheck disable=SC2034
GREP_OPTIONS="--color=never"
# shellcheck disable=SC2034
GREP_COLORS=

asdf_version() {
  cat "$(asdf_dir)/VERSION"
}

asdf_dir() {
  if [ -z "$ASDF_DIR" ]; then
    local current_script_path=${BASH_SOURCE[0]}
    export ASDF_DIR
    ASDF_DIR=$(cd "$(dirname "$(dirname "$current_script_path")")" || exit; pwd)
  fi

  echo "$ASDF_DIR"
}

asdf_repository_url() {
  echo "https://github.com/asdf-vm/asdf-plugins.git"
}

asdf_data_dir(){
  local data_dir

  if [ -n "${ASDF_DATA_DIR}" ]; then
    data_dir="${ASDF_DATA_DIR}"
  else
    data_dir="$HOME/.asdf"
  fi

  echo "$data_dir"
}

get_install_path() {
  local plugin=$1
  local install_type=$2
  local version=$3

  local install_dir
  install_dir="$(asdf_data_dir)/installs"

  mkdir -p "${install_dir}/${plugin}"

  if [ "$install_type" = "version" ]
  then
    echo "${install_dir}/${plugin}/${version}"
  else
    echo "${install_dir}/${plugin}/${install_type}-${version}"
  fi
}

list_installed_versions() {
  local plugin_name=$1
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  local plugin_installs_path
  plugin_installs_path="$(asdf_data_dir)/installs/${plugin_name}"

  if [ -d "$plugin_installs_path" ]; then
    # shellcheck disable=SC2045
    for install in $(ls -d "${plugin_installs_path}"/*/ 2>/dev/null); do
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
    display_error "version $version is not installed for $plugin_name"
    exit 1
  fi
}

get_plugin_path() {
  echo "$(asdf_data_dir)/plugins/$1"
}

display_error() {
  echo >&2 "$1"
}

get_version_in_dir() {
  local plugin_name=$1
  local search_path=$2
  local legacy_filenames=$3

  local asdf_version
  asdf_version=$(parse_asdf_version_file "$search_path/.tool-versions" "$plugin_name")

  if [ -n "$asdf_version" ]; then
    echo "$asdf_version|$search_path/.tool-versions"
    return 0
  fi

  for filename in $legacy_filenames; do
    local legacy_version
    legacy_version=$(parse_legacy_version_file "$search_path/$filename" "$plugin_name")

    if [ -n "$legacy_version" ]; then
      echo "$legacy_version|$search_path/$filename"
      return 0
    fi
  done
}

find_version() {
  local plugin_name=$1
  local search_path=$2

  local version
  version=$(get_version_from_env "$plugin_name")
  if [ -n "$version" ]; then
      local upcase_name
      upcase_name=$(echo "$plugin_name" | tr '[:lower:]-' '[:upper:]_')
      local version_env_var="ASDF_${upcase_name}_VERSION"

      echo "$version|$version_env_var environment variable"
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
    legacy_filenames=$(bash "$legacy_list_filenames_script")
  fi

  while [ "$search_path" != "/" ]; do
    version=$(get_version_in_dir "$plugin_name" "$search_path" "$legacy_filenames")
    if [ -n "$version" ]; then
      echo "$version"
      return 0
    fi
    search_path=$(dirname "$search_path")
  done

  get_version_in_dir "$plugin_name" "$HOME" "$legacy_filenames"

  if [ -f "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" ]; then
    version=$(parse_asdf_version_file "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" "$plugin_name")
    if [ -n "$version" ]; then
      echo "$version|$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"
      return 0
    fi
  fi
}

display_no_version_set() {
  local plugin_name=$1
  echo "No version set for ${plugin_name}; please run \`asdf <global | local> ${plugin_name} <version>\`"
}

get_version_from_env () {
  local plugin_name=$1
  local upcase_name
  upcase_name=$(echo "$plugin_name" | tr '[:lower:]-' '[:upper:]_')
  local version_env_var="ASDF_${upcase_name}_VERSION"
  local version=${!version_env_var}
  echo "$version"
}

find_install_path() {
  local plugin_name=$1
  local version=$2

  # shellcheck disable=SC2162
  IFS=':' read -a version_info <<< "$version"

  if [ "$version" = "system" ]; then
    echo ""
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
    echo "${version_info[1]}"
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
    executable_path="$("${plugin_path}/bin/exec-path" "$install_path" "$cmd" "$executable_path")"
  fi

  echo "$executable_path"
}

get_executable_path() {
  local plugin_name=$1
  local version=$2
  local executable_path=$3

  check_if_version_exists "$plugin_name" "$version"

  if [ "$version" = "system" ]; then
    path=$(echo "$PATH" | sed -e "s|$(asdf_data_dir)/shims||g; s|::|:|g")
    cmd=$(basename "$executable_path")
    cmd_path=$(PATH=$path command -v "$cmd" 2>&1)
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
      return 1
    fi
    echo "$cmd_path"
  else
    local install_path
    install_path=$(find_install_path "$plugin_name" "$version")
    echo "${install_path}"/"${executable_path}"
  fi
}

parse_asdf_version_file() {
  local file_path=$1
  local plugin_name=$2

  if [ -f "$file_path" ]; then
    local version
    version=$(grep "^${plugin_name} " "$file_path" | sed -e "s/^${plugin_name} //")
    if [ -n "$version" ]; then
      echo "$version"
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
      bash "$parse_legacy_script" "$file_path"
    else
      cat "$file_path"
    fi
  fi
}

get_preset_version_for() {
  local plugin_name=$1
  local search_path
  search_path=$(pwd)
  local version_and_path
  version_and_path=$(find_version "$plugin_name" "$search_path")
  local version
  version=$(cut -d '|' -f 1 <<< "$version_and_path");

  echo "$version"
}

get_asdf_config_value_from_file() {
  local config_path=$1
  local key=$2

  if [ ! -f "$config_path" ]; then
    return 0
  fi

  local result
  result=$(grep -E "^\\s*$key\\s*=" "$config_path" | awk -F '=' '{ gsub(/ /, "", $2); print $2 }')
  if [ -n "$result" ]; then
    echo "$result"
  fi
}

get_asdf_config_value() {
  local key=$1
  local config_path=${ASDF_CONFIG_FILE:-"$HOME/.asdfrc"}
  local default_config_path=${ASDF_CONFIG_DEFAULT_FILE:-"$(asdf_dir)/defaults"}

  local result
  result=$(get_asdf_config_value_from_file "$config_path" "$key")

  if [ -n "$result" ]; then
    echo "$result"
  else
    get_asdf_config_value_from_file "$default_config_path" "$key"
  fi
}

repository_needs_update() {
  local update_file_dir
  update_file_dir="$(asdf_data_dir)/tmp"
  local update_file_name
  update_file_name="repo-updated"
  # `find` outputs filename if it has not been modified in the last day
  local find_result
  find_result=$(find "$update_file_dir" -name "$update_file_name" -type f -mtime +1 -print)
  [ -n "$find_result" ]
}

initialize_or_update_repository() {
  local repository_url
  local repository_path

  repository_url=$(asdf_repository_url)
  repository_path=$(asdf_data_dir)/repository

  if [ ! -d "$repository_path" ]; then
    echo "initializing plugin repository..."
    git clone "$repository_url" "$repository_path"
  elif repository_needs_update; then
    echo "updating plugin repository..."
    (cd "$repository_path" && git fetch && git reset --hard origin/master)
  fi

  mkdir -p "$(asdf_data_dir)/tmp"
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
  local search_path
  search_path=$(pwd)
  while [ "$search_path" != "/" ]; do
    if [ -f "$search_path/.tool-versions" ]; then
        echo "${search_path}/.tool-versions"
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
  resolved_path=$(ls -l "$symlink" | sed -e 's|.*-> \(.*\)|\1|')

  # Check if resolved path is relative or not by looking at the first character.
  # If it is a slash we can assume it's root and absolute. Otherwise we treat it
  # as relative
  case $resolved_path in
    /*)
      echo "$resolved_path"
      ;;
    *)
      echo "$PWD/$resolved_path"
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
      bash "${plugin_path}/bin/list-bin-paths"
                                     )
  else
    local space_separated_list_of_bin_paths="bin"
  fi
  echo "$space_separated_list_of_bin_paths"
}

list_plugin_exec_paths() {
  local plugin_name=$1
  local full_version=$2
  check_if_plugin_exists "$plugin_name"

  IFS=':' read -r -a version_info <<< "$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  local plugin_shims_path
  plugin_shims_path=$(get_plugin_path "$plugin_name")/shims
  if [ -d "$plugin_shims_path" ]; then
    echo "$plugin_shims_path"
  fi

  space_separated_list_of_bin_paths="$(list_plugin_bin_paths "$plugin_name" "$version" "$install_type")"
  IFS=' ' read -r -a all_bin_paths <<< "$space_separated_list_of_bin_paths"

  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

  for bin_path in "${all_bin_paths[@]}"; do
    echo "$install_path/$bin_path"
  done
}

plugin_exec_env() {
  local plugin_name=$1
  local version=$2

  if [ "$version" = "system" ]; then
    PATH=$(echo "$PATH" | sed -e "s|$(asdf_data_dir)/shims||g; s|::|:|g")
    export PATH
    return 0
  fi

  check_if_plugin_exists "$plugin_name"

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  PATH="$(list_plugin_exec_paths "$plugin_name" "$version" | tr '\n' ':'):$PATH"
  export PATH

  if [ -f "${plugin_path}/bin/exec-env" ]; then
    ASDF_INSTALL_TYPE=$install_type
    ASDF_INSTALL_VERSION=$version
    ASDF_INSTALL_PATH=$install_path

    export ASDF_INSTALL_TYPE
    export ASDF_INSTALL_VERSION
    export ASDF_INSTALL_PATH
    # shellcheck source=/dev/null
    source "${plugin_path}/bin/exec-env"

    # unset everything, we don't want to pollute
    unset ASDF_INSTALL_TYPE
    unset ASDF_INSTALL_VERSION
    unset ASDF_INSTALL_PATH
  fi
}

plugin_executables() {
  local plugin_name=$1
  local full_version=$2
  for bin_path in $(list_plugin_exec_paths "$plugin_name" "$full_version"); do
    for executable_file in "$bin_path"/*; do
      if is_executable "$executable_file"; then
        echo "$executable_file"
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
  grep -l "# asdf-plugin: $plugin_name $full_version" "$(asdf_data_dir)/shims"/* 2>/dev/null
}

shim_plugin_versions() {
  local executable_name
  executable_name=$(basename "$1")
  local shim_path
  shim_path="$(asdf_data_dir)/shims/${executable_name}"
  if [ -x "$shim_path" ]; then
    grep -y "# asdf-plugin: " "$shim_path" 2>/dev/null | sed -e "s/# asdf-plugin: //" | uniq
  else
    echo "asdf: unknown shim $executable_name"
    return 1
  fi
}



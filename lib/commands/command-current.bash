# -*- sh -*-
# shellcheck source=lib/functions/plugins.bash
. "$(dirname "$(dirname "$0")")/lib/functions/plugins.bash"

# shellcheck disable=SC2059
plugin_current_command() {
  local plugin_name=$1
  local terminal_format=$2

  check_if_plugin_exists "$plugin_name"

  local search_path
  search_path=$(pwd)
  local version_and_path
  version_and_path=$(find_versions "$plugin_name" "$search_path")
  local full_version
  full_version=$(cut -d '|' -f 1 <<<"$version_and_path")
  local version_file_path
  version_file_path=$(cut -d '|' -f 2 <<<"$version_and_path")
  local version_not_installed
  local description=""

  IFS=' ' read -r -a versions <<<"$full_version"
  for version in "${versions[@]}"; do
    if ! (check_if_version_exists "$plugin_name" "$version"); then
      version_not_installed="$version"
    fi
  done
  check_for_deprecated_plugin "$plugin_name"

  if [ -n "$version_not_installed" ]; then
    description="Not installed. Run \"asdf install $plugin $version\""
    printf "$terminal_format" "$plugin" "$version" "$description" 1>&2
    return 1
  elif [ -z "$full_version" ]; then
    description="No version is set. Run \"asdf <global|shell|local> $plugin <version>\""
    printf "$terminal_format" "$plugin" "______" "$description" 1>&2
    return 126
  else
    description="$version_file_path"
    printf "$terminal_format" "$plugin" "$full_version" "$description"
  fi
}

# shellcheck disable=SC2059
current_command() {
  local terminal_format="%s %s %s\\n"
  local exit_status=0
  local plugin
  declare -A collected_currents
  declare -A max_widths
  declare -A min_widths

  # Set initial column widths to max the terminal can support
  local terminal_width
  terminal_width=$(stty size | cut -d ' ' -f 2)
  # reset if less than 80 cols, likely reading the wrong device
  if [ "$terminal_width" -lt 80 ]; then
    terminal_width=80
  fi
  # leave room for spaces
  terminal_width=$((terminal_width - 3))

  # Integer divison, but floors/truncates so we should have a couple characters left over instead of running to the next line
  max_widths[name]=$((terminal_width / 4))
  max_widths[version]=$((terminal_width / 4))
  max_widths[path]=$((terminal_width * 2 / 4))

  min_widths[name]=10
  min_widths[version]=10
  min_widths[path]=20

  # disable this until we release headings across the board
  # printf "$terminal_format" "PLUGIN" "VERSION" "SET BY CONFIG"
  if [ $# -eq 0 ]; then
    # shellcheck disable=SC2119
    for plugin in $(plugin_list_command); do
      collected_currents[$plugin]=$(plugin_current_command "$plugin" "$terminal_format")

      local plugin_name
      plugin_name=$(cut -d ' ' -f 1 <<<"${collected_currents[$plugin]}")
      local plugin_version
      plugin_version=$(cut -d ' ' -f 2 <<<"${collected_currents[$plugin]}")
      local plugin_path
      plugin_path=$(cut -d ' ' -f 3 <<<"${collected_currents[$plugin]}")

      if [ "${min_widths[name]}" -lt ${#plugin_name} ]; then
        # printf "${plugin_name} has a long name!\\n"
        min_widths[name]=${#plugin_name}
      fi
      if [ "${min_widths[version]}" -lt ${#plugin_version} ]; then
        # printf "${plugin_name} has a long version!\\n"
        min_widths[version]=${#plugin_version}
      fi
      if [ "${min_widths[path]}" -lt ${#plugin_path} ]; then
        # printf "${plugin_name} has a long path!\\n"
        min_widths[path]=${#plugin_path}
      fi
    done

    # make first 2 cols equal size, make second as large as it needs to if there's room?
    terminal_format="%-${min_widths[name]}.${max_widths[name]}s  %-${min_widths[version]}.${max_widths[version]}s  %-${min_widths[path]}.${max_widths[path]}s\\n"

    for plugin in "${!collected_currents[@]}"; do
      local plugin_name
      plugin_name=$(cut -d ' ' -f 1 <<<"${collected_currents[$plugin]}")
      local plugin_version
      plugin_version=$(cut -d ' ' -f 2 <<<"${collected_currents[$plugin]}")
      local plugin_path
      plugin_path=$(cut -d ' ' -f 3 <<<"${collected_currents[$plugin]}")
      printf "$terminal_format" "$plugin_name" "$plugin_version" "${plugin_path}"
    done

  else
    plugin=$1
    plugin_current_command "$plugin" "$terminal_format"
    exit_status="$?"
  fi

  exit "$exit_status"
}

# Warn if the plugin isn't using the updated legacy file api.
check_for_deprecated_plugin() {
  local plugin_name=$1

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  local legacy_config
  legacy_config=$(get_asdf_config_value "legacy_version_file")
  local deprecated_script="${plugin_path}/bin/get-version-from-legacy-file"
  local new_script="${plugin_path}/bin/list-legacy-filenames"

  if [ "$legacy_config" = "yes" ] && [ -f "$deprecated_script" ] && [ ! -f "$new_script" ]; then
    printf "Heads up! It looks like your %s plugin is out of date. You can update it with:\\n\\n" "$plugin_name"
    printf "  asdf plugin-update %s\\n\\n" "$plugin_name"
  fi
}

current_command "$@"

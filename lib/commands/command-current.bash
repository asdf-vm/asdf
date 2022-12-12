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
    printf "$terminal_format" "$plugin" "$version" "$description"
    return 1
  elif [ -z "$full_version" ]; then
    description="No version is set. Run \"asdf <global|shell|local> $plugin <version>\""
    printf "$terminal_format" "$plugin" "______" "$description"
    return 126
  else
    description="$version_file_path"
    printf "$terminal_format" "$plugin" "$full_version" "$description"
  fi
}

# shellcheck disable=SC2059
current_command() {
  local terminal_format="%s\t%s\t%s\\n"
  local exit_status=0
  local verbose
  local tsv
  local all_plugins
  # shellcheck disable=SC2119
  all_plugins=$(plugin_list_command)
  local plugin
  declare -A collected_currents
  declare -A max_widths
  declare -A widths

  for flag in "$@"; do
    case "$flag" in
    "--verbose")
      verbose=true
      shift
      ;;
    "--tsv")
      tsv=true
      verbose=true
      shift
      ;;
    *) ;;
    esac
  done

  # Set initial column widths to max the terminal can support
  local terminal_width
  terminal_width=$(stty size | cut -d ' ' -f 2)

  # reset if less than 80 cols, likely reading the wrong device
  if [ "$terminal_width" -lt 80 ]; then
    terminal_width=80
  fi

  # leave room for spaces
  terminal_width=$((terminal_width - 3))

  max_widths[name]=$((terminal_width / 4))
  max_widths[version]=$((terminal_width / 4))
  max_widths[path]=$((terminal_width * 2 / 4))

  widths[name]=10
  widths[version]=10
  widths[path]=20

  # disable this until we release headings across the board
  # printf "$terminal_format" "PLUGIN" "VERSION" "SET BY CONFIG"

  if [ $# -eq 0 ]; then
    # shellcheck disable=SC2068
    for plugin in ${all_plugins[@]}; do
      collected_currents[$plugin]=$(plugin_current_command "$plugin" "$terminal_format")
    done
  else
    plugin=$1
    collected_currents[$plugin]=$(plugin_current_command "$plugin" "$terminal_format")
    exit_status="$?"
  fi

  # Set column widths/precision
  # This ensures names/versions are aligned and take up minimal space
  # shellcheck disable=SC2068
  for plugin in ${all_plugins[@]}; do
    local plugin_name
    plugin_name=$(cut -f 1 <<<"${collected_currents[$plugin]}")
    local plugin_version
    plugin_version=$(cut -f 2 <<<"${collected_currents[$plugin]}")
    local plugin_path
    plugin_path=$(cut -f 3 <<<"${collected_currents[$plugin]}")

    if [ "${widths[name]}" -lt ${#plugin_name} ]; then
      widths[name]=${#plugin_name}
    fi
    if [ "${widths[version]}" -lt ${#plugin_version} ]; then
      widths[version]=${#plugin_version}
    fi
    if [ "${widths[path]}" -lt ${#plugin_path} ]; then
      widths[path]=${#plugin_path}
    fi
  done

  # Re-allocate width to path if possible
  # This helps ensure we see the full error if a plugin/version is not installed
  if [ "${widths[name]}" -lt "${max_widths[name]}" ]; then
    max_widths[path]=$((max_widths[path] + max_widths[name] - widths[name]))
    max_widths[name]=${widths[name]}
  fi
  if [ "${widths[version]}" -lt "${max_widths[version]}" ]; then
    max_widths[path]=$((max_widths[path] + max_widths[version] - widths[version]))
    max_widths[version]=${widths[version]}
  fi

  # If verbose flag was passed, skip calculating widths so we always print everything
  if [ -n "$verbose" ]; then
    max_widths[name]=${widths[name]}
    max_widths[version]=${widths[version]}
    max_widths[path]=${widths[path]}
  fi

  # If tsv flag was passed, use tab delimited fields instead of variable spaces
  # tsv implies verbose
  if [ -z "$tsv" ]; then
    terminal_format="%-${widths[name]}s %-${widths[version]}s %-s\\n"
  fi

  # If we're still exceeding the max width for a column, truncate it with three dots
  # shellcheck disable=SC2068
  for plugin in ${all_plugins[@]}; do
    if [[ -n ${collected_currents[$plugin]} ]]; then
      local plugin_name
      plugin_name=$(awk -F'\t' -v max=$((max_widths[name])) '{ print ( length($1) > max ? substr($1, 1, max-3) "..." : $1 ) }' <<<"${collected_currents[$plugin]}")
      local plugin_version
      plugin_version=$(awk -F'\t' -v max=$((max_widths[version])) '{ print ( length($2) > max ? substr($2, 1, max-3) "..." : $2 ) }' <<<"${collected_currents[$plugin]}")
      local plugin_path
      plugin_path=$(awk -F'\t' -v max=$((max_widths[path])) '{ print ( length($3) > max ? substr($3, 1, max-3) "..." : $3 ) }' <<<"${collected_currents[$plugin]}")

      printf "$terminal_format" "$plugin_name" "$plugin_version" "${plugin_path}"
    fi
  done

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

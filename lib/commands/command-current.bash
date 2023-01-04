# -*- sh -*-
# shellcheck source=lib/functions/plugins.bash
. "$(dirname "$(dirname "$0")")/lib/functions/plugins.bash"

# shellcheck disable=SC2059
plugin_current_command() {
  local plugin_name=$1
  local terminal_format=$2

  check_if_plugin_exists "$plugin_name"

  local search_path
  search_path=$PWD
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
  local terminal_format="%-15s %-15s %-10s\n"
  local exit_status=0
  local plugin

  # printf "$terminal_format" "PLUGIN" "VERSION" "SET BY CONFIG" # disable this until we release headings across the board
  if [ $# -eq 0 ]; then
    # shellcheck disable=SC2119
    for plugin in $(plugin_list_command); do
      plugin_current_command "$plugin" "$terminal_format"
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
    printf "Heads up! It looks like your %s plugin is out of date. You can update it with:\n\n" "$plugin_name"
    printf "  asdf plugin-update %s\n\n" "$plugin_name"
  fi
}

current_command "$@"

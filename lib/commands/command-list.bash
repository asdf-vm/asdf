# -*- sh -*-
# shellcheck source=lib/functions/system-version.bash
. "$(dirname "$(dirname "$0")")/lib/functions/system-version.bash"

list_command() {
  local plugin_name=$1
  local query=$2

  if [ -z "$plugin_name" ]; then
    local plugins_path
    plugins_path=$(get_plugin_path)

    if find "$plugins_path" -mindepth 1 -type d &>/dev/null; then
      for plugin_path in "$plugins_path"/*/; do
        plugin_name=$(basename "$plugin_path")
        printf "%s\n" "$plugin_name"
        display_installed_versions "$plugin_name" "$query"
      done
    else
      printf "%s\n" 'No plugins installed'
    fi
  else
    check_if_plugin_exists "$plugin_name"
    display_installed_versions "$plugin_name" "$query"
  fi
}

display_installed_versions() {
  local plugin_name=$1
  local query=$2
  local versions
  local current_version
  local flag

  versions=$(list_installed_versions "$plugin_name")

  if [[ $query ]]; then
    versions=$(printf "%s\n" "$versions" | grep -E "^\s*$query")

    if [ -z "${versions}" ]; then
      display_error "No compatible versions installed ($plugin_name $query)"
      exit 1
    fi
  fi

  # Add each system version checker and default system version if it exists.
  system_version=$(system_version_command "$plugin_name")
  if [[ $system_version ]]; then
    # If show system version detilas then use $system_version.
    versions="$(printf "%s\n" "system") $versions"
  elif [[ $(default_system_version_command "$plugin_name") ]]; then
    versions="$(printf "%s\n" "system") $versions"
  fi

  if [ -n "${versions}" ]; then
    current_version=$(cut -d '|' -f 1 <<<"$(find_versions "$plugin_name" "$PWD")")

    for version in $versions; do
      flag="  "
      if [[ "$version" == "$current_version" ]]; then
        flag=" *"
      fi
      printf "%s%s\n" "$flag" "$version"
    done
  else
    display_error '  No versions installed'
  fi
}

list_command "$@"

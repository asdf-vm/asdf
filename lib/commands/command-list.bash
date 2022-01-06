# -*- sh -*-

list_command() {
  local plugin_name=$1
  local query=$2

  if [ -z "$plugin_name" ]; then
    local plugins_path
    plugins_path=$(get_plugin_path)

    if find "$plugins_path" -mindepth 1 -type d &>/dev/null; then
      for plugin_path in "$plugins_path"/*; do
        plugin_name=$(basename "$plugin_path")
        printf "%s\\n" "$plugin_name"
        display_installed_versions "$plugin_name" "$query"
      done
    else
      printf "%s\\n" 'No plugins installed'
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
  versions=$(list_installed_versions "$plugin_name")

  if [[ $query ]]; then
    versions=$(printf "%s\n" "$versions" | grep -E "^\s*$query")

    if [ -z "${versions}" ]; then
      display_error "No compatible versions installed ($plugin_name $query)"
      exit 1
    fi
  fi

  if [ -n "${versions}" ]; then
    for version in $versions; do
      printf "  %s\\n" "$version"
    done
  else
    display_error '  No versions installed'
  fi
}

list_command "$@"

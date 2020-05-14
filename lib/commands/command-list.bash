# -*- sh -*-

list_command() {
  local plugin_name=$1
  local query=$2

  if [ -z "$plugin_name" ]; then
    local plugins_path
    plugins_path=$(get_plugin_path)

    if ls "$plugins_path" &>/dev/null; then
      for plugin_path in "$plugins_path"/*; do
        plugin_name=$(basename "$plugin_path")
        echo "$plugin_name"
        display_installed_versions "$plugin_name" "$query"
      done
    else
      printf "%s\\n" 'Oohes nooes ~! No plugins installed'
    fi
  else
    check_if_plugin_exists "$plugin_name"
    display_installed_versions "$plugin_name" "$query"
  fi
}

display_installed_versions() {
  local versions
  local query=$2
  versions=$(list_installed_versions "$1")

  if [ -z "${versions}" ]; then
    display_error 'No versions installed'
    exit 1
  fi

  if [[ $query ]]; then
    versions=$(echo "$versions" | grep -E "^\s*$query")
  fi

  if [ -n "${versions}" ]; then
    for version in $versions; do
      echo "  $version"
    done
  else
    display_error 'No compatible versions installed'
    exit 1
  fi
}

list_command "$@"

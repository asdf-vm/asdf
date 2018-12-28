list_command() {
  local plugin_name=$1

  if [ -z "$plugin_name" ]; then
    local plugins_path
    plugins_path=$(get_plugin_path)

    if ls "$plugins_path" &> /dev/null; then
      for plugin_path in "$plugins_path"/* ; do
        plugin_name=$(basename "$plugin_path")
        echo "$plugin_name"
        display_installed_versions "$plugin_name"
      done
    else
      printf "%s\\n" 'Oohes nooes ~! No plugins installed'
    fi
  else
    check_if_plugin_exists "$plugin_name"
    display_installed_versions "$plugin_name"
  fi
}

display_installed_versions() {
  local versions
  versions=$(list_installed_versions "$1")

  if [ -n "${versions}" ]; then
    for version in $versions; do
      echo "  $version"
    done
  else
    display_error 'No versions installed'
  fi
}

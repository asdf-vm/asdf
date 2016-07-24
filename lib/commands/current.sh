current_command() {
  local plugin_name=$1
  local version=$(get_preset_version_for $plugin_name)

  check_if_plugin_exists $plugin_name

  if [ "$version" == "" ]; then
    echo "No version set for $plugin_name"
    exit 1
  else
    local version_file_path=$(get_version_file_path_for $plugin_name)
    if [ "$version_file_path" == "" ]; then
      echo "$version"
    else
      echo "$version (set by $version_file_path)"
    fi

    exit 0
  fi
}

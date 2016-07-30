current_command() {
  local plugin_name=$1

  check_if_plugin_exists $plugin_name
  local version_file_path=$(find_version_file_for $plugin_name)
  local version=$(parse_version_file $version_file_path $plugin_name)
  check_if_version_exists $plugin_name $version

  if [ -z "$version" ]; then
    echo "No version set for $plugin_name"
    exit 1
  else
    echo "$version (set by $version_file_path)"
  fi
}

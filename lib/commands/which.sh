current_version() {
  local plugin_name=$1

  check_if_plugin_exists $plugin_name

  local search_path=$(pwd)
  local version_and_path=$(find_version "$plugin_name" "$search_path")
  local version=$(cut -d '|' -f 1 <<< "$version_and_path");
  local version_file_path=$(cut -d '|' -f 2  <<< "$version_and_path");

  check_if_version_exists $plugin_name $version
  check_for_deprecated_plugin $plugin_name

  if [ -z "$version" ]; then
    echo "No version set for $plugin_name"
    exit 1
  else
    echo "$version"
  fi
}

which_command() {
  local plugin_name=$1
  local plugin_path=$(get_plugin_path $plugin_name)
  check_if_plugin_exists $plugin_name
  local install_type="version"

  local install_path=$(get_install_path $plugin_name $install_type $(current_version $plugin_name))

  if [ -d $install_path ]; then
    echo $install_path
    exit 0
  else
    echo "Version not installed"
    exit 1
  fi
}

which_command() {
  local plugin_name=$1
  local plugin_path=$(get_plugin_path $plugin_name)
  check_if_plugin_exists $plugin_name

  full_version=$(get_preset_version_for $plugin_name)

  if [ "$full_version" == "" ]; then
      echo "No version set for ${plugin_name}"
      exit -1
  else
      echo "$full_version"
      exit 0
  fi
}

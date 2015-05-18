plugin_remove_command() {
  local package_name=$1
  local plugin_path=$(get_plugin_path $package_name)

  rm -rf $plugin_path
  rm -rf $(asdf_dir)/installs/${package_name}
}

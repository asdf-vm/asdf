plugin_remove_command() {
  local plugin_name=$1
  local plugin_path=$(get_plugin_path $plugin_name)

  rm -rf $plugin_path
  rm -rf $(asdf_dir)/installs/${plugin_name}
}

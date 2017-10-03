plugin_list_all_command() {
  initialize_or_update_repository

  local plugins_path
  plugins_path="$(asdf_dir)/repository/plugins"
  for plugin in $plugins_path/*; do
    basename "$plugin"
  done
}

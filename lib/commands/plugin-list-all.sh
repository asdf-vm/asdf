plugin_list_all_command() {
  initialize_or_update_repository

  local plugins_path
  plugins_path="$(asdf_dir)/repository/plugins"

if ls "$plugins_path" &> /dev/null; then
  for plugin in $plugins_path/*; do
    plugin_name=$(basename "$plugin")
    source_url=$(get_plugin_source_url "$plugin_name")
    printf "%-15s %s\\n" "$plugin_name" "$source_url"
  done
else
  printf "%s%s\\n" "error: index of plugins not found at " "$plugins_path"
fi
}

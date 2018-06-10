plugin_list_all_command() {
  initialize_or_update_repository

  local plugins_index_path
  plugins_index_path="$(asdf_data_dir)/repository/plugins"

  local plugins_local_path
  plugins_local_path="$(get_plugin_path)"

  if ls "$plugins_index_path" &> /dev/null; then
    for index_plugin in "$plugins_index_path"/*; do
      index_plugin_name=$(basename "$index_plugin")
      source_url=$(get_plugin_source_url "$index_plugin_name")
      installed_flag=""

      for local_plugin in "$plugins_local_path"/*; do
      local_plugin_name=$(basename "$local_plugin")
        [[ "$index_plugin_name" == "$local_plugin_name" ]] && installed_flag="*"
      done

      printf "%-15s %-1s%s\\n" "$index_plugin_name" "$installed_flag" "$source_url"
    done
  else
    printf "%s%s\\n" "error: index of plugins not found at " "$plugins_index_path"
  fi
}

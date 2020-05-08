# -*- sh -*-

plugin_list_all_command() {
  initialize_or_update_repository

  local plugins_index_path
  plugins_index_path="$(asdf_data_dir)/repository/plugins"

  local plugins_local_path
  plugins_local_path="$(get_plugin_path)"

  if ls "$plugins_index_path" &>/dev/null; then
      list=""
      width=0
      for index_plugin in "$plugins_index_path"/*; do
        index_plugin_name=$(basename "$index_plugin")
        l=$(echo -n "$index_plugin_name" | wc -m)
        width=$((l > width ? l : width))
        list="$list $index_plugin_name"
      done

      for index_plugin_name in $list; do
        source_url=$(get_plugin_source_url "$index_plugin_name")
        installed_flag=" "

        [[ -d "${plugins_local_path}/${index_plugin_name}" ]] && installed_flag='*'

        printf "%-${width}s  %s\\n" "$index_plugin_name" "$installed_flag$source_url"
      done
  else
    printf "%s%s\\n" "error: index of plugins not found at " "$plugins_index_path"
  fi
}

plugin_list_all_command "$@"

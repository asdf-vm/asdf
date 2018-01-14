plugin_list_command() {
  local plugins_path
  plugins_path=$(get_plugin_path)

  if ls "$plugins_path" &> /dev/null; then
    for plugin_path in $plugins_path/* ; do
      plugin_name=$(basename "$plugin_path")
      source_url=$(get_plugin_source_url "$plugin_name")
      printf "%-15s %s\\n" "$plugin_name" "$source_url"
    done
  else
    printf "%s\\n" "Oohes nooes ~! No plugins installed"
  fi
}

plugin_list_command() {
  local plugins_path
  plugins_path=$(get_plugin_path)

  if ls "$plugins_path" &> /dev/null; then
    for plugin_path in $plugins_path/* ; do
      basename "$plugin_path"
    done
  else
    echo 'Oohes nooes ~! No plugins installed'
  fi
}

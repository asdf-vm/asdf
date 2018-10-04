plugin_list_command() {
  local flag=$1

  # 0 || 1 with flag
  if [ $# -eq 0 ] || { [ $# -eq 1 ] && [ "$flag" = "--urls" ]; }; then
    # valid command

    local plugins_path
    plugins_path=$(get_plugin_path)

    if ls "$plugins_path" &> /dev/null; then
      for plugin_path in "$plugins_path"/* ; do
        plugin_name=$(basename "$plugin_path")

        if [ $# -eq 0 ]; then
          printf "%s\\n" "$plugin_name"
        else
          source_url=$(get_plugin_source_url "$plugin_name")
          printf "%-15s %s\\n" "$plugin_name" "$source_url"
        fi

      done
    else
      display_error 'Oohes nooes ~! No plugins installed'
      exit 1
    fi

  else
    display_error "usage: asdf plugin-list [--urls]"
    exit 1
  fi

}

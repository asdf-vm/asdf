plugin_update_command() {
  if [ "$#" -ne 1 ]; then
    display_error "usage: asdf plugin-update {<name> | --all}"
    exit 1
  fi

  local plugin_name=$1
  if [ "$plugin_name" = "--all" ]; then
    for dir in "$(asdf_dir)"/plugins/*; do
      echo "Updating $(basename "$dir")..."
      (cd "$dir" && git pull)
    done
  else
    local plugin_path
    plugin_path=$(get_plugin_path "$plugin_name")
    check_if_plugin_exists "$plugin_name"
    echo "Updating $plugin_name..."
    (cd "$plugin_path" && git pull)
  fi
}

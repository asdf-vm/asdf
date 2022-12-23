# -*- sh -*-

plugin_push_command() {
  local plugin_name=$1
  if [ "$plugin_name" = "--all" ]; then
    for dir in "$(asdf_data_dir)"/plugins/*/; do
      printf "Pushing %s...\n" "$(basename "$dir")"
      (cd "$dir" && git push)
    done
  else
    local plugin_path
    plugin_path=$(get_plugin_path "$plugin_name")
    check_if_plugin_exists "$plugin_name"
    printf "Pushing %s...\n" "$plugin_name"
    (cd "$plugin_path" && git push)
  fi
}

plugin_push_command "$@"

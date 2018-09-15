plugin_remove_command() {
  local plugin_name=$1
  check_if_plugin_exists "$plugin_name"

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  rm -rf "$plugin_path"
  rm -rf "$ASDF_DATA_DIR/installs/${plugin_name}"

  grep -l "asdf-plugin: ${plugin_name}" "$ASDF_DATA_DIR"/shims/* 2>/dev/null | xargs rm -f
}

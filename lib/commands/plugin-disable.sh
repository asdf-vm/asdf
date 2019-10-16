plugin_disable_command() {
  local plugin_name=$1
  check_if_plugin_exists "$plugin_name"

  local disabled_file
  disabled_file=$(get_plugin_disabled_file "$plugin_name")
  touch "$disabled_file"

  grep -l "asdf-plugin: ${plugin_name}" "$(asdf_data_dir)"/shims/* 2>/dev/null | xargs rm -f
}

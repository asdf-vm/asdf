plugin_enable_command() {
  local plugin_name=$1
  check_if_plugin_exists "$plugin_name"

  local disabled_file
  disabled_file=$(get_plugin_disabled_file "$plugin_name")
  rm -f "$disabled_file"

  reshim_command "$plugin_name"
}

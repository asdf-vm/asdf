system_version_command() {
  local plugin_name=$1

  local plugins_path
  plugin_path=$(get_plugin_path "$plugin_name")

  if [ -f "${plugin_path}/bin/system-version" ]; then
    printf "%s\n" "$("${plugin_path}/bin/system-version")"
  fi
}

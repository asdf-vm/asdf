system_version_command() {
  local plugin_name=$1

  plugin_path=$(get_plugin_path "$plugin_name")
  if [ -f "${plugin_path}/bin/system-version" ]; then
    printf "%s\n" "$("${plugin_path}/bin/system-version")"
  fi
}

default_system_version_command() {
  local plugin_name=$1

  version_and_path=$(find_versions "$plugin_name" "$PWD")
  if [[ "$version_and_path" == *"system"* ]]; then
    printf "%s\n" "system"
  fi
}

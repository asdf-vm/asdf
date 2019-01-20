shim_env_command() {
  local shim_name="$1"
  local env_cmd="${2}"

  if [ -z "$env_cmd" ]; then
    env_cmd="env"
  fi

  local selected_version
  selected_version=$(select_from_tool_versions)

  if [ -z "$selected_version" ]; then
    selected_version=$(select_from_preset_version)
  fi

  if [ -n "$selected_version" ]; then
    local plugin_name
    plugin_name=$(cut -d ' ' -f 1 <<< "$selected_version");
    local version
    version=$(cut -d ' ' -f 2- <<< "$selected_version");
    plugin_exec_env "$plugin_name" "$version"
    exec "$env_cmd" "${@:3}"
  fi

  (
    echo "asdf: No version set for command ${shim_name}"
    echo "you might want to add one of the following in your .tool-versions file:"
    echo ""
    shim_plugin_versions "${shim_name}"
  ) >&2
  exit 126
}

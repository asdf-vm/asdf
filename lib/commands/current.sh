plugin_current_command() {
  local plugin_name=$1

  check_if_plugin_exists "$plugin_name"

  local search_path
  search_path=$(pwd)
  local version_and_path
  version_and_path=$(find_version "$plugin_name" "$search_path")
  local full_version
  full_version=$(cut -d '|' -f 1 <<< "$version_and_path");
  local version_file_path
  version_file_path=$(cut -d '|' -f 2  <<< "$version_and_path");


  # shellcheck disable=SC2162
  IFS=' ' read -a versions <<< "$full_version"

  if [ ${#versions} -eq 0 ]; then
    printf "%s\\n" "$(display_no_version_set "$plugin_name")"
    exit 126
  fi

  for version in "${versions[@]}"; do
    check_if_version_exists "$plugin_name" "$version"
    check_for_deprecated_plugin "$plugin_name"
  done
  printf "%-7s%s\\n" "$full_version" " (set by $version_file_path)"
}

current_command() {
  if [ $# -eq 0 ]; then
    for plugin in $(plugin_list_command); do
      printf "%-15s%s\\n" "$plugin" "$(plugin_current_command "$plugin")" >&2
    done
  else
    local plugin=$1
    plugin_current_command "$plugin"
  fi
}

# Warn if the plugin isn't using the updated legacy file api.
check_for_deprecated_plugin() {
  local plugin_name=$1

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  local legacy_config
  legacy_config=$(get_asdf_config_value "legacy_version_file")
  local deprecated_script="${plugin_path}/bin/get-version-from-legacy-file"
  local new_script="${plugin_path}/bin/list-legacy-filenames"

  if [ "$legacy_config" = "yes" ] && [ -f "$deprecated_script" ] && [ ! -f "$new_script" ]; then
    echo "Heads up! It looks like your $plugin_name plugin is out of date. You can update it with:"
    echo ""
    echo "  asdf plugin-update $plugin_name"
    echo ""
  fi
}

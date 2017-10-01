plugin_current_command() {
  local plugin_name=$1

  check_if_plugin_exists "$plugin_name"

  local search_path
  search_path=$(pwd)
  local version_and_path
  version_and_path=$(find_version "$plugin_name" "$search_path")
  local version
  version=$(cut -d '|' -f 1 <<< "$version_and_path");
  local version_file_path
  version_file_path=$(cut -d '|' -f 2  <<< "$version_and_path");

  check_if_version_exists "$plugin_name" "$version"
  check_for_deprecated_plugin "$plugin_name"

  if [ -z "$version" ]; then
    echo "No version set for $plugin_name"
    exit 1
  else
    echo "$version (set by $version_file_path)"
  fi
}

current_command() {
  if [ $# -eq 0 ]; then
    for plugin in $(plugin_list_command); do
      echo "$plugin $(plugin_current_command "$plugin")"
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

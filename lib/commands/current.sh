current_command() {
  local plugin_name=$1

  check_if_plugin_exists $plugin_name
  local version_file_path=$(find_version_file_for $plugin_name)
  local version=$(parse_version_file $version_file_path $plugin_name)
  check_if_version_exists $plugin_name $version

  check_for_deprecated_plugin $plugin_name

  if [ -z "$version" ]; then
    echo "No version set for $plugin_name"
    exit 1
  else
    echo "$version (set by $version_file_path)"
  fi
}

# Warn if the plugin isn't using the updated legacy file api.
check_for_deprecated_plugin() {
  local plugin_name=$1

  local plugin_path=$(get_plugin_path "$plugin_name")
  local legacy_config=$(get_asdf_config_value "legacy_version_file")
  local deprecated_script="${plugin_path}/bin/get-version-from-legacy-file"
  local new_script="${plugin_path}/bin/list-legacy-filenames"

  if [ "$legacy_config" = "yes" ] && [ -f $deprecated_script ] && [ ! -f $new_script ]; then
    echo "Heads up! It looks like your $plugin_name plugin is out of date. You can update it with:"
    echo ""
    echo "  asdf plugin-update $plugin_name"
    echo ""
  fi
}

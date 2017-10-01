list_command() {
  local plugin_name=$1
  check_if_plugin_exists "$plugin_name"

  local versions
  versions=$(list_installed_versions "$plugin_name")

  if [ -n "${versions}" ]; then
    for version in $versions; do
      echo "$version"
    done
  else
    display_error 'No versions installed'
    exit 1
  fi
}

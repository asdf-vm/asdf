each_command() {
  local plugin_name=$1
  shift

  if [ -z "$plugin_name" ]; then
    display_error "You must specify a name"
    exit 1
  else
    check_if_plugin_exists "$plugin_name"
    execute_command_for_each_installed_version "$plugin_name" "$@"
  fi
}

execute_command_for_each_installed_version() {
  local plgugin_name=$1
  shift

  local versions=$(list_installed_versions "$plugin_name")

  if [ -n "${versions}" ]; then
    local version_envvar_name=$(version_envvar_name "$plugin_name")

    for version in $versions; do
      echo "## $plugin_name $version ##"
      env $version_envvar_name="$version" "$@"
    done
  else
    display_error 'No versions installed'
  fi
}

version_envvar_name() {
  local plugin_name=$1
  local upcase_name=$(echo "${plugin_name}" | tr '[:lower:]-' '[:upper:]_')
  echo "ASDF_${upcase_name}_VERSION"
}

each_command "$@"

install_command() {
  local package_name=$1
  local full_version=$2
  local plugin_path=$(get_plugin_path $package_name)
  check_if_plugin_exists $plugin_path

  IFS=':' read -a version_info <<< "$full_version"
  if [ "${version_info[0]}" = "tag" ] || [ "${version_info[0]}" = "commit" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  local install_path=$(get_install_path $package_name $install_type $version)
  ${plugin_path}/bin/install $install_type $version $install_path
  reshim_command $package_name $full_version
}

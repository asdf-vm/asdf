install_command() {
  local package_name=$1
  local full_version=$2
  local source_path=$(get_source_path $package_name)
  check_if_source_exists $source_path

  IFS=':' read -a version_info <<< "$full_version"
  if [ "${version_info[0]}" = "tag" ] || [ "${version_info[0]}" = "commit" ]
  then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  local install_path=$(get_install_path $package_name $install_type $version)
  ${source_path}/bin/install $install_type $version $install_path
  $(asdf_dir)/bin/asdf reshim $package_name $full_version
}

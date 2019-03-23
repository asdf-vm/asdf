where_command() {
  local plugin_name=$1
  local full_version=$2
  check_if_plugin_exists "$plugin_name"

  local version
  local install_type="version"
  if [[ -z ${full_version} ]]; then
    local version_and_path
    version_and_path=$(find_version "$plugin_name" "$PWD")
    version=$(cut -d '|' -f 1 <<< "$version_and_path");
  else
    local -a version_info
    IFS=':' read -r -a version_info <<< "$full_version"
    if [ "${version_info[0]}" = "ref" ]; then
      install_type="${version_info[0]}"
      version="${version_info[1]}"
    else
      version="${version_info[0]}"
    fi
  fi

  if [ -z "$version" ]; then
    display_no_version_set "$plugin_name"
    exit 1
  fi

  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

  if [ -d "$install_path" ]; then
    echo "$install_path"
    exit 0
  else
    if [ "$version" = "system" ]; then
      echo "System version is selected"
      exit 1
    else
      echo "Version not installed"
      exit 1
    fi
  fi
}

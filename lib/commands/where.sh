where_command() {
  local plugin_name=$1
  local full_version=$2
  check_if_plugin_exists "$plugin_name"

  IFS=':' read -r -a version_info <<< "$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

  if [ -d "$install_path" ]; then
    echo "$install_path"
    exit 0
  else
    echo "Version not installed"
    exit 1
  fi
}

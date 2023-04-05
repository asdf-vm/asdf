# -*- sh -*-

where_command() {
  local plugin_name=$1
  local full_version=$2
  check_if_plugin_exists "$plugin_name"

  local version
  local install_type="version"
  if [[ -z ${full_version} ]]; then
    local version_and_path
    local versions
    version_and_path=$(find_versions "$plugin_name" "$PWD")
    versions=$(cut -d '|' -f 1 <<<"$version_and_path")
    IFS=' ' read -r -a plugin_versions <<<"$versions"
    version="${plugin_versions[0]}"
  else
    local -a version_info
    IFS=':' read -r -a version_info <<<"$full_version"
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
    printf "%s\n" "$install_path"
    exit 0
  else
    if [ "$version" = "system" ]; then
      printf "System version is selected\n"
      exit 1
    else
      printf "Version not installed\n"
      exit 1
    fi
  fi
}

where_command "$@"

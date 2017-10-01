shim_command() {
  local plugin_name=$1
  local executable_path=$2
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"
  ensure_shims_dir

  generate_shim_for_executable "$plugin_name" "$executable_path"
}

reshim_command() {
  local plugin_name=$1
  local full_version=$2
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"
  ensure_shims_dir

  if [ "$full_version" != "" ]; then
    # generate for the whole package version
    generate_shims_for_version "$plugin_name" "$full_version"
  else
    # generate for all versions of the package
    local plugin_installs_path
    plugin_installs_path="$(asdf_dir)/installs/${plugin_name}"

    for install in "${plugin_installs_path}"/*/; do
      local full_version_name
      full_version_name=$(basename "$install" | sed 's/ref\-/ref\:/')
      generate_shims_for_version "$plugin_name" "$full_version_name"
      remove_obsolete_shims "$plugin_name" "$full_version_name"
    done
  fi
}


ensure_shims_dir() {
  # Create shims dir if doesn't exist
  if [ ! -d "$(asdf_dir)/shims" ]; then
    mkdir "$(asdf_dir)/shims"
  fi
}


write_shim_script() {
  local plugin_name=$1
  local version=$2
  local executable_path=$3
  local executable_name
  executable_name=$(basename "$executable_path")
  local plugin_shims_path
  plugin_shims_path=$(get_plugin_path "$plugin_name")/shims
  local shim_path
  shim_path="$(asdf_dir)/shims/$executable_name"

  if [ -f "$plugin_shims_path/$executable_name" ]; then
    cp "$plugin_shims_path/$executable_name" "$shim_path"
  elif [ -f "$shim_path" ]; then
    if ! grep "# asdf-plugin-version: $version" "$shim_path" > /dev/null; then
     sed -i'' -e "s/\(asdf-plugin: $plugin_name\)/\1\\"$'\n'"# asdf-plugin-version: $version/" "$shim_path"
    fi
  else
    cat <<EOF > "$shim_path"
#!/usr/bin/env bash
# asdf-plugin: ${plugin_name}
# asdf-plugin-version: ${version}
exec $(asdf_dir)/bin/private/asdf-exec ${plugin_name} ${executable_path} "\$@"
EOF
  fi

  chmod +x "$shim_path"
}


generate_shim_for_executable() {
  local plugin_name=$1
  local executable=$2
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  check_if_plugin_exists "$plugin_name"

  IFS=':' read -r -a version_info <<< "$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  write_shim_script "$plugin_name" "$version" "$executable"
}

list_plugin_bin_paths() {
  local plugin_name=$1
  local version=$2
  local install_type=$3
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

  if [ -f "${plugin_path}/bin/list-bin-paths" ]; then
    local space_separated_list_of_bin_paths
    space_separated_list_of_bin_paths=$(
      export ASDF_INSTALL_TYPE=$install_type
      export ASDF_INSTALL_VERSION=$version
      export ASDF_INSTALL_PATH=$install_path
      bash "${plugin_path}/bin/list-bin-paths"
    )
  else
    local space_separated_list_of_bin_paths="bin"
  fi
  echo "$space_separated_list_of_bin_paths"
}


generate_shims_for_version() {
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
  space_separated_list_of_bin_paths="$(list_plugin_bin_paths "$plugin_name" "$version" "$install_type")"
  IFS=' ' read -r -a all_bin_paths <<< "$space_separated_list_of_bin_paths"

  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

  for bin_path in "${all_bin_paths[@]}"; do
    for executable_file in $install_path/$bin_path/*; do
      # because just $executable_file gives absolute path; We don't want version hardcoded in shim
      local executable_path_relative_to_install_path
      executable_path_relative_to_install_path="$bin_path"/$(basename "$executable_file")
      if [ -x "$executable_file" ]; then
        write_shim_script "$plugin_name" "$version" "$executable_path_relative_to_install_path"
      fi
    done
  done
}

shim_still_exists() {
  local shim_name=$1
  local install_path=$2
  local space_separated_list_of_bin_paths=$3
  IFS=' ' read -r -a all_bin_paths <<< "$space_separated_list_of_bin_paths"


  for bin_path in "${all_bin_paths[@]}"; do
    if [ -x "$install_path/$bin_path/$shim_name" ]; then
      return 0
    fi
  done
  return 1
}

remove_obsolete_shims() {
  local plugin_name=$1
  local full_version=$2
  local shims_path
  shims_path="$(asdf_dir)/shims"

  IFS=':' read -r -a version_info <<< "$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  space_separated_list_of_bin_paths="$(list_plugin_bin_paths "$plugin_name" "$version" "$install_type")"

  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

  for shim_path in "$shims_path"/*; do
    local shim_name
    shim_name="$(basename "$shim_path")"
    if grep "# asdf-plugin: $plugin_name" "$shim_path" > /dev/null && \
        grep "# asdf-plugin-version: $version" "$shim_path" > /dev/null && \
        ! shim_still_exists "$shim_name" "$install_path" "$space_separated_list_of_bin_paths"; then
      remove_shim_for_version "$plugin_name" "$shim_name" "$version"
    fi
  done
}

remove_shim_for_version() {
  local plugin_name=$1
  local executable_name=$2
  local version=$3
  local plugin_shims_path
  plugin_shims_path=$(get_plugin_path "$plugin_name")/shims
  local shim_path
  shim_path="$(asdf_dir)/shims/$executable_name"
  local count_installed
  count_installed=$(list_installed_versions "$plugin_name" | wc -l)

  if ! grep "# asdf-plugin: $plugin_name" "$shim_path" > /dev/null 2>&1; then
    return 0
  fi

  sed -i'' -e "/# asdf-plugin-version: $version/d" "$shim_path"

  if [ ! -f "$plugin_shims_path/$executable_name" ] && \
        ! grep "# asdf-plugin-version" "$shim_path" > /dev/null || \
      [ "$count_installed" -eq 0 ]; then
    rm "$shim_path"
  fi
}

remove_shims_for_version() {
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
  space_separated_list_of_bin_paths="$(list_plugin_bin_paths "$plugin_name" "$version" "$install_type")"
  IFS=' ' read -r -a all_bin_paths <<< "$space_separated_list_of_bin_paths"

  for bin_path in "${all_bin_paths[@]}"; do
    for executable_file in $install_path/$bin_path/*; do
      local executable_name
      executable_name="$(basename "$executable_file")"
      remove_shim_for_version "$plugin_name" "$executable_name" "$version"
    done
  done
}

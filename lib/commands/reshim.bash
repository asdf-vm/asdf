remove_shim_for_version() {
  local plugin_name=$1
  local version=$2
  local shim_name

  shim_name=$(basename "$3")

  local shim_path
  shim_path="$(asdf_data_dir)/shims/$shim_name"

  local count_installed
  count_installed=$(list_installed_versions "$plugin_name" | wc -l)

  if ! grep -x "# asdf-plugin: $plugin_name $version" "$shim_path" &>/dev/null; then
    return 0
  fi

  sed -i.bak -e "/# asdf-plugin: $plugin_name $version"'$/d' "$shim_path"
  rm "$shim_path".bak

  if ! grep -q "# asdf-plugin:" "$shim_path" ||
    [ "$count_installed" -eq 0 ]; then
    rm -f "$shim_path"
  fi
}

reshim_command() {
  local plugin_name=$1
  local full_version=$2

  if [ -z "$plugin_name" ]; then
    local plugins_path
    plugins_path=$(get_plugin_path)

    if find "$plugins_path" -mindepth 1 -type d &>/dev/null; then
      for plugin_path in "$plugins_path"/*/; do
        plugin_name=$(basename "$plugin_path")
        reshim_command "$plugin_name"
      done
    fi
    return 0
  fi

  check_if_plugin_exists "$plugin_name"
  ensure_shims_dir

  if [ "$full_version" != "" ]; then
    # generate for the whole package version
    asdf_run_hook "pre_asdf_reshim_$plugin_name" "$full_version"
    generate_shims_for_version "$plugin_name" "$full_version"
    asdf_run_hook "post_asdf_reshim_$plugin_name" "$full_version"
  else
    # generate for all versions of the package
    local plugin_installs_path
    plugin_installs_path="$(asdf_data_dir)/installs/${plugin_name}"

    for install in "${plugin_installs_path}"/*/; do
      local full_version_name
      full_version_name=$(basename "$install" | sed 's/ref\-/ref\:/')
      asdf_run_hook "pre_asdf_reshim_$plugin_name" "$full_version_name"
      generate_shims_for_version "$plugin_name" "$full_version_name"
      remove_obsolete_shims "$plugin_name" "$full_version_name"
      asdf_run_hook "post_asdf_reshim_$plugin_name" "$full_version_name"
    done
  fi

}

ensure_shims_dir() {
  # Create shims dir if doesn't exist
  if [ ! -d "$(asdf_data_dir)/shims" ]; then
    mkdir "$(asdf_data_dir)/shims"
  fi
}

write_shim_script() {
  local plugin_name=$1
  local version=$2
  local executable_path=$3

  if ! is_executable "$executable_path"; then
    return 0
  fi

  local executable_name
  executable_name=$(basename "$executable_path")

  local shim_path
  shim_path="$(asdf_data_dir)/shims/$executable_name"

  local temp_dir
  temp_dir=${TMPDIR:-/tmp}

  local temp_versions_path
  temp_versions_path=$(mktemp "$temp_dir/asdf-command-reshim-write-shims.XXXXXX")
  cat <<EOF >"$temp_versions_path"
# asdf-plugin: ${plugin_name} ${version}
EOF

  if [ -f "$shim_path" ]; then
    grep '^#\sasdf-plugin:\s' <"$shim_path" >>"$temp_versions_path"
  fi

  cat <<EOF >"$shim_path"
#!/usr/bin/env bash
$(sort -u <"$temp_versions_path")
exec $(asdf_dir)/bin/asdf exec "${executable_name}" "\$@" # asdf_allow: ' asdf '
EOF

  rm "$temp_versions_path"

  chmod +x "$shim_path"
}

generate_shims_for_version() {
  local plugin_name=$1
  local full_version=$2
  local all_executable_paths
  IFS=$'\n' read -rd '' -a all_executable_paths <<<"$(plugin_executables "$plugin_name" "$full_version")"
  for executable_path in "${all_executable_paths[@]}"; do
    write_shim_script "$plugin_name" "$full_version" "$executable_path"
  done
}

remove_obsolete_shims() {
  local plugin_name=$1
  local full_version=$2

  local shims
  shims=$(plugin_shims "$plugin_name" "$full_version" | xargs -IX basename X | sort)

  local exec_names
  exec_names=$(plugin_executables "$plugin_name" "$full_version" | xargs -IX basename X | sort)

  local obsolete_shims
  local formatted_shims
  local formatted_exec_names

  local temp_dir
  temp_dir=${TMPDIR:-/tmp}

  # comm only takes to files, so we write this data to temp files so we can
  # pass it to comm.
  formatted_shims="$(mktemp "$temp_dir/asdf-command-reshim-formatted-shims.XXXXXX")"
  printf "%s\n" "$shims" >"$formatted_shims"

  formatted_exec_names="$(mktemp "$temp_dir/asdf-command-reshim-formatted-exec-names.XXXXXX")"
  printf "%s\n" "$exec_names" >"$formatted_exec_names"

  obsolete_shims=$(comm -23 "$formatted_shims" "$formatted_exec_names")
  rm -f "$formatted_exec_names" "$formatted_shims"

  for shim_name in $obsolete_shims; do
    remove_shim_for_version "$plugin_name" "$full_version" "$shim_name"
  done
}

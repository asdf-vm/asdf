# -*- sh -*-

# shellcheck source=lib/commands/reshim.bash
. "$(dirname "$ASDF_CMD_FILE")/reshim.bash"

reshim_command() {
  local plugin_name=$1
  local full_version=$2

  if [ -z "$plugin_name" ]; then
    local plugins_path
    plugins_path=$(get_plugin_path)

    if find "$plugins_path" -mindepth 1 -type d &>/dev/null; then
      for plugin_path in "$plugins_path"/*; do
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

  if [ -f "$shim_path" ]; then
    if ! grep -x "# asdf-plugin: ${plugin_name} ${version}" "$shim_path" >/dev/null; then
      sed -i.bak -e "s/exec /# asdf-plugin: ${plugin_name} ${version}\\"$'\n''exec /' "$shim_path"
      rm -f "$shim_path".bak
    fi
  else
    cat <<EOF >"$shim_path"
#!/usr/bin/env bash
# asdf-plugin: ${plugin_name} ${version}
exec $(asdf_dir)/bin/asdf exec "${executable_name}" "\$@"
EOF
  fi

  chmod +x "$shim_path"
}

generate_shim_for_executable() {
  local plugin_name=$1
  local executable=$2

  check_if_plugin_exists "$plugin_name"

  local version
  IFS=':' read -r -a version_info <<<"$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    version="${version_info[1]}"
  else
    version="${version_info[0]}"
  fi

  write_shim_script "$plugin_name" "$version" "$executable"
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

  # comm only takes to files, so we write this data to temp files so we can
  # pass it to comm.
  formatted_shims=$(mktemp /tmp/asdf-command-reshim-formatted-shims.XXXXXX)
  printf "%s\\n" "$shims" >"$formatted_shims"

  formatted_exec_names=$(mktemp /tmp/asdf-command-reshim-formatted-exec-names.XXXXXX)
  printf "%s\\n" "$exec_names" >"$formatted_exec_names"

  obsolete_shims=$(comm -23 "$formatted_shims" "$formatted_exec_names")
  rm -f "$formatted_exec_names" "$formatted_shims"

  for shim_name in $obsolete_shims; do
    remove_shim_for_version "$plugin_name" "$full_version" "$shim_name"
  done
}

reshim_command "$@"

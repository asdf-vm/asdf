# -*- sh -*-

# shellcheck source=lib/commands/reshim.bash
. "$(dirname "$ASDF_CMD_FILE")/reshim.bash"

uninstall_command() {
  local plugin_name=$1
  local full_version=$2
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  check_if_plugin_exists "$plugin_name"

  IFS=':' read -r -a version_info <<<"$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

  if [ ! -d "$install_path" ]; then
    display_error "No such version"
    exit 1
  fi

  asdf_run_hook "pre_asdf_uninstall_${plugin_name}" "$full_version"
  remove_shims_for_version "$plugin_name" "$full_version"

  if [ -f "${plugin_path}/bin/uninstall" ]; then
    (
      export ASDF_INSTALL_TYPE=$install_type
      export ASDF_INSTALL_VERSION=$version
      export ASDF_INSTALL_PATH=$install_path
      "${plugin_path}/bin/uninstall"
    )
  else
    rm -rf "$install_path"
  fi

  asdf_run_hook "post_asdf_uninstall_${plugin_name}" "$full_version"
}

remove_shims_for_version() {
  local plugin_name=$1
  local full_version=$2
  for shim_path in $(plugin_shims "$plugin_name" "$full_version"); do
    remove_shim_for_version "$plugin_name" "$full_version" "$shim_path"
  done
}

uninstall_command "$@"

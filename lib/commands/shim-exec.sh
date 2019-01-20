
tool_versions() {
  env | awk -F= '/^ASDF_[A-Z]+_VERSION/ {print $1" "$2}' | sed -e "s/^ASDF_//" | sed -e "s/_VERSION / /" | tr "[:upper:]_" "[:lower:]-"
  local asdf_versions_path
  asdf_versions_path="$(find_tool_versions)"
  [ -f "${asdf_versions_path}" ] && cat "${asdf_versions_path}"
}

shim_versions() {
  shim_plugin_versions "${shim_name}"
  shim_plugin_versions "${shim_name}" | cut -d' ' -f 1 | awk '{print$1" system"}'
}

select_from_tool_versions() {
  grep -f <(shim_versions) <(tool_versions) | head -n 1 | xargs echo
}

preset_versions() {
  shim_plugin_versions "${shim_name}" | cut -d' ' -f 1 | uniq | xargs -IPLUGIN bash -c "source $(asdf_dir)/lib/utils.sh; echo PLUGIN \$(get_preset_version_for PLUGIN)"
}

select_from_preset_version() {
  grep -f <(shim_versions) <(preset_versions) | head -n 1 | xargs echo
}

shim_exec_command() {
  local shim_name="$1"

  selected_version=$(select_from_tool_versions)

  if [ -z "$selected_version" ]; then
    selected_version=$(select_from_preset_version)
  fi


  if [ ! -z "$selected_version" ]; then
    plugin_name=$(cut -d ' ' -f 1 <<< "$selected_version");
    version=$(cut -d ' ' -f 2- <<< "$selected_version");
    plugin_path=$(get_plugin_path "$plugin_name")

    plugin_exec_env "$plugin_name" "$version"
    executable_path=$(command -v "$shim_name")

    if [ -x "${plugin_path}/bin/exec-path" ]; then
      install_path=$(find_install_path "$plugin_name" "$version")
      executable_path=$(get_custom_executable_path "${plugin_path}" "${install_path}" "${executable_path}")
    fi

    asdf_run_hook "pre_${plugin_name}_${shim_name}" "${@:2}"
    pre_status=$?
    if [ "$pre_status" -eq 0 ]; then
      "$executable_path" "${@:2}"
      exit_status=$?
    fi
    if [ "${exit_status:-${pre_status}}" -eq 0 ]; then
      asdf_run_hook "post_${plugin_name}_${shim_name}" "${@:2}"
      post_status=$?
    fi
    exit "${post_status:-${exit_status:-${pre_status}}}"
  fi

  (
    echo "asdf: No version set for command ${shim_name}"
    echo "you might want to add one of the following in your .tool-versions file:"
    echo ""
    shim_plugin_versions "${shim_name}"
  ) >&2
  exit 126
}

# -*- sh -*-

# shellcheck source=lib/functions/plugins.bash
. "$(dirname "$(dirname "$0")")/lib/functions/plugins.bash"
# shellcheck source=lib/functions/versions.bash
. "$(dirname "$(dirname "$0")")/lib/functions/versions.bash"
# shellcheck source=lib/commands/reshim.bash
. "$(dirname "$ASDF_CMD_FILE")/reshim.bash"
# shellcheck source=lib/functions/installs.bash
. "$(dirname "$(dirname "$0")")/lib/functions/installs.bash"

sync_command() {
  
  if [[ "$1" == "--local" || "$1" == "" ]]; then
        local tool_versions_file=./"${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME:-.tool-versions}"
  elif [ "$1" == "--global" ]; then
        local tool_versions_file="${HOME}"/"${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME:-.tool-versions}"
  else
    display_error "usage: asdf sync [--local | --global]"
  fi

  if [ -f "${tool_versions_file}" ]; then
      local plugin
      readonly plugin_list_tmpfile=$(mktemp)

      plugin_list_all_command | awk '{print $1}'> "${plugin_list_tmpfile}"

      while read plugin; do
        local plugin_name=$(echo "${plugin}" | awk '{print $1}' )
        local plugin_version=$(echo "${plugin}" | awk '{print $2}' )

        echo "Sync ${plugin_name} in version ${plugin_version}"
        if ! plugin_list_command | grep -E "^${plugin_name}$" > /dev/null 2>&1; then
          if grep -E "^${plugin_name}$" "${plugin_list_tmpfile}"; then
            plugin_add_command "${plugin_name}"
            install_command "${plugin_name}" "${plugin_version}"
          else
            display_error "plugin ${plugin_name} not found in repository"
          fi
        else
          install_command "${plugin_name}" "${plugin_version}"
        fi
        

      done < "${tool_versions_file}"
  else
      display_error "No ${tool_versions_file} here"
      exit 1
  fi
  
}

sync_command "$@"
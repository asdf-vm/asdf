# -*- sh -*-

list_all_command() {
  local plugin_name=$1
  local query=$2
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"

  local versions
  # Capture return code to allow error handling
  return_code=0 && versions=$(bash "${plugin_path}/bin/list-all" 2>&1) || return_code=$?

  if [[ $return_code -ne 0 ]]; then
    # Printing all output to allow plugin to handle error formatting
    printf "Plugin %s's list-all callback script failed with output:\\n" "${plugin_name}"
    printf "%s\\n" "${versions}"
    exit 1
  fi

  if [[ $query ]]; then
    versions=$(tr ' ' '\n' <<<"$versions" |
      grep -E "^\\s*$query" |
      tr '\n' ' ')
  fi

  IFS=' ' read -r -a versions_list <<<"$versions"

  for version in "${versions_list[@]}"; do
    printf "%s\\n" "${version}"
  done
}

list_all_command "$@"

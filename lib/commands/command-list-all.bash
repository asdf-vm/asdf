# -*- sh -*-

list_all_command() {
  local plugin_name=$1
  local query=$2
  local plugin_path
  local std_out
  local std_err
  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"

  # Capture return code to allow error handling
  return_code=0 && split_outputs std_out std_err "bash ${plugin_path}/bin/list-all" || return_code=$?

  if [[ $return_code -ne 0 ]]; then
    # Printing all output to allow plugin to handle error formatting
    printf "Plugin %s's list-all callback script failed with output:\\n" "${plugin_name}" >&2
    printf "%s\\n" "${std_err}" >&2
    printf "%s\\n" "${std_out}" >&2
    exit 1
  fi

  if [[ $query ]]; then
    std_out=$(tr ' ' '\n' <<<"$std_out" |
      grep -E "^\\s*$query" |
      tr '\n' ' ')
  fi

  IFS=' ' read -r -a versions_list <<<"$std_out"

  for version in "${versions_list[@]}"; do
    printf "%s\\n" "${version}"
  done
}

# This function splits stdout from std error, whilst preserving the return core
function split_outputs() {
  {
    IFS=$'\n' read -r -d '' "${1}"
    IFS=$'\n' read -r -d '' "${2}"
    (
      IFS=$'\n' read -r -d '' _ERRNO_
      return "${_ERRNO_}"
    )
  } < <((printf '\0%s\0%d\0' "$( ( ( ({
    ${3}
    printf "%s\n" ${?} 1>&3-
  } | tr -d '\0' 1>&4-) 4>&2- 2>&1- | tr -d '\0' 1>&4-) 3>&1- | exit "$(cat)") 4>&1-)" "${?}" 1>&2) 2>&1)
}

list_all_command "$@"

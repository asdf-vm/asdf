# -*- sh -*-

list_all_command() {
  local plugin_name=$1
  local query=$2
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"

  local versions
  versions=$(bash "${plugin_path}/bin/list-all")

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

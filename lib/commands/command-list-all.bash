# -*- sh -*-

list_all_command() {
  local plugin_name=$1
  local query=$2
  local plugin_path
  local std_out_file
  local std_err_file
  local output
  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"

  # Capture return code to allow error handling
  std_out_file="$(mktemp "/tmp/asdf-command-list-all-${plugin_name}.stdout.XXXXXX")"
  std_err_file="$(mktemp "/tmp/asdf-command-list-all-${plugin_name}.stderr.XXXXXX")"
  return_code=0 && "${plugin_path}/bin/list-all" >"$std_out_file" 2>"$std_err_file" || return_code=$?

  if [[ $return_code -ne 0 ]]; then
    # Printing all output to allow plugin to handle error formatting
    printf "Plugin %s's list-all callback script failed with output:\\n" "${plugin_name}" >&2
    printf "%s\\n" "$(cat "$std_err_file")" >&2
    printf "%s\\n" "$(cat "$std_out_file")" >&2
    rm "$std_out_file" "$std_err_file"
    exit 1
  fi

  if [[ $query ]]; then
    output=$(tr ' ' '\n' <"$std_out_file" |
      grep -E "^\\s*$query" |
      tr '\n' ' ')
  else
    output=$(cat "$std_out_file")
  fi

  if [ -z "$output" ]; then
    display_error "No compatible versions available ($plugin_name $query)"
    exit 1
  fi

  IFS=' ' read -r -a versions_list <<<"$output"

  for version in "${versions_list[@]}"; do
    printf "%s\\n" "${version}"
  done

  # Remove temp files if they still exist
  rm "$std_out_file" "$std_err_file" || true
}

list_all_command "$@"

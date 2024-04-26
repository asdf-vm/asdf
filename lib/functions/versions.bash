version_command() {
  local cmd=$1
  local plugin_name=$2

  if [ "$#" -lt "3" ]; then
    if [ "$cmd" = "global" ]; then
      printf "Usage: asdf global <name> <version>\n"
    else
      printf "Usage: asdf local <name> <version>\n"
    fi
    exit 1
  fi

  shift 2
  local versions=("$@")

  local file_name
  local file

  file_name="$(asdf_tool_versions_filename)"

  if [ "$cmd" = "global" ]; then
    file="$HOME/$file_name"
  elif [ "$cmd" = "local-tree" ]; then
    file=$(find_tool_versions)
  else # cmd = local
    file="$PWD/$file_name"
  fi

  if [ -L "$file" ]; then
    # Resolve file path if symlink
    file="$(resolve_symlink "$file")"
  fi

  check_if_plugin_exists "$plugin_name"

  declare -a resolved_versions
  local item
  for item in "${!versions[@]}"; do
    IFS=':' read -r -a version_info <<<"${versions[$item]}"
    if [ "${version_info[0]}" = "latest" ] && [ -n "${version_info[1]}" ]; then
      version=$(latest_command "$plugin_name" "${version_info[1]}")
    elif [ "${version_info[0]}" = "latest" ] && [ -z "${version_info[1]}" ]; then
      version=$(latest_command "$plugin_name")
    else
      # if branch handles ref: || path: || normal versions
      version="${versions[$item]}"
    fi

    # check_if_version_exists should probably handle if either param is empty string
    if [ -z "$version" ]; then
      exit 1
    fi

    if ! (check_if_version_exists "$plugin_name" "$version"); then
      version_not_installed_text "$plugin_name" "$version" 1>&2
      exit 1
    fi

    resolved_versions+=("$version")
  done

  if [ -f "$file" ] && grep -q "^$plugin_name " "$file"; then
    local temp_dir
    temp_dir=${TMPDIR:-/tmp}

    local temp_tool_versions_file
    temp_tool_versions_file=$(mktemp "$temp_dir/asdf-tool-versions-file.XXXXXX")

    cp -f "$file" "$temp_tool_versions_file"
    sed -e "s|^$plugin_name .*$|$plugin_name ${resolved_versions[*]}|" "$temp_tool_versions_file" >"$file"
    rm -f "$temp_tool_versions_file"
  else
    # Add a trailing newline at the end of the file if missing
    [[ -f "$file" && -n "$(tail -c1 "$file")" ]] && printf '\n' >>"$file"

    # Add a new version line to the end of the file
    printf "%s %s\n" "$plugin_name" "${resolved_versions[*]}" >>"$file"
  fi
}

list_all_command() {
  local plugin_name=$1
  local query=$2
  local plugin_path
  local std_out_file
  local std_err_file
  local output
  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"

  local temp_dir
  temp_dir=${TMPDIR:-/tmp}

  # Capture return code to allow error handling
  std_out_file="$(mktemp "$temp_dir/asdf-command-list-all-${plugin_name}.stdout.XXXXXX")"
  std_err_file="$(mktemp "$temp_dir/asdf-command-list-all-${plugin_name}.stderr.XXXXXX")"
  return_code=0 && "${plugin_path}/bin/list-all" >"$std_out_file" 2>"$std_err_file" || return_code=$?

  if [[ $return_code -ne 0 ]]; then
    # Printing all output to allow plugin to handle error formatting
    printf "Plugin %s's list-all callback script failed with output:\n" "${plugin_name}" >&2
    printf "%s\n" "$(cat "$std_err_file")" >&2
    printf "%s\n" "$(cat "$std_out_file")" >&2
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
    printf "%s\n" "${version}"
  done

  # Remove temp files if they still exist
  rm "$std_out_file" "$std_err_file" || true
}

latest_command() {
  DEFAULT_QUERY="[0-9]"

  local plugin_name=$1
  local query=$2
  local plugin_path

  if [ "$plugin_name" = "--all" ]; then
    latest_all
  fi

  [[ -z $query ]] && query="$DEFAULT_QUERY"

  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"

  local versions

  if [ -f "${plugin_path}/bin/latest-stable" ]; then
    versions=$("${plugin_path}"/bin/latest-stable "$query")
    if [ -z "${versions}" ]; then
      # this branch requires this print to mimic the error from the list-all branch
      printf "No compatible versions available (%s %s)\n" "$plugin_name" "$query" >&2
      exit 1
    fi
  else
    # pattern from xxenv-latest (https://github.com/momo-lab/xxenv-latest)
    versions=$(list_all_command "$plugin_name" "$query" |
      grep -ivE "(^Available versions:|-src|-dev|-latest|-stm|[-\\.]rc|-milestone|-alpha|-beta|[-\\.]pre|-next|(a|b|c)[0-9]+|snapshot|master)" |
      sed 's/^[[:space:]]\+//' |
      tail -1)
    if [ -z "${versions}" ]; then
      exit 1
    fi
  fi

  printf "%s\n" "$versions"
}

latest_all() {
  local plugins_path
  plugins_path=$(get_plugin_path)

  if find "$plugins_path" -mindepth 1 -type d &>/dev/null; then
    for plugin_path in "$plugins_path"/*/; do
      plugin_name=$(basename "$plugin_path")

      # Retrieve the version of the plugin
      local version
      if [ -f "${plugin_path}/bin/latest-stable" ]; then
        # We can't filter by a concrete query because different plugins might
        # have different queries.
        version=$("${plugin_path}"/bin/latest-stable "")
        if [ -z "${version}" ]; then
          version="unknown"
        fi
      else
        # pattern from xxenv-latest (https://github.com/momo-lab/xxenv-latest)
        version=$(list_all_command "$plugin_name" |
          grep -ivE "(^Available version:|-src|-dev|-latest|-stm|[-\\.]rc|-alpha|-beta|[-\\.]pre|-next|(a|b|c)[0-9]+|snapshot|master)" |
          sed 's/^[[:space:]]\+//' |
          tail -1)
        if [ -z "${version}" ]; then
          version="unknown"
        fi
      fi

      local installed_status
      installed_status="missing"

      local installed_versions
      installed_versions=$(list_installed_versions "$plugin_name")

      if [ -n "$installed_versions" ] && printf '%s\n' "$installed_versions" | grep -q "^$version\$"; then
        installed_status="installed"
      fi
      printf "%s\t%s\t%s\n" "$plugin_name" "$version" "$installed_status"
    done
  else
    printf "%s\n" 'No plugins installed'
  fi
  exit 0
}

local_command() {
  local parent=false
  local positional=()

  while [[ $# -gt 0 ]]; do
    case $1 in
    -p | --parent)
      parent="true"
      shift # past value
      ;;
    *)
      positional+=("$1") # save it in an array for later
      shift              # past argument
      ;;
    esac
  done

  set -- "${positional[@]}" # restore positional parameters

  if [ $parent = true ]; then
    version_command local-tree "$@"
  else
    version_command local "$@"
  fi
}

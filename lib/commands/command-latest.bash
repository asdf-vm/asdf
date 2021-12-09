# -*- sh -*-

latest_command() {
  DEFAULT_QUERY="[0-9]"

  local plugin_name=$1
  local query=$2
  local plugin_path

  if [ "$plugin_name" == "--all" ]; then
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
    versions=$(asdf list-all "$plugin_name" "$query" |
      grep -vE "(^Available versions:|-src|-dev|-latest|-stm|[-\\.]rc|-alpha|-beta|[-\\.]pre|-next|(a|b|c)[0-9]+|snapshot|master)" |
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

  if ls "$plugins_path" &>/dev/null; then
    for plugin_path in "$plugins_path"/*; do
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
        version=$(asdf list-all "$plugin_name" |
          grep -vE "(^Available version:|-src|-dev|-latest|-stm|[-\\.]rc|-alpha|-beta|[-\\.]pre|-next|(a|b|c)[0-9]+|snapshot|master)" |
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
      printf "%s\\t%s\\t%s\\n" "$plugin_name" "$version" "$installed_status"
    done
  else
    printf "%s\\n" 'No plugins installed'
  fi
  exit 0
}

latest_command "$@"

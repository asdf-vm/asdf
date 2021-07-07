# -*- sh -*-

latest_command() {
  DEFAULT_QUERY="[0-9]"

  local plugin_name=$1
  local query=$2
  local plugin_path

  [[ -z $query ]] && query="$DEFAULT_QUERY"

  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"

  local versions

  if [ -f "${plugin_path}/bin/latest-stable" ]; then
    versions=$(bash "${plugin_path}"/bin/latest-stable "$query")
    if [ -z "${versions}" ]; then
      # this branch requires this print to mimic the error from the list-all branch
      printf "No compatible versions available (%s %s)\n" "$plugin_name" "$query" >&2
      exit 1
    fi
  else
    # pattern from xxenv-latest (https://github.com/momo-lab/xxenv-latest)
    versions=$(asdf list-all "$plugin_name" "$query" |
      grep -vE "(^Available versions:|-src|-dev|-latest|-stm|[-\\.]rc|-alpha|-beta|[-\\.]pre|-next|(a|b|c)[0-9]+|snapshot|master)" |
      sed 's/^\s\+//' |
      tail -1)
    if [ -z "${versions}" ]; then
      exit 1
    fi
  fi

  printf "%s\n" "$versions"
}

latest_command "$@"

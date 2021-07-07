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
  else
    # pattern from xxenv-latest (https://github.com/momo-lab/xxenv-latest)
    versions=$(asdf list-all "$plugin_name" "$query" |
      grep -vE "(^Available versions:|-src|-dev|-latest|-stm|[-\\.]rc|-alpha|-beta|[-\\.]pre|-next|(a|b|c)[0-9]+|snapshot|master)" |
      sed 's/^\s\+//' |
      tail -1) 2>/dev/null
  fi

  if [ -z "${versions}" ]; then
    display_error "No compatible versions available ($plugin_name $query)"
    exit 1
  fi

  printf "%s\n" "$versions"
}

latest_command "$@"

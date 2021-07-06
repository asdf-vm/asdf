# -*- sh -*-

latest_command() {
  DEFAULT_QUERY="[0-9]"

  local plugin_name=$1
  local query=$2

  [[ -z $query ]] && query="$DEFAULT_QUERY"

  local versions
  # pattern from xxenv-latest (https://github.com/momo-lab/xxenv-latest)
  versions=$(asdf list-all "$plugin_name" "$query" |
    grep -vE "(^Available versions:|-src|-dev|-latest|-stm|[-\\.]rc|-alpha|-beta|[-\\.]pre|-next|(a|b|c)[0-9]+|snapshot|master)" |
    sed 's/^\s\+//' |
    tail -1)

  if [ -z "${versions}" ]; then
    exit 1
  fi

  printf "%s\n" "$versions"
}

latest_command "$@"

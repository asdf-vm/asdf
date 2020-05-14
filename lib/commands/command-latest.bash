# -*- sh -*-

latest_command() {
  DEFAULT_QUERY="[0-9]"

  local plugin_name=$1
  local query=$2

  [[ -z $query ]] && query="$DEFAULT_QUERY"

  local versions
  versions=$(asdf list-all "$plugin_name" "$query")

  if [ -n "${versions}" ]; then
    get_latest_version "$versions"
  else
    exit 1
  fi
}

latest_command "$@"

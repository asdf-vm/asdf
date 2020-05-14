# -*- sh -*-

latest_command() {
  DEFAULT_QUERY="[0-9]"

  local plugin_name=$1
  local query=$2

  [[ -z $query ]] && query="$DEFAULT_QUERY"

  get_latest_version "$(asdf list-all $plugin_name $query)"
}

latest_command "$@"

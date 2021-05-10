# -*- sh -*-

latest_command() {
  DEFAULT_QUERY="[0-9]"

  local plugin_name=$1
  local query=$2
  local plugin_path

  plugin_path=$(get_plugin_path "$plugin_name")
  check_if_plugin_exists "$plugin_name"

  [[ -z $query ]] && query="$DEFAULT_QUERY"

  if [ -f "${plugin_path}/bin/latest-stable" ]; then
    bash "${plugin_path}"/bin/latest-stable "$query"
    return
  fi

  # pattern from xxenv-latest (https://github.com/momo-lab/xxenv-latest)
  asdf list-all "$plugin_name" "$query" |
    grep -vE "(^Available versions:|-src|-dev|-latest|-stm|[-\\.]rc|-alpha|-beta|[-\\.]pre|-next|(a|b|c)[0-9]+|snapshot|master)" |
    sed 's/^\s\+//' |
    tail -1
}

latest_command "$@"

# -*- sh -*-

list_command() {
  local plugin_name=$1
  local query=$2
  local delimited=false
  local delimiter=" "

  if [ "$1" == "-d" ] || [ "$1" == "--delimited" ]; then
    plugin_name=""
    delimited=true
    if [ "$2" ]; then
      delimiter=$2
      query=""
    fi
  elif [ "$2" == "-d" ] || [ "$2" == "--delimited" ]; then
    query=""
    delimited=true
    if [ "$3" ]; then
      delimiter=$3
    fi
  elif [ "$3" == "-d" ] || [ "$3" == "--delimited" ]; then
    delimited=true
    if [ "$4" ]; then
      delimiter=$4
    fi  
  fi

  if [ -z "$plugin_name" ]; then
    local plugins_path
    plugins_path=$(get_plugin_path)

    if find "$plugins_path" -mindepth 1 -type d &>/dev/null; then
      for plugin_path in "$plugins_path"/*/; do
        plugin_name=$(basename "$plugin_path")
        if [ $delimited == false ]; then
        printf "%s\n" "$plugin_name"
        fi
        display_installed_versions "$plugin_name" "$query" "$delimited" "$delimiter"
      done
    else
      printf "%s\n" 'No plugins installed'
    fi
  else
    check_if_plugin_exists "$plugin_name"
    display_installed_versions "$plugin_name" "$query" "$delimited" "$delimiter"
  fi
}

display_installed_versions() {
  local plugin_name=$1
  local query=$2
  local delimited=$3
  local delimiter=$4
  local versions
  local current_version
  local flag

  versions=$(list_installed_versions "$plugin_name")

  if [ $query ]; then
    versions=$(printf "%s\n" "$versions" | grep -E "^\s*$query")

    if [ -z "${versions}" ]; then
      display_error "No compatible versions installed ($plugin_name $query)"
      exit 1
    fi
  fi

  if [ -n "${versions}" ]; then
    current_version=$(cut -d '|' -f 1 <<<"$(find_versions "$plugin_name" "$PWD")")

    for version in $versions; do
      flag=""
      if [ "$version" == "$current_version" ]; then
        flag="*"
      fi
      if [ $delimited == false ]; then
        printf " %s%s\n" "$flag" "$version"
      else
        printf "%s${delimiter}%s${delimiter}%s\n" "$plugin_name" "$version" "$flag"
      fi
    done
  else
    display_error '  No versions installed'
  fi
}

list_command "$@"

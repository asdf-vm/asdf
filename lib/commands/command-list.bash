# -*- sh -*-

list_command() {
  local plugin_name=$1

  if [ -z "$plugin_name" ]; then
    local plugins_path
    plugins_path=$(get_plugin_path)

    if ls "$plugins_path" &>/dev/null; then
      for plugin_path in "$plugins_path"/*; do
        plugin_name=$(basename "$plugin_path")
        echo "$plugin_name"
        display_installed_versions "$plugin_name"
      done
    else
      printf "%s\\n" 'Oohes nooes ~! No plugins installed'
    fi
  else
    check_if_plugin_exists "$plugin_name"
    display_installed_versions "$plugin_name"
  fi
}

display_installed_versions() {
  local versions
  local plugin
  local cver
  local flag
  
  plugin=$1
  versions=$(list_installed_versions "$plugin")
  if [ -n "${versions}" ]; then
    cver=$(asdf current "$plugin" | cut -f 1 -d " ")
    for version in $versions; do
      flag="  "
      if [[ "$version" == "$cver" ]]; then
        flag=" *"
      fi
      echo "${flag}$version"
    done
  else
    display_error 'No versions installed'
  fi
}

list_command "$@"

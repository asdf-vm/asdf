current_command() {
  local exit_code=0
  local short=false

  local plugin_names=""

  while [ $# -gt 0 ]
  do
    case "$1" in
      --short) short=true ;;
      -*) ;;
      *)
        plugin_names="$1" ;;
    esac
    shift
  done


  if [ -z "$plugin_names" ]; then
    read -a plugin_names <<< $(plugin_list_command)
  fi

  for plugin_name in "${plugin_names[@]}"; do
    local version=$(get_preset_version_for $plugin_name)

    check_if_plugin_exists $plugin_name

    if [ "$version" == "" ]; then
      echo "No version set for $plugin_name"
      exit_code=1
    else
      if [ "$short" = true ]; then
        echo "$version"
      else
        local version_file_path=$(get_version_file_path_for $plugin_name)
        if [ "$version_file_path" == "" ]; then
          echo "$plugin_name $version"
        else
          echo "$plugin_name $version (set by $version_file_path)"
        fi
      fi
    fi
  done

  exit $exit_code
}

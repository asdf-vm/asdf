which_command() {
  local command=$1
  local plugins_path
  plugins_path=$(get_plugin_path)

  if ls "$plugins_path" &> /dev/null; then
    for plugin_path in "$plugins_path"/* ; do
      plugin_name=$(basename "$plugin_path")
      full_version=$(get_preset_version_for "$plugin_name")
      IFS=' ' read -a versions <<< "$full_version"
      for version in "${versions[@]}"; do
        if [ -f "${plugin_path}/bin/exec-path" ]; then
          echo "EXEC_PATH"
          cmd=$(basename "$executable_path")
          executable_path="$("${plugin_path}/bin/exec-path" "$install_path" "$cmd" "$executable_path")"
        fi
        full_executable_path=$(get_executable_path "$plugin_name" "$version" "$executable_path")
        local location=$(find $full_executable_path -name $command -type f -perm -u+x | sed -e 's|//|/|g')
        if [ ! -z "$location" ]; then
          echo $location
          not_found=0
        else
          not_found=1
        fi
      done
    done
    if [ $not_found -eq 1 ]; then
      echo "No executable binary found for $command"
      exit 1
    fi
  fi
  exit 0
}
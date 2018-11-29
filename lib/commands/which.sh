which_command() {
  local command=$1 plugins_path not_found plugin_name full_version location
  plugins_path=$(get_plugin_path)

  if ls "$plugins_path" &> /dev/null; then
    for plugin_path in "$plugins_path"/* ; do
      plugin_name=$(basename "$plugin_path")
      full_version=$(get_preset_version_for "$plugin_name")
      # shellcheck disable=SC2162
      IFS=' ' read -a versions <<< "$full_version"
      for version in "${versions[@]}"; do
        if [ "$version" = "system" ]; then
          continue
        fi
        if [ -f "${plugin_path}/bin/exec-path" ]; then
          cmd=$(basename "$executable_path")
          install_path=$(find_install_path "$plugin_name" "$version")
          executable_path="$("${plugin_path}/bin/exec-path" "$install_path" "$cmd" "$executable_path")"
        fi
        full_executable_path=$(get_executable_path "$plugin_name" "$version" "$executable_path")
        location=$(find -L "$full_executable_path" -maxdepth 4 -name "$command" -type f -perm -u+x | sed -e 's|//|/|g')
        if [ -n "$location" ]; then
          echo "$location"
          not_found=0
          break 2
        else
          not_found=1
        fi
      done
    done
  fi
  if [ $not_found -eq 1 ]; then
    echo "No executable binary found for $command"
    exit 1
  fi
  exit 0
}

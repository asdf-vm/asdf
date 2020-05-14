# -*- sh -*-

version_command() {
  local cmd=$1
  local plugin_name=$2

  if [ "$#" -lt "3" ]; then
    if [ "$cmd" = "global" ]; then
      echo "Usage: asdf global <name> <version>"
    else
      echo "Usage: asdf local <name> <version>"
    fi
    exit 1
  fi

  shift 2
  local versions=("$@")

  local file
  if [ "$cmd" = "global" ]; then
    file=${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME:-$HOME/.tool-versions}
  elif [ "$cmd" = "local-tree" ]; then
    file=$(find_tool_versions)
  else # cmd = local
    file="$(pwd)/.tool-versions"
  fi

  if [ -L "$file" ]; then
    # Resolve file path if symlink
    file="$(resolve_symlink "$file")"
  fi

  check_if_plugin_exists "$plugin_name"

  for i in "${!versions[@]}"; do
    IFS=':' read -r -a version_info <<<"${versions[$i]}"
    if [ "${version_info[0]}" = "latest" ]; then
      local installed_versions
      installed_versions=$(asdf list "$plugin_name" "${version_info[1]}")

      if [ -z "$installed_versions" ]; then
        exit 1
      fi

      versions[$i]=$(get_latest_version "$installed_versions")
    fi
  done

  local version
  for version in "${versions[@]}"; do
    check_if_version_exists "$plugin_name" "$version"
  done

  if [ -f "$file" ] && grep "^$plugin_name " "$file" >/dev/null; then
    sed -i.bak -e "s|^$plugin_name .*$|$plugin_name ${versions[*]}|" "$file"
    rm "$file".bak
  else
    echo "$plugin_name ${versions[*]}" >>"$file"
  fi
}

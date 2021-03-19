# -*- sh -*-

version_command() {
  local cmd=$1
  local plugin_name=$2

  if [ "$#" -lt "3" ]; then
    if [ "$cmd" = "global" ]; then
      printf "Usage: asdf global <name> <version>\\n"
    else
      printf "Usage: asdf local <name> <version>\\n"
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

  declare -a resolved_versions
  local version
  for version in "${versions[@]}"; do
    if [ "$version" = "latest" ]; then
      version=$(asdf latest "$plugin_name")
    fi
    if ! (check_if_version_exists "$plugin_name" "$version"); then
      version_not_installed_text "$plugin_name" "$version" 1>&2
    fi
    resolved_versions+=("$version")
  done
  
  if [ -z "$resolved_versions" ] || [ "$cmd" = "local-tree" ]; then
    exit 1
  fi

  if [ -f "$file" ] && grep "^$plugin_name " "$file" >/dev/null; then
    sed -i.bak -e "s|^$plugin_name .*$|$plugin_name ${resolved_versions[*]}|" "$file"
    rm "$file".bak
    printf "Replacing %s %s with version %s in %s\\n" "$cmd" "$plugin_name" "${resolved_versions[*]}" "$file"
  else
    printf "\\n%s %s\\n" "$plugin_name" "${resolved_versions[*]}" >>"$file"
    printf "Adding %s %s version %s to %s\\n" "$cmd" "$plugin_name" "${resolved_versions[*]}" "$file"
  fi
}

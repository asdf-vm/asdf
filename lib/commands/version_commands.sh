version_command() {
  local cmd=$1
  local plugin=$2

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

  check_if_plugin_exists "$plugin"

  local version
  for version in "${versions[@]}"; do
    check_if_version_exists "$plugin" "$version"
  done


  if [ -f "$file" ] && grep "^$plugin " "$file" > /dev/null; then
    sed -i.bak -e "s/^$plugin .*$/$plugin ${versions[*]}/" "$file"
    rm "$file".bak
  else
    echo "$plugin ${versions[*]}" >> "$file"
  fi
}

local_command() {
  local parent=false
  local positional=()

  while [[ $# -gt 0 ]]
  do
    case $1 in
      -p|--parent)
        parent="true"
        shift # past value
        ;;
      *)
        positional+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
  done

  set -- "${positional[@]}" # restore positional parameters

  if [ $parent = true ]; then
    # shellcheck disable=2068
    version_command "local-tree" $@
  else
    # shellcheck disable=2068
    version_command "local" $@
  fi
}

global_command() {
  # shellcheck disable=2068
  version_command "global" $@
}

# Output from this command must be executable shell code
shell_command() {
  if [ "$#" -lt "2" ]; then
    echo "Usage: asdf shell <name> <version>" >&2
    echo 'false'
    exit 1
  fi

  local plugin=$1
  local version=$2

  if ! (check_if_version_exists "$plugin" "$version"); then
    echo 'false'
    exit 1
  fi

  local upcase_name
  upcase_name=$(echo "$plugin" | tr '[:lower:]-' '[:upper:]_')
  local version_env_var="ASDF_${upcase_name}_VERSION"

  case $ASDF_SHELL in
    fish )
      echo "set -gx $version_env_var \"$version\"";;
    * )
      echo "export $version_env_var=\"$version\"";;
  esac
}

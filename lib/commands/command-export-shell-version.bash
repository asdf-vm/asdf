# -*- sh -*-

# Output from this command must be executable shell code
shell_command() {
  local asdf_shell="$1"
  shift

  if [ "$#" -lt "2" ]; then
    echo "Usage: asdf shell <name> {<version>|--unset}" >&2
    echo 'false'
    exit 1
  fi

  local plugin=$1
  local version=$2

  local upcase_name
  upcase_name=$(echo "$plugin" | tr '[:lower:]-' '[:upper:]_')
  local version_env_var="ASDF_${upcase_name}_VERSION"

  if [ "$version" = "--unset" ]; then
    case "$asdf_shell" in
    fish)
      echo "set -e $version_env_var"
      ;;
    *)
      echo "unset $version_env_var"
      ;;
    esac
    exit 0
  fi
  if ! (check_if_version_exists "$plugin" "$version"); then
    version_not_installed_text "$plugin" "$version" 1>&2
    echo 'false'
    exit 1
  fi

  case "$asdf_shell" in
  fish)
    echo "set -gx $version_env_var \"$version\""
    ;;
  *)
    echo "export $version_env_var=\"$version\""
    ;;
  esac
}

shell_command "$@"

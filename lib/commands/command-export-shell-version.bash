# -*- sh -*-

# Output from this command must be executable shell code
shell_command() {
  local asdf_shell="$1"
  shift

  if [ "$#" -lt "2" ]; then
    printf "Usage: asdf shell <name> {<version>|--unset}\\n" >&2
    printf "false\\n"
    exit 1
  fi

  local plugin=$1
  local version=$2

  local upcase_name
  upcase_name=$(tr '[:lower:]-' '[:upper:]_' <<<"$plugin")
  local version_env_var="ASDF_${upcase_name}_VERSION"

  if [ "$version" = "--unset" ]; then
    case "$asdf_shell" in
    fish)
      printf "set -e %s\\n" "$version_env_var"
      ;;
    *)
      printf "unset %s\\n" "$version_env_var"
      ;;
    esac
    exit 0
  fi
  if [ "$version" = "latest" ]; then
    version=$(asdf latest "$plugin")
  fi
  if ! (check_if_version_exists "$plugin" "$version"); then
    version_not_installed_text "$plugin" "$version" 1>&2
    printf "false\\n"
    exit 1
  fi

  case "$asdf_shell" in
  fish)
    printf "set -gx %s \"%s\"\\n" "$version_env_var" "$version"
    ;;
  *)
    printf "export %s=\"%s\"\\n" "$version_env_var" "$version"
    ;;
  esac
}

shell_command "$@"

# -*- sh -*-

shim_env_command() {
  local shim_name="$1"
  local env_cmd="${2}"
  local env_args=("${@:3}")

  local help_text="usage: asdf env <command>"
  if has_help_flag "$@"; then
    printf '%s\n' "$help_text"
    exit 0
  fi
  if [ -z "$shim_name" ]; then
    display_error "$help_text"
    exit 1
  fi

  if [ -z "$env_cmd" ]; then
    env_cmd="env"
  fi

  shim_env() {
    "$env_cmd" "${env_args[@]}"
  }

  with_shim_executable "$shim_name" shim_env || exit $?
}

shim_env_command "$@"

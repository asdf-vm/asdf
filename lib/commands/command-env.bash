# -*- sh -*-

shim_env_command() {
  local shim_name="$1"
  local env_cmd="${2}"
  local env_args=("${@:3}")

  if [ -z "$shim_name" ]; then
    printf "usage: asdf env <command>\n"
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

# -*- sh -*-
set -o nounset

shim_env_command() {
  local shim_name="${1:-}"
  local env_cmd="${2:-}"
  local env_args=("${@:3}")

  if [ -z "$shim_name" ]; then
    printf "usage: asdf env <command>\\n"
    exit 1
  fi

  if [ -z "$env_cmd" ]; then
    env_cmd="env"
  fi

  shim_env() {
    # Yes, the syntax for the expansion is ugly and confusing, but it is what we
    # need to do to make it work with the nounset option. See
    # https://stackoverflow.com/q/7577052/ for the details
    "$env_cmd" ${env_args[@]+"${env_args[@]}"}
  }

  with_shim_executable "$shim_name" shim_env || exit $?
}

shim_env_command "$@"

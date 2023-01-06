# -*- sh -*-

shim_exec_command() {
  local shim_name
  shim_name=$(basename "$1")
  local shim_args=("${@:2}")

  if [ -z "$shim_name" ]; then
    printf "usage: asdf exec <command>\n"
    exit 1
  fi

  exec_shim() {
    local plugin_name="$1"
    local version="$2"
    local executable_path="$3"

    if [ ! -x "$executable_path" ]; then
      printf "No %s executable found for %s %s\n" "$shim_name" "$plugin_name" "$version" >&2
      exit 2
    fi

    asdf_run_hook "pre_${plugin_name}_${shim_name}" "${shim_args[@]}"
    pre_status=$?
    if [ "$pre_status" -ne 0 ]; then
      return "$pre_status"
    fi
    exec "$executable_path" "${shim_args[@]}"
  }

  with_shim_executable "$shim_name" exec_shim || exit $?
}

shim_exec_command "$@"

# -*- sh -*-

shim_exec_command() {
  local shim_name
  shim_name=$(basename "$1")

  local shim_args=()
  if [ $# -gt 1 ]; then
    shim_args=("${@:2}")
  fi

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

    # Check if array is empty before using it
    if [ ${#shim_args[@]} -eq 0 ]; then
      asdf_run_hook "pre_${plugin_name}_${shim_name}"
      pre_status=$?
    else
      asdf_run_hook "pre_${plugin_name}_${shim_name}" "${shim_args[@]}"
      pre_status=$?
    fi

    if [ "$pre_status" -ne 0 ]; then
      return "$pre_status"
    fi

    # Check if array is empty before using it
    if [ ${#shim_args[@]} -eq 0 ]; then
      exec "$executable_path"
    else
      exec "$executable_path" "${shim_args[@]}"
    fi
  }

  with_shim_executable "$shim_name" exec_shim || exit $?
}

shim_exec_command "$@"

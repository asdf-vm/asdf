shim_exec_command() {
  local shim_name
  shim_name=$(basename "$1")
  local shim_args=("${@:2}")

  if [ -z "$shim_name" ]; then
    echo "usage: asdf exec <command>"
    exit 1
  fi

  exec_shim() {
    local plugin_name="$1"
    local version="$2"
    local executable_path="$3"

    if [ ! -x "$executable_path" ]; then
      echo "No ${shim_name} executable found for ${plugin_name} ${version}" >&2
      exit 2
    fi

    asdf_run_hook "pre_${plugin_name}_${shim_name}" "${shim_args[@]}"
    pre_status=$?
    if [ "$pre_status" -eq 0 ]; then
      "$executable_path" "${shim_args[@]}"
      exit_status=$?
    fi
    if [ "${exit_status:-${pre_status}}" -eq 0 ]; then
      asdf_run_hook "post_${plugin_name}_${shim_name}" "${shim_args[@]}"
      post_status=$?
    fi
    exit "${post_status:-${exit_status:-${pre_status}}}"
  }

  with_shim_executable "$shim_name" exec_shim || exit $?
}

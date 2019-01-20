which_command() {
  local shim_name
  shim_name=$(basename "$1")

  if [ -z "$shim_name" ]; then
    echo "usage: asdf which <command>"
    exit 1
  fi

  print_exec() {
    local plugin_name="$1"
    local version="$2"
    local executable_path="$3"

    if [ ! -x "$executable_path" ]; then
      echo "No ${shim_name} executable found for ${plugin_name} ${version}" >&2
      exit 1
    fi

    echo "$executable_path"
    exit 0
  }

  with_shim_executable "$shim_name" print_exec || exit 1
}

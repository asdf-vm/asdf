# -*- sh -*-

which_command() {
  local shim_name
  shim_name=$(basename "$1")

  if [ -z "$shim_name" ]; then
    printf "usage: asdf which <command>\n"
    exit 1
  fi

  print_exec() {
    local plugin_name="$1"
    local version="$2"
    local executable_path="$3"

    if [ ! -x "$executable_path" ]; then
      printf "No %s executable found for %s %s\n" "$shim_name" "$plugin_name" "$version" >&2
      exit 1
    fi

    printf "%s\n" "$executable_path"
    exit 0
  }

  with_shim_executable "$shim_name" print_exec || exit 1
}

which_command "$@"

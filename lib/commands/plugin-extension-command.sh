plugin_extension_command() {
  local plugin_bin_dir plugin_cmd
  plugin_bin_dir="$(get_plugin_path "$1")/bin"

  if test -d "$plugin_bin_dir"; then
    if test -f "$plugin_bin_dir/$2"; then
      plugin_cmd="$plugin_bin_dir/$2"
      shift # consume plugin name
      shift # and command name
    elif test -f "$plugin_bin_dir/default-command"; then
      plugin_cmd="$plugin_bin_dir/default-command"
      shift # only consume plugin name
    fi

    if test -x "$plugin_cmd"; then
      exec "$plugin_cmd" "$@"
    elif test -f "$plugin_cmd"; then
      # shellcheck disable=SC1090 # Cant follow non constant source
      source "$plugin_cmd"
      exit $?
    fi
  fi
}

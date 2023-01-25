# -*- sh -*-

shim_versions_command() {
  if has_help_flag "$@"; then
    printf '%s\n' 'usage: asdf shim-versions <command>'
    exit 0
  fi

  local shim_name=$1
  shim_plugin_versions "$shim_name"
}

shim_versions_command "$@"

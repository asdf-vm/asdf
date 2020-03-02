# -*- sh -*-

plugin_update_command() {
  if [ "$#" -lt 1 ]; then
    display_error "usage: asdf plugin-update {<name> | --all} [git-ref]"
    exit 1
  fi

  local plugin_name="$1"
  local gitref="${2:-master}"
  if [ "$plugin_name" = "--all" ]; then
    for dir in "$(asdf_data_dir)"/plugins/*; do
      echo "Updating $(basename "$dir")..."
      (cd "$dir" && git fetch -p -u origin "$gitref:$gitref" && git checkout -f "$gitref")
    done
  else
    local plugin_path
    plugin_path="$(get_plugin_path "$plugin_name")"
    check_if_plugin_exists "$plugin_name"
    echo "Updating $plugin_name..."
    (cd "$plugin_path" && git fetch -p -u origin "$gitref:$gitref" && git checkout -f "$gitref")
  fi
}

plugin_update_command "$@"

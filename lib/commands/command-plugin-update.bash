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
      local plugin_name
      plugin_name=$(basename "$dir")
      update_plugin "$plugin_name" "$dir" "$gitref" &
    done
    wait
  else
    local plugin_path
    plugin_path="$(get_plugin_path "$plugin_name")"
    check_if_plugin_exists "$plugin_name"
    update_plugin "$plugin_name" "$plugin_path" "$gitref"
  fi
}

update_plugin() {
  local plugin_name=$1
  local plugin_path=$2
  local gitref=$3
  logfile=$(mktemp)
  {
    echo "Updating $plugin_name..."
    (cd "$plugin_path" && git fetch -p -u origin "$gitref:$gitref" && git checkout -f "$gitref")
  } >"$logfile" 2>&1
  cat "$logfile"
  rm "$logfile"
}

plugin_update_command "$@"

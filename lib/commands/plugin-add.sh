plugin_add_command() {
  if [[ $# -lt 1 || $# -gt 2 ]]; then
    display_error "usage: asdf plugin-add <name> [<git-url>]"
    exit 1
  fi

  local plugin_name=$1

  if [ -n "$2" ]; then
    local source_url=$2
  else
    initialize_or_update_repository
    local source_url
    source_url=$(get_plugin_source_url "$plugin_name")
  fi

  if [ -z "$source_url" ]; then
    display_error "plugin $plugin_name not found in repository"
    exit 1
  fi

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  mkdir -p "$(asdf_dir)/plugins"

  if [ -d "$plugin_path" ]; then
    display_error "Plugin named $plugin_name already added"
    exit 1
  else
    if ! git clone "$source_url" "$plugin_path"; then
      exit 1
    fi
  fi
}

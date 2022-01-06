# -*- sh -*-

plugin_add_command() {
  if [[ $# -lt 1 || $# -gt 2 ]]; then
    display_error "usage: asdf plugin add <name> [<git-url>]"
    exit 1
  fi

  local plugin_name=$1

  if ! printf "%s" "$plugin_name" | grep -q -E "^[a-zA-Z0-9_-]+$"; then
    display_error "$plugin_name is invalid. Name must match regex ^[a-zA-Z0-9_-]+$"
    exit 1
  fi

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

  mkdir -p "$(asdf_data_dir)/plugins"

  if [ -d "$plugin_path" ]; then
    display_error "Plugin named $plugin_name already added"
    exit 2
  else
    asdf_run_hook "pre_asdf_plugin_add" "$plugin_name"
    asdf_run_hook "pre_asdf_plugin_add_${plugin_name}"

    if ! git clone -q "$source_url" "$plugin_path"; then
      exit 1
    fi

    if [ -f "${plugin_path}/bin/post-plugin-add" ]; then
      (
        export ASDF_PLUGIN_SOURCE_URL=$source_url
        export ASDF_PLUGIN_PATH=$plugin_path
        "${plugin_path}/bin/post-plugin-add"
      )
    fi

    asdf_run_hook "post_asdf_plugin_add" "$plugin_name"
    asdf_run_hook "post_asdf_plugin_add_${plugin_name}"
  fi
}

plugin_add_command "$@"

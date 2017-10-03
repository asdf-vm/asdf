plugin_add_command() {
  if [[ $# -lt 1 || $# -gt 3 ]]; then
    display_error "usage: asdf plugin-add <name> [<git-url>] [<git-branch>]"
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

	if [ -n "$3" ]; then
		local plugin_branch=$3
		plugin_name=$plugin_name-$3
	else
		local plugin_branch=master
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
    if git clone -b "$plugin_branch" "$source_url" "$plugin_path"; then
      exit 1
    fi
  fi
}

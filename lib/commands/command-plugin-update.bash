# -*- sh -*-

plugin_update_command() {
  if [ "$#" -lt 1 ]; then
    display_error "usage: asdf plugin-update {<name> [git-ref] | --all}"
    exit 1
  fi

  local plugin_name="$1"
  local plugin_path
  local branch_of_head
  local gitref

  if [ "$plugin_name" = "--all" ]; then
    for dir in "$(asdf_data_dir)"/plugins/*; do
      branch_of_head=$(git --git-dir "$dir/.git" rev-parse --abbrev-ref HEAD 2>/dev/null)

      printf "%s %s%s\\n" "Updating" "$(basename "$dir")" "..."
      gitref="${branch_of_head}"
      git --git-dir "$dir/.git" --work-tree "$dir" fetch -p -u origin "$gitref:$gitref"
      git --git-dir "$dir/.git" --work-tree "$dir" checkout -f "$gitref"
    done
  else
    check_if_plugin_exists "$plugin_name"
    plugin_path="$(get_plugin_path "$plugin_name")"
    branch_of_head=$(git --git-dir "$plugin_path/.git" rev-parse --abbrev-ref HEAD 2>/dev/null)

    printf "%s %s%s\\n" "Updating" "$plugin_name" "..."
    gitref="${2:-${branch_of_head}}"
    git --git-dir "$plugin_path/.git" --work-tree "$plugin_path" fetch -p -u origin "$gitref:$gitref"
    git --git-dir "$plugin_path/.git" --work-tree "$plugin_path" checkout -f "$gitref"
  fi
}

plugin_update_command "$@"

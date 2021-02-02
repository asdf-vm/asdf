# -*- sh -*-

plugin_update_command() {
  if [ "$#" -lt 1 ]; then
    display_error "usage: asdf plugin-update {<name> [git-ref] | --all}"
    exit 1
  fi

  local plugin_name="$1"
  local gitref="${2}"

  if [ "$plugin_name" = "--all" ]; then
    for dir in "$(asdf_data_dir)"/plugins/*; do
      update_plugin "$(basename "$dir")" "$dir" "$gitref" &
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
  repo_default_branch=$(git --git-dir "$plugin_path/.git" --work-tree "$plugin_path" remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
  local gitref=${3:-${repo_default_branch}}
  logfile=$(mktemp)
  {
    printf "Updating %s...\\n" "$plugin_name"
    git --git-dir "$plugin_path/.git" --work-tree "$plugin_path" fetch --prune --update-head-ok origin "$gitref:$gitref"
    git --git-dir "$plugin_path/.git" --work-tree "$plugin_path" checkout --force "$gitref"
  } >"$logfile" 2>&1
  cat "$logfile"
  rm "$logfile"
}

plugin_update_command "$@"

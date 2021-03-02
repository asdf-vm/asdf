# -*- sh -*-

plugin_update_command() {
  if [ "$#" -lt 1 ]; then
    display_error "usage: asdf plugin-update {<name> [git-ref] | --all}"
    exit 1
  fi

  local plugin_name="$1"
  local gitref="${2}"

  if [ "$plugin_name" = "--all" ]; then
    if [ -d "$(asdf_data_dir)"/plugins ]; then
      while IFS= read -r dir; do
        update_plugin "$(basename "$dir")" "$dir" "$gitref" &
      done < <(find "$(asdf_data_dir)"/plugins -mindepth 1 -maxdepth 1 -type d)
      wait
    fi
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
  plugin_remote_default_branch=$(git --git-dir "$plugin_path/.git" --work-tree "$plugin_path" ls-remote --symref origin HEAD | awk -F'[[:space:]]*' 'NR == 1 {sub(/refs\/heads\//, "", $2); print $2}')
  local gitref=${3:-${plugin_remote_default_branch}}
  logfile=$(mktemp)
  {
    printf "Updating %s to %s\\n" "$plugin_name" "$gitref"
    git --git-dir "$plugin_path/.git" --work-tree "$plugin_path" fetch --prune --update-head-ok origin "$gitref:$gitref"
    git --git-dir "$plugin_path/.git" --work-tree "$plugin_path" -c advice.detachedHead=false checkout --force "$gitref"
  } >"$logfile" 2>&1
  cat "$logfile"
  rm "$logfile"
}

plugin_update_command "$@"

# -*- sh -*-

plugin_update_command() {
  if [ "$#" -lt 1 ]; then
    display_error "usage: asdf plugin-update {<name> [git-ref] | --all}"
    exit 1
  fi

  local plugin_name="$1"
  local gitref="${2}"
  local plugins=

  if [ "$plugin_name" = "--all" ]; then
    if [ -d "$(asdf_data_dir)"/plugins ]; then
      plugins=$(find "$(asdf_data_dir)"/plugins -mindepth 1 -maxdepth 1 -type d)
      while IFS= read -r dir; do
        update_plugin "$(basename "$dir")" "$dir" "$gitref" &
      done <<<"$plugins"
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
  plugin_remote_default_branch=$(git --git-dir "$plugin_path/.git" --work-tree "$plugin_path" ls-remote --symref origin HEAD | awk '{ sub(/refs\/heads\//, ""); print $2; exit }')
  local gitref=${3:-${plugin_remote_default_branch}}
  logfile=$(mktemp)

  local common_git_options=(--git-dir "$plugin_path/.git" --work-tree "$plugin_path")
  local prev_ref=
  local post_ref=
  {
    asdf_run_hook "pre_asdf_plugin_update" "$plugin_name"
    asdf_run_hook "pre_asdf_plugin_update_${plugin_name}"

    printf "Updating %s to %s\\n" "$plugin_name" "$gitref"

    git "${common_git_options[@]}" fetch --prune --update-head-ok origin "$gitref:$gitref"
    prev_ref=$(git "${common_git_options[@]}" rev-parse --short HEAD)
    post_ref=$(git "${common_git_options[@]}" rev-parse --short "${gitref}")
    git "${common_git_options[@]}" -c advice.detachedHead=false checkout --force "$gitref"

    if [ -f "${plugin_path}/bin/post-plugin-update" ]; then
      (
        export ASDF_PLUGIN_PATH=$plugin_path
        export ASDF_PLUGIN_PREV_REF=$prev_ref
        export ASDF_PLUGIN_POST_REF=$post_ref
        "${plugin_path}/bin/post-plugin-update"
      )
    fi

    asdf_run_hook "post_asdf_plugin_update" "$plugin_name"
    asdf_run_hook "post_asdf_plugin_update_${plugin_name}"
  } >"$logfile" 2>&1
  cat "$logfile"
  rm "$logfile"
}

plugin_update_command "$@"

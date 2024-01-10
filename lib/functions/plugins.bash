plugin_list_command() {
  local plugins_path
  plugins_path=$(get_plugin_path)

  local show_repo
  local show_ref

  while [ -n "$*" ]; do
    case "$1" in
    "--urls")
      show_repo=true
      shift
      ;;
    "--refs")
      show_ref=true
      shift
      ;;
    *)
      shift
      ;;
    esac
  done

  if find "$plugins_path" -mindepth 1 -type d &>/dev/null; then
    (
      for plugin_path in "$plugins_path"/*/; do
        plugin_name=$(basename "$plugin_path")
        printf "%s" "$plugin_name"

        if [ -n "$show_repo" ]; then
          printf "\t%s" "$(get_plugin_remote_url "$plugin_name")"
        fi

        if [ -n "$show_ref" ]; then
          printf "\t%s\t%s" \
            "$(get_plugin_remote_branch "$plugin_name")" \
            "$(get_plugin_remote_gitref "$plugin_name")"
        fi

        printf "\n"
      done
    ) | awk '{ if (NF > 1) { printf("%-28s", $1) ; $1="" }; print $0}'
  else
    display_error 'No plugins installed'
    exit 0
  fi
}

plugin_add_command() {
  if [[ $# -lt 1 || $# -gt 2 ]]; then
    display_error "usage: asdf plugin add <name> [<git-url>]"
    exit 1
  fi

  local plugin_name=$1

  local regex="^[[:lower:][:digit:]_-]+$"
  if ! printf "%s" "$plugin_name" | grep -q -E "$regex"; then
    display_error "$plugin_name is invalid. Name may only contain lowercase letters, numbers, '_', and '-'"
    exit 1
  fi

  if [ -n "$2" ]; then
    local source_url=$2
  else
    initialize_or_update_plugin_repository
    local source_url
    source_url=$(get_plugin_source_url "$plugin_name")
  fi

  if [ -z "$source_url" ]; then
    display_error "plugin $plugin_name not found in repository"
    exit 1
  fi

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  [ -d "$(asdf_data_dir)/plugins" ] || mkdir -p "$(asdf_data_dir)/plugins"

  if [ -d "$plugin_path" ]; then
    printf '%s\n' "Plugin named $plugin_name already added"
    exit 0
  else
    asdf_run_hook "pre_asdf_plugin_add" "$plugin_name"
    asdf_run_hook "pre_asdf_plugin_add_${plugin_name}"

    if ! git clone -q "$source_url" "$plugin_path"; then
      exit 1
    fi

    if [ -f "${plugin_path}/bin/post-plugin-add" ]; then
      (
        export ASDF_PLUGIN_SOURCE_URL=$source_url
        # shellcheck disable=SC2030
        export ASDF_PLUGIN_PATH=$plugin_path
        "${plugin_path}/bin/post-plugin-add"
      )
    fi

    asdf_run_hook "post_asdf_plugin_add" "$plugin_name"
    asdf_run_hook "post_asdf_plugin_add_${plugin_name}"
  fi
}

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
    printf "Location of %s plugin: %s\n" "$plugin_name" "$plugin_path"
    asdf_run_hook "pre_asdf_plugin_update" "$plugin_name"
    asdf_run_hook "pre_asdf_plugin_update_${plugin_name}"

    printf "Updating %s to %s\n" "$plugin_name" "$gitref"

    git "${common_git_options[@]}" fetch --prune --update-head-ok origin "$gitref:$gitref"
    prev_ref=$(git "${common_git_options[@]}" rev-parse --short HEAD)
    post_ref=$(git "${common_git_options[@]}" rev-parse --short "${gitref}")
    git "${common_git_options[@]}" -c advice.detachedHead=false checkout --force "$gitref"

    if [ -f "${plugin_path}/bin/post-plugin-update" ]; then
      (
        # shellcheck disable=SC2031
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

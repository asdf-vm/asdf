# -*- sh -*-

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
      for plugin_path in "$plugins_path"/*; do
        plugin_name=$(basename "$plugin_path")
        printf "%s" "$plugin_name"

        if [ -n "$show_repo" ]; then
          printf "\\t%s" "$(git --git-dir "$plugin_path/.git" remote get-url origin 2>/dev/null)"
        fi

        if [ -n "$show_ref" ]; then
          local branch
          local gitref
          branch=$(git --git-dir "$plugin_path/.git" rev-parse --abbrev-ref HEAD 2>/dev/null)
          gitref=$(git --git-dir "$plugin_path/.git" rev-parse --short HEAD 2>/dev/null)
          printf "\\t%s\\t%s" "$branch" "$gitref"
        fi

        printf "\\n"
      done
    ) | awk '{ if (NF > 1) { printf("%-28s", $1) ; $1="" }; print $0}'
  else
    display_error 'No plugins installed'
    exit 1
  fi
}

plugin_list_command "$@"

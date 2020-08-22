# The asdf function is a wrapper so we can export variables
asdf() {
  local command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  "shell")
    # commands that need to export variables
    eval "$(asdf export-shell-version sh "$@")" # asdf_allow: eval
    ;;
  *)
    # forward other commands to asdf script
    command asdf "$command" "$@"
    ;;

  esac
}

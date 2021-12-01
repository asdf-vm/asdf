# The asdf function is a wrapper so we can export variables
asdf() {
  case "$1" in
  "shell")
    shift
    # commands that need to export variables
    eval "$(asdf export-shell-version sh "$@")" # asdf_allow: eval
    ;;
  *)
    # forward other commands to asdf script
    command asdf "$@"
    ;;

  esac
}

# shellcheck shell=sh

# The asdf function is a wrapper so we can export variables
asdf() {
  case $1 in
  "shell")
    if ! shift; then
      printf '%s\n' 'asdf: Error: Failed to shift' >&2
      return 1
    fi

    # Invoke command that needs to export variables.
    eval "$(asdf export-shell-version sh "$@")" # asdf_allow: eval
    ;;
  *)
    # Forward other commands to asdf script.
    command asdf "$@" # asdf_allow: ' asdf '
    ;;
  esac
}

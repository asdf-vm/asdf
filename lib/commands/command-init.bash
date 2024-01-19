# -*- sh -*-
# shellcheck source=lib/functions/plugins.bash
. "$(dirname "$(dirname "$0")")/lib/functions/plugins.bash"

init_command() {
  local shell=$1
  local dir
  dir="$(dirname "$(dirname "$0")")"

  case $shell in
  sh)
    cat "$dir/asdf.sh"
    ;;
  bash)
    cat "$dir/asdf.sh"
    ;;
  zsh)
    cat "$dir/asdf.sh"
    ;;
  fish)
    cat "$dir/asdf.fish"
    ;;
  elvish)
    cat "$dir/asdf.elv"
    ;;
  nushell)
    cat "$dir/asdf.nu"
    ;;
  powershell)
    cat "$dir/asdf.ps1"
    ;;
  esac
}

init_command "$@"

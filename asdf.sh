#!/usr/bin/env bash

# For Korn shells (ksh, mksh, etc.), capture $_ (the final parameter passed to
# the last command) straightaway, as it will contain the path to this script.
# For Bash, ${BASH_SOURCE[0]} will be used to obtain this script's path.
# For Zsh and others, $0 (the path to the shell or script) will be used.
_under="$_"
if [ "${BASH_SOURCE[0]}" != "" ]; then
  current_script_path="${BASH_SOURCE[0]}"
elif [[ "$_under" == *".sh" ]]; then
  current_script_path="$_under"
else
  current_script_path="$0"
fi

export ASDF_DIR
ASDF_DIR="$(dirname "$current_script_path")"
# shellcheck disable=SC2016
[ -d "$ASDF_DIR" ] || echo '$ASDF_DIR is not a directory'

# Add asdf to PATH
#
# if in $PATH, remove, regardless of if it is in the right place (at the front) or not.
# replace all occurrences - ${parameter//pattern/string}
ASDF_BIN="${ASDF_DIR}/bin"
ASDF_USER_SHIMS="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
[[ ":$PATH:" == *":${ASDF_BIN}:"* ]] && PATH="${PATH//$ASDF_BIN:/}"
[[ ":$PATH:" == *":${ASDF_USER_SHIMS}:"* ]] && PATH="${PATH//$ASDF_USER_SHIMS:/}"
# add to front of $PATH
PATH="${ASDF_BIN}:$PATH"
PATH="${ASDF_USER_SHIMS}:$PATH"

# Add function wrapper so we can export variables
asdf() {
  local command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
    "shell")
      # eval commands that need to export variables
      eval "$(asdf "sh-$command" "$@")";;
    *)
      # forward other commands to asdf script
      command asdf "$command" "$@";;

  esac
}

if [ -n "$ZSH_VERSION" ]; then
  autoload -U bashcompinit
  bashcompinit
fi

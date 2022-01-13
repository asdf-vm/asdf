# For Korn shells (ksh, mksh, etc.), capture $_ (the final parameter passed to
# the last command) straightaway, as it will contain the path to this script.
# For Bash, ${BASH_SOURCE[0]} will be used to obtain this script's path.
# For Zsh and others, $0 (the path to the shell or script) will be used.
_under="$_"
if [ -z "${ASDF_DIR:-}" ]; then
  if [ -n "${BASH_SOURCE[0]}" ]; then
    current_script_path="${BASH_SOURCE[0]}"
  elif [[ "$_under" == *".sh" ]]; then
    current_script_path="$_under"
  else
    current_script_path="$0"
  fi

  ASDF_DIR="$(dirname "$current_script_path")"
fi
export ASDF_DIR
# shellcheck disable=SC2016
[ -d "$ASDF_DIR" ] || printf "%s\n" "$ASDF_DIR is not a directory"

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

# shellcheck source=lib/asdf.sh
# Load the asdf wrapper function
. "${ASDF_DIR}/lib/asdf.sh"

unset _under current_script_path ASDF_BIN ASDF_USER_SHIMS

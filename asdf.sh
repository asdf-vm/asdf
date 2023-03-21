# shellcheck shell=sh
# shellcheck disable=SC1007

# This file is the entrypoint for all POSIX-compatible shells. If `ASDF_DIR` is
# not already set, this script is able to calculate it, but only if the shell is
# either Bash, Zsh, and Ksh. For other shells, `ASDF_DIR` must be manually set.

export ASDF_DIR="${ASDF_DIR:-}"

if [ -z "$ASDF_DIR" ]; then
  if [ -n "$BASH_VERSION" ]; then
    # Use BASH_SOURCE[0] to obtain the relative path to this source'd file. Since it's
    # a relative path, 'cd' to its dirname and use '$PWD" to obtain the fullpath.
    # Use 'builtin cd' to ensure user-defined 'cd()' functions aren't called.
    # Use variable '_asdf_old_dir' to avoid using subshells.

    _asdf_old_dir=$PWD
    # shellcheck disable=SC3028,SC3054
    if ! CDPATH= builtin cd -- "${BASH_SOURCE[0]%/*}"; then
      printf '%s\n' 'asdf: Error: Failed to cd' >&2
      unset -v _asdf_old_dir
      return 1
    fi
    ASDF_DIR=$PWD
    if ! CDPATH= builtin cd -- "$_asdf_old_dir"; then
      printf '%s\n' 'asdf: Error: Failed to cd' >&2
      unset -v _asdf_old_dir
      return 1
    fi
    unset -v _asdf_old_dir
  elif [ -n "$ZSH_VERSION" ]; then
    # Use '%x' to expand to path of current file. It must be prefixed
    # with '(%):-', so it expands in non-prompt-string contexts.

    # shellcheck disable=SC2296
    ASDF_DIR=${(%):-%x}
    ASDF_DIR=${ASDF_DIR%/*}
  elif [ -n "$KSH_VERSION" ] && [ -z "$PATHSEP" ]; then
    # Only the original KornShell (kornshell.com) has a '.sh.file' variable with the path
    # of the current file. To prevent errors with other variations, such as the MirBSD
    # Korn shell (mksh), test for 'PATHSEP' which is _not_ set on the original Korn Shell.

    # shellcheck disable=SC2296
    ASDF_DIR=${.sh.file}
    ASDF_DIR=${ASDF_DIR%/*}
  fi
fi

if [ -z "$ASDF_DIR" ]; then
  printf "%s\n" "asdf: Error: Source directory could not be calculated. Please set it manually before sourcing this file." >&2
  return 1
fi

if [ ! -d "$ASDF_DIR" ]; then
  printf "%s\n" "asdf: Error: Variable '\$ASDF_DIR' is not a directory: $ASDF_DIR" >&2
  return 1
fi

_asdf_bin="${ASDF_DIR}/bin"
_asdf_shims="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"

# shellcheck disable=SC3060
if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
  case ":$PATH:" in
    *":${_asdf_bin}:"*) PATH="${PATH//$_asdf_bin:/}" ;;
  esac
  case ":$PATH:" in
    *":${_asdf_shims}:"*) PATH="${PATH//$_asdf_shims:/}" ;;
  esac
fi

PATH="${_asdf_bin}:${_asdf_shims}:$PATH"
unset -v _asdf_bin _asdf_shims

# shellcheck source=lib/asdf.sh
. "${ASDF_DIR}/lib/asdf.sh"


#!/usr/bin/env bash

if [ "${BASH_SOURCE[0]}" != "" ]; then
  current_script_path="${BASH_SOURCE[0]}"
else
  current_script_path="$0"
fi

# shellcheck disable=SC2155,SC2164
export ASDF_DIR="$(cd "$(dirname "$current_script_path")" &> /dev/null; pwd)"
export PATH="${ASDF_DIR}/bin:${ASDF_DIR}/shims:$PATH"

if [ -n "$ZSH_VERSION" ]; then
  autoload -U bashcompinit
  bashcompinit
fi

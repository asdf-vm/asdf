#!/usr/bin/env bash

if [ "${BASH_SOURCE[0]}" != "" ]; then
  current_script_path="${BASH_SOURCE[0]}"
else
  current_script_path="$0"
fi

export ASDF_DIR
ASDF_DIR="$(cd "$(dirname "$current_script_path")" &> /dev/null || exit 1; pwd)"

if [ -n "$BASH_VERSION" ]; then
# remove osx bash session logging output if exists
ASDF_DIR=${ASDF_DIR//[[:space:]]*Saving[[:alpha:][:blank:]]*completed./}
fi

export PATH="${ASDF_DIR}/bin:${ASDF_DIR}/shims:$PATH"

if [ -n "$ZSH_VERSION" ]; then
  autoload -U bashcompinit
  bashcompinit
fi

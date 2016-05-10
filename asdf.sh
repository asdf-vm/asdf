#!/usr/bin/env bash

if [ "${BASH_SOURCE[0]}" != "" ]; then
  current_script_path=${BASH_SOURCE[0]}
else
  current_script_path=$0
fi

asdf_dir=$(cd $(dirname $current_script_path) > /dev/null; echo $(pwd))
export PATH="${asdf_dir}/bin:${asdf_dir}/shims:$PATH"

if [ -n "$ZSH_VERSION" ]; then
  fpath=(${asdf_dir}/completions $fpath)
  autoload -U compinit
  compinit
fi

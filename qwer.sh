#!/usr/bin/env bash

if [ "${BASH_SOURCE[0]}" != "" ]; then
  current_script_path=${BASH_SOURCE[0]}
else
  current_script_path=$0
fi

qwer_dir=$(cd $(dirname $current_script_path); echo $(pwd))
export PATH="${qwer_dir}/bin:${qwer_dir}/shims:$PATH"

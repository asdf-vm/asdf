#!/usr/bin/env sh

#TODO check for ${BASH_SOURCE[0]} or use $0

current_script_path=${BASH_SOURCE[0]}
asdf_dir=$(cd $(dirname $current_script_path); echo $(pwd))
export PATH="${asdf_dir}/bin:${asdf_dir}/shims:$PATH"

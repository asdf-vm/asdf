#!/usr/bin/env bash

current_script_path=${BASH_SOURCE[0]}
asdf_dir=$(cd $(dirname $current_script_path); echo $(pwd))
export PATH="${asdf_dir}/bin:${asdf_dir}/shims:$PATH"

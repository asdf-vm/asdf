#!/usr/bin/env fish

set -l asdf_dir (dirname (status -f))

# we get an ugly warning when setting the path if shims does not exist
mkdir -p $asdf_dir/shims

set -xg PATH $asdf_dir/bin $asdf_dir/shims $PATH

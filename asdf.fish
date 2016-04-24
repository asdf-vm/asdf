#!/usr/bin/env fish

# Find the asdf directory.
set asdf_dir (dirname (status --current-filename))

# Prepend the bin and shims to Fish's user paths.
set -U fish_user_paths $asdf_dir/bin $asdf_dir/shims $fish_user_paths

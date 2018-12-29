#!/usr/bin/env fish

set -l asdf_dir (dirname (status -f))
set -l asdf_data_dir (
  if test -n "$ASDF_DATA_DIR"; echo $ASDF_DATA_DIR;
  else; echo $HOME/.asdf; end)

# Add asdf to PATH
set -l asdf_bin_dirs $asdf_dir/bin $asdf_dir/shims $asdf_data_dir/shims

for x in $asdf_bin_dirs
  if begin not contains $x $PATH; and test -d $x; end
    set -gx fish_user_paths $fish_user_paths $x
  end
end

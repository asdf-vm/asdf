#!/usr/bin/env fish

set -x ASDF_DIR (dirname (status -f))
set -l asdf_data_dir (
  if test -n "$ASDF_DATA_DIR"; echo $ASDF_DATA_DIR;
  else; echo $HOME/.asdf; end)

# Add asdf to PATH
set -l asdf_bin_dirs $ASDF_DIR/bin $ASDF_DIR/shims $asdf_data_dir/shims

for x in $asdf_bin_dirs
  if begin not contains $x $fish_user_paths; and test -d $x; end
    set -gx fish_user_paths $fish_user_paths $x
  end
end

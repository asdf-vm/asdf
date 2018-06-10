#!/usr/bin/env fish

set -l asdf_data_dir (dirname (status -f))

# we get an ugly warning when setting the path if shims does not exist
mkdir -p $asdf_data_dir/shims

for x in $asdf_data_dir/{bin,shims}
  if not contains $x $PATH
  and test -d $x
    set -gx PATH $x $PATH
  end
end

set -x ASDF_DIR (dirname (status -f))
set -l asdf_data_dir (
  if test -n "$ASDF_DATA_DIR"; echo $ASDF_DATA_DIR;
  else; echo $HOME/.asdf; end)

# Add asdf to PATH
set -l asdf_bin_dirs $ASDF_DIR/bin $ASDF_DIR/shims $asdf_data_dir/shims

for x in $asdf_bin_dirs
  if test -d $x
    for i in (seq 1 (count $PATH))
      if test $PATH[$i] = $x
        set -e PATH[$i]
        break
      end
    end
  end
  set PATH $x $PATH
end

# Load the asdf wrapper function
source $ASDF_DIR/lib/asdf.fish

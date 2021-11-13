set -x ASDF_DIR (dirname (status -f))

set -l asdf_user_shims (
  if test -n "$ASDF_DATA_DIR"
    printf "%s\n" "$ASDF_DATA_DIR/shims"
  else
    printf "%s\n" "$HOME/.asdf/shims"
  end
)

# Add asdf to PATH
set -l asdf_bin_dirs $ASDF_DIR/bin $asdf_user_shims

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
. $ASDF_DIR/lib/asdf.fish

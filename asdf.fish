if not set -q ASDF_DIR
  set -x ASDF_DIR (dirname (status -f))
end

# Add asdf to PATH
# fish_add_path was added in fish 3.2, so we need a fallback for older version
if type -q fish_add_path
  if test -n "$ASDF_DATA_DIR"
    fish_add_path --global --move "$ASDF_DATA_DIR/shims" "$ASDF_DIR/bin"
  else
    fish_add_path --global --move "$HOME/.asdf/shims" "$ASDF_DIR/bin"
  end
else
  set -l asdf_user_shims (
    if test -n "$ASDF_DATA_DIR"
      printf "%s\n" "$ASDF_DATA_DIR/shims"
    else
      printf "%s\n" "$HOME/.asdf/shims"
    end
  )

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
end

# Load the asdf wrapper function
. $ASDF_DIR/lib/asdf.fish

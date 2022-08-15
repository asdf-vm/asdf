if not set -q ASDF_DIR
  set -x ASDF_DIR (dirname (status -f))
end

fish_add_path --global --move $ASDF_DIR/bin

if test -n "$ASDF_DATA_DIR"
  fish_add_path --global --move "$ASDF_DATA_DIR/shims"
else
  fish_add_path --global --move "$HOME/.asdf/shims"
end

# Load the asdf wrapper function
. $ASDF_DIR/lib/asdf.fish

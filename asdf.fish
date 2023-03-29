if test -z $ASDF_DIR
    set ASDF_DIR (realpath (dirname (status filename)))
end
set --export ASDF_DIR $ASDF_DIR

set -l _asdf_bin "$ASDF_DIR/bin"
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in fish_user_paths
if not contains $_asdf_bin $fish_user_paths
    set --global --prepend fish_user_paths $_asdf_bin
end
if not contains $_asdf_shims $fish_user_paths
    set --global --prepend fish_user_paths $_asdf_shims
end
set --erase _asdf_bin _asdf_shims

# Load the asdf wrapper function
. $ASDF_DIR/lib/asdf.fish

if test -z $ASDF_DIR
    set ASDF_DIR (builtin realpath --no-symlinks (dirname (status filename)))
end
set --export ASDF_DIR $ASDF_DIR

set -l _asdf_bin "$ASDF_DIR/bin"
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_bin $PATH
    set -gx --prepend PATH $_asdf_bin
end
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_bin
set --erase _asdf_shims

# The asdf function is a wrapper so we can export variables
function asdf
    set command $argv[1]
    set -e argv[1]

    switch "$command"
        case shell
            # Source commands that need to export variables.
            command asdf export-shell-version fish $argv | source # asdf_allow: source
        case '*'
            # Forward other commands to asdf script.
            command asdf "$command" $argv
    end
end

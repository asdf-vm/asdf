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

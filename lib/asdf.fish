
# Add function wrapper so we can export variables
function asdf
    set command $argv[1]
    set -e argv[1]

    switch "$command"
        case "shell"
            # source commands that need to export variables
            source (asdf export-shell-version fish $argv | psub)
        case '*'
            # forward other commands to asdf script
            command asdf "$command" $argv
    end
end

function __fish_asdf_needs_command
    set -l cmd (commandline -opc)
    if test (count $cmd) -eq 1
        return 0
    end
    return 1
end

function __fish_asdf_using_command -a current_command
    set -l cmd (commandline -opc)
    if test (count $cmd) -gt 1
        if test $current_command = $cmd[2]
            return 0
        end
    end
    return 1
end

function __fish_asdf_arg_number -a number
    set -l cmd (commandline -opc)
	test (count $cmd) -eq $number
end

function __fish_asdf_arg_at -a number
    set -l cmd (commandline -opc)
	echo $cmd[$number]
end

set -l official_plugins ruby erlang nodejs elixir


# plugin-add completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a plugin-add -d "Add git repo as plugin"
complete -f -c asdf -n '__fish_asdf_using_command plugin-add; and __fish_asdf_arg_number 2' -a (echo $official_plugins)
complete -f -c asdf -n '__fish_asdf_using_command plugin-add; and __fish_asdf_arg_number 3' -a '(echo https://github.com/asdf-vm/asdf-(__fish_asdf_arg_at 3).git)'

# plugin-list completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a plugin-list -d "List installed plugins"

# plugin-remove completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a plugin-remove -d "Remove plugin and package versions"
complete -f -c asdf -n '__fish_asdf_using_command plugin-remove; and __fish_asdf_arg_number 2' -a '(asdf plugin-list)' -A

# plugin-update completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a plugin-update -d "Update plugin"
complete -f -c asdf -n '__fish_asdf_using_command plugin-update; and __fish_asdf_arg_number 2' -a '(asdf plugin-list)' -A
complete -f -c asdf -n '__fish_asdf_using_command plugin-update; and __fish_asdf_arg_number 2' -a --all -A

# install completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a install -d "Install a specific version of a package"
complete -f -c asdf -n '__fish_asdf_using_command install; and __fish_asdf_arg_number 2' -a '(asdf plugin-list)'
complete -f -c asdf -n '__fish_asdf_using_command install; and __fish_asdf_arg_number 3' -a '(asdf list-all (__fish_asdf_arg_at 3))'

# uninstall completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a uninstall -d "Remove a specific version of a package"
complete -f -c asdf -n '__fish_asdf_using_command uninstall; and __fish_asdf_arg_number 2' -a '(asdf plugin-list)'
complete -f -c asdf -n '__fish_asdf_using_command uninstall; and __fish_asdf_arg_number 3' -a '(asdf list (__fish_asdf_arg_at 3))'

# which completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a which -d "Display version set or being used for package"
complete -f -c asdf -n '__fish_asdf_using_command which; and __fish_asdf_arg_number 2' -a '(asdf plugin-list)'

# where completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a where -d "Display install path for an installed version"
complete -f -c asdf -n '__fish_asdf_using_command where; and __fish_asdf_arg_number 2' -a '(asdf plugin-list)'
complete -f -c asdf -n '__fish_asdf_using_command where; and __fish_asdf_arg_number 3' -a '(asdf list (__fish_asdf_arg_at 3))'

# list completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a list -d "List installed versions of a package"
complete -f -c asdf -n '__fish_asdf_using_command list; and __fish_asdf_arg_number 2' -a '(asdf plugin-list)'

# list-all completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a list-all -d "List all versions of a package"
complete -f -c asdf -n '__fish_asdf_using_command list-all; and __fish_asdf_arg_number 2' -a '(asdf plugin-list)'

# reshim completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a reshim -d "Recreate shims for version of a package"
complete -f -c asdf -n '__fish_asdf_using_command reshim; and __fish_asdf_arg_number 2' -a '(asdf plugin-list)'
complete -f -c asdf -n '__fish_asdf_using_command reshim; and __fish_asdf_arg_number 3' -a '(asdf list (__fish_asdf_arg_at 3))'

# local completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a local -d "Set local version for a plugin"
complete -f -c asdf -n '__fish_asdf_using_command local; and __fish_asdf_arg_number 2' -a '(asdf plugin-list)'
complete -f -c asdf -n '__fish_asdf_using_command local; and test (count (commandline -opc)) -gt 2' -a '(asdf list (__fish_asdf_arg_at 3))'

# global completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a global -d "Set global version for a plugin"
complete -f -c asdf -n '__fish_asdf_using_command global; and __fish_asdf_arg_number 2' -a '(asdf plugin-list)'
complete -f -c asdf -n '__fish_asdf_using_command global; and test (count (commandline -opc)) -gt 2' -a '(asdf list (__fish_asdf_arg_at 3))'

# misc
complete -f -c asdf -n '__fish_asdf_needs_command' -l "help" -d "Displays help"
complete -f -c asdf -n '__fish_asdf_needs_command' -l "version" -d "Displays asdf version"

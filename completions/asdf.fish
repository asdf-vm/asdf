set -x asdf_data_dir (
  if test -n "$ASDF_DATA_DIR"; echo $ASDF_DATA_DIR;
  else; echo $HOME/.asdf; end)

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

function __fish_asdf_list_versions -a plugin
    asdf list $plugin 2> /dev/null | sed -e 's/^\s*//'
end

function __fish_asdf_list_all -a plugin
    asdf list-all $plugin 2> /dev/null
end

function __fish_asdf_plugin_list
    asdf plugin-list 2> /dev/null
end

function __fish_asdf_plugin_list_all
    asdf plugin-list-all 2> /dev/null
end

function __fish_asdf_list_shims
    ls $asdf_data_dir/shims
end

# update
complete -f -c asdf -n '__fish_asdf_needs_command' -a update -d "Update asdf"
complete -f -c asdf -n '__fish_asdf_using_command update; and __fish_asdf_arg_number 2' -l "head" -d "Updates to master HEAD"

# plugin-add completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a plugin-add -d "Add git repo as plugin"
complete -f -c asdf -n '__fish_asdf_using_command plugin-add; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list_all | grep -v \'*\' | awk \'{ print $1 }\')'
complete -f -c asdf -n '__fish_asdf_using_command plugin-add; and __fish_asdf_arg_number 3' -a '(__fish_asdf_plugin_list_all | grep (__fish_asdf_arg_at 3) | awk \'{ print $2 }\')'
complete -f -c asdf -n '__fish_asdf_using_command plugin-add; and __fish_asdf_arg_number 4'

# plugin-list completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a plugin-list -d "List installed plugins"

# plugin-list-all completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a plugin-list-all -d "List all existing plugins"

# plugin-remove completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a plugin-remove -d "Remove plugin and package versions"
complete -f -c asdf -n '__fish_asdf_using_command plugin-remove; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'

# plugin-update completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a plugin-update -d "Update plugin"
complete -f -c asdf -n '__fish_asdf_using_command plugin-update; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command plugin-update; and __fish_asdf_arg_number 2' -a --all

# install completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a install -d "Install a specific version of a package"
complete -f -c asdf -n '__fish_asdf_using_command install; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command install; and __fish_asdf_arg_number 3' -a '(__fish_asdf_list_all (__fish_asdf_arg_at 3))'

# uninstall completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a uninstall -d "Remove a specific version of a package"
complete -f -c asdf -n '__fish_asdf_using_command uninstall; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command uninstall; and __fish_asdf_arg_number 3' -a '(__fish_asdf_list_versions (__fish_asdf_arg_at 3))'

# current completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a current -d "Display version set or being used for package"
complete -f -c asdf -n '__fish_asdf_using_command current; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'

# where completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a where -d "Display install path for an installed version"
complete -f -c asdf -n '__fish_asdf_using_command where; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command where; and __fish_asdf_arg_number 3' -a '(__fish_asdf_list_versions (__fish_asdf_arg_at 3))'

# which completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a which -d "Display executable path for a command"
complete -f -c asdf -n '__fish_asdf_using_command which; and __fish_asdf_arg_number 2' -a '(__fish_asdf_list_shims)'

# list completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a list -d "List installed versions of a package"
complete -f -c asdf -n '__fish_asdf_using_command list; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'

# list-all completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a list-all -d "List all versions of a package"
complete -f -c asdf -n '__fish_asdf_using_command list-all; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'

# reshim completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a reshim -d "Recreate shims for version of a package"
complete -f -c asdf -n '__fish_asdf_using_command reshim; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command reshim; and __fish_asdf_arg_number 3' -a '(__fish_asdf_list_versions (__fish_asdf_arg_at 3))'

# local completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a local -d "Set local version for a plugin"
complete -f -c asdf -n '__fish_asdf_using_command local; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command local; and test (count (commandline -opc)) -gt 2' -a '(__fish_asdf_list_versions (__fish_asdf_arg_at 3)) system'

# global completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a global -d "Set global version for a plugin"
complete -f -c asdf -n '__fish_asdf_using_command global; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command global; and test (count (commandline -opc)) -gt 2' -a '(__fish_asdf_list_versions (__fish_asdf_arg_at 3)) system'

# shell completion
complete -f -c asdf -n '__fish_asdf_needs_command' -a shell -d "Set version for a plugin in current shell session"
complete -f -c asdf -n '__fish_asdf_using_command shell; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command shell; and test (count (commandline -opc)) -gt 2' -a '(__fish_asdf_list_versions (__fish_asdf_arg_at 3)) system'

# misc
complete -f -c asdf -n '__fish_asdf_needs_command' -l "help" -d "Displays help"
complete -f -c asdf -n '__fish_asdf_needs_command' -l "version" -d "Displays asdf version"

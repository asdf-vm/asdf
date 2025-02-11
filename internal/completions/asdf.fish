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
    asdf list $plugin 2>/dev/null | string trim | string trim --left --chars '*'
end

function __fish_asdf_list_all -a plugin
    asdf list all $plugin 2>/dev/null
end

function __fish_asdf_plugin_list
    asdf plugin list 2>/dev/null
end

function __fish_asdf_plugin_list_all
    asdf plugin list all 2>/dev/null
end

function __fish_asdf_list_shims
    path basename $asdf_data_dir/shims/*
end

# plugin completion
complete -f -c asdf -n __fish_asdf_needs_command -a plugin -d "Plugin management sub-commands"
# suggest `add` after `plugin`
complete -f -c asdf -n '__fish_asdf_using_command plugin; and __fish_asdf_arg_number 2' -a add -d "Add git repo as plugin"
# show available plugins after `plugin add`
complete -f -c asdf -n '__fish_asdf_using_command plugin; and __fish_asdf_arg_at 2 = "add"; and __fish_asdf_arg_number 3' -a '(__fish_asdf_plugin_list_all | grep -v \'*\' | awk \'{ print $1 }\')'
# show repository urls for selected plugin
complete -f -c asdf -n '__fish_asdf_using_command plugin; and __fish_asdf_arg_at 2 = "add"; and __fish_asdf_arg_number 4' -a '(__fish_asdf_plugin_list_all | grep (__fish_asdf_arg_at 3) | awk \'{ print $2 }\')'

# plugin list completion
complete -f -c asdf -n '__fish_asdf_using_command plugin; and __fish_asdf_arg_number 2' -a list -d "List installed plugins"
complete -f -c asdf -n '__fish_asdf_using_command plugin; and __fish_asdf_arg_at 2 = "list"; and __fish_asdf_arg_number 3' -a all -d "List all available plugins"

# plugin remove completion
# show `remove` as an option for `plugin`
complete -f -c asdf -n '__fish_asdf_using_command plugin; and __fish_asdf_arg_number 2' -a remove -d "Remove plugin and package versions"
# Show list of plugins after `remove`
complete -f -c asdf -n '__fish_asdf_using_command plugin; and __fish_asdf_arg_at 2 = "remove"; and __fish_asdf_arg_number 3' -a '(__fish_asdf_plugin_list)'

# plugin update completion
complete -f -c asdf -n '__fish_asdf_using_command plugin; and __fish_asdf_arg_number 2' -a update -d "Update plugin"
# suggest the plugin list
complete -f -c asdf -n '__fish_asdf_using_command plugin; and __fish_asdf_arg_at 2 = "update"; and __fish_asdf_arg_number 3' -a '(__fish_asdf_plugin_list)'
# suggest '--all'
complete -f -c asdf -n '__fish_asdf_using_command plugin; and __fish_asdf_arg_at 2 = "update"; and __fish_asdf_arg_number 3' -a --all

# install completion
complete -f -c asdf -n __fish_asdf_needs_command -a install -d "Install a specific version of a package"
complete -f -c asdf -n '__fish_asdf_using_command install; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command install; and __fish_asdf_arg_number 3' -a '(__fish_asdf_list_all (__fish_asdf_arg_at 3))'

# uninstall completion
complete -f -c asdf -n __fish_asdf_needs_command -a uninstall -d "Remove a specific version of a package"
complete -f -c asdf -n '__fish_asdf_using_command uninstall; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command uninstall; and __fish_asdf_arg_number 3' -a '(__fish_asdf_list_versions (__fish_asdf_arg_at 3))'

# current completion
complete -f -c asdf -n __fish_asdf_needs_command -a current -d "Display version set or being used for package"
complete -f -c asdf -n '__fish_asdf_using_command current; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'

# where completion
complete -f -c asdf -n __fish_asdf_needs_command -a where -d "Display install path for an installed version"
complete -f -c asdf -n '__fish_asdf_using_command where; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command where; and __fish_asdf_arg_number 3' -a '(__fish_asdf_list_versions (__fish_asdf_arg_at 3))'

# which completion
complete -f -c asdf -n __fish_asdf_needs_command -a which -d "Display executable path for a command"
complete -f -c asdf -n '__fish_asdf_using_command which; and __fish_asdf_arg_number 2' -a '(__fish_asdf_list_shims)'

# latest completion
complete -f -c asdf -n __fish_asdf_needs_command -a latest -d "Show latest stable version of a package"
complete -f -c asdf -n '__fish_asdf_using_command latest; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command latest; and __fish_asdf_arg_number 2' -a --all

# list completion
complete -f -c asdf -n __fish_asdf_needs_command -a list -d "List installed versions of a package"
complete -f -c asdf -n '__fish_asdf_using_command list; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'

# list-all completion
complete -f -c asdf -n '__fish_asdf_using_command list; and __fish_asdf_arg_number 2' -a all -d "List all versions of a package"
complete -f -c asdf -n '__fish_asdf_using_command list; and __fish_asdf_arg_at 2 = "all"; and __fish_asdf_arg_number 3' -a '(__fish_asdf_plugin_list)'

# reshim completion
complete -f -c asdf -n __fish_asdf_needs_command -a reshim -d "Recreate shims for version of a package"
complete -f -c asdf -n '__fish_asdf_using_command reshim; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command reshim; and __fish_asdf_arg_number 3' -a '(__fish_asdf_list_versions (__fish_asdf_arg_at 3))'

# shim versions completion
complete -f -c asdf -n __fish_asdf_needs_command -a shimversions -d "List the plugins and versions that provide a command"
complete -f -c asdf -n '__fish_asdf_using_command shimversions; and __fish_asdf_arg_number 2' -a '(__fish_asdf_list_shims)'

# set completion
complete -f -c asdf -n __fish_asdf_needs_command -a set -d "Set version for a plugin"
complete -f -c asdf -n '__fish_asdf_using_command set; and __fish_asdf_arg_number 2' -a '(__fish_asdf_plugin_list)'
complete -f -c asdf -n '__fish_asdf_using_command set; and test (count (commandline -opc)) -gt 2' -a '(__fish_asdf_list_versions (__fish_asdf_arg_at 3)) system'

# set commands
complete -f -c asdf -n '__fish_asdf_using_command set' -l home -d "Set version in home directory"
complete -f -c asdf -n '__fish_asdf_using_command set' -l parent -d "Set version in parent directory"

# misc
complete -f -c asdf -n __fish_asdf_needs_command -l help -d "Displays help"
complete -f -c asdf -n __fish_asdf_needs_command -a info -d "Print OS, Shell and ASDF debug information"
complete -f -c asdf -n __fish_asdf_needs_command -l version -d "Print the currently installed version of ASDF"

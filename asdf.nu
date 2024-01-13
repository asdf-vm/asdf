def --env configure-asdf [] {
    $env.ASDF_DIR = (
      if ($env | get --ignore-errors ASDF_NU_DIR | is-empty) == false {
        $env.ASDF_NU_DIR
      }
      else if ($env | get --ignore-errors ASDF_DIR | is-empty) == false {
        $env.ASDF_DIR
      } else {
        print --stderr "asdf: Either ASDF_NU_DIR or ASDF_DIR must not be empty"
        return
      }
    )

    let shims_dir = (
      if ( $env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {
        $env.HOME | path join '.asdf'
      } else {
        $env.ASDF_DIR
      } | path join 'shims'
    )
    let asdf_bin_dir = ( $env.ASDF_DIR | path join 'bin' )

    $env.PATH = ( $env.PATH | split row (char esep) | where { |p| $p != $shims_dir } | prepend $shims_dir )
    $env.PATH = ( $env.PATH | split row (char esep) | where { |p| $p != $asdf_bin_dir } | prepend $asdf_bin_dir )
}

configure-asdf

## Completions

module asdf {

    def "complete asdf sub-commands" [] {
        [
            "plugin",
            "list",
            "install",
            "uninstall",
            "current",
            "where",
            "which",
            "local",
            "global",
            "shell",
            "latest",
            "help",
            "exec",
            "env",
            "info",
            "reshim",
            "shim-version",
            "update"
        ]
    }

    def "complete asdf installed" [] {
        ^asdf plugin list | lines | each { |line| $line | str trim }
    }


    def "complete asdf plugin sub-commands" [] {
        [
            "list",
            "list all",
            "add",
            "remove",
            "update"
        ]
    }

    def "complete asdf installed plugins" [] {
        ^asdf plugin list | lines | each { |line|
            $line | str trim
        }
    }

    # ASDF version manager
    export extern main [
        subcommand?: string@"complete asdf sub-commands"
    ]

    # Manage plugins
    export extern "asdf plugin" [
        subcommand?: string@"complete asdf plugin sub-commands"
    ]

    # List installed plugins
    export def "asdf plugin list" [
        --urls # Show urls
        --refs # Show refs
    ] {

        let params = [
            {name: 'urls', enabled: $urls, flag: '--urls',
             template: '\s+?(?P<repository>(?:http[s]?|git).+\.git|/.+)'}
            {name: 'refs', enabled: $refs, flag: '--refs',
             template: '\s+?(?P<branch>\w+)\s+(?P<ref>\w+)'}
        ]

        let template = '(?P<name>.+)' + (
                            $params |
                            where enabled |
                            get --ignore-errors template |
                            str join '' |
                            str trim
                        )

        let flags = ($params | where enabled | get --ignore-errors flag | default '' )

        ^asdf plugin list $flags | lines | parse -r $template | str trim
    }

    # list all available plugins
    export def "asdf plugin list all" [] {
        let template = '(?P<name>.+)\s+?(?P<installed>[*]?)(?P<repository>(?:git|http|https).+)'
        let is_installed = { |it| $it.installed == '*' }

        ^asdf plugin list all |
            lines |
            parse -r $template |
            str trim |
            update installed $is_installed |
            sort-by name
    }

    # Add a plugin
    export extern  "asdf plugin add" [
        name: string # Name of the plugin
        git_url?: string # Git url of the plugin
    ]

    # Remove an installed plugin and their package versions
    export extern "asdf plugin remove" [
        name: string@"complete asdf installed plugins" # Name of the plugin
    ]

    # Update a plugin
    export extern "asdf plugin update" [
        name: string@"complete asdf installed plugins" # Name of the plugin
        git_ref?: string # Git ref to update the plugin
    ]

    # Update all plugins to the latest commit
    export extern "asdf plugin update --all" []

    # install a package version
    export extern "asdf install" [
        name?: string # Name of the package
        version?: string # Version of the package or latest
    ]


    # Remove an installed package version
    export extern "asdf uninstall" [
        name: string@"complete asdf installed" # Name of the package
        version: string # Version of the package
    ]

    # Display current version
    export extern "asdf current" [
        name?: string@"complete asdf installed" # Name of installed version of a package
    ]

    # Display path of an executable
    export extern "asdf which" [
        command: string # Name of command
    ]

    # Display install path for an installled package version
    export extern "asdf where" [
        name: string@"complete asdf installed" # Name of installed package
        version?: string # Version of installed package
    ]

    # Set the package local version
    export extern "asdf local" [
        name: string@"complete asdf installed" # Name of the package
        version?: string # Version of the package or latest
    ]

    # Set the package global version
    export extern "asdf global" [
        name: string@"complete asdf installed" # Name of the package
        version?: string # Version of the package or latest
    ]

    # Set the package to version in the current shell
    export extern "asdf shell" [
        name: string@"complete asdf installed" # Name of the package
        version?: string # Version of the package or latest
    ]

    # Show latest stable version of a package
    export extern "asdf latest" [
        name: string # Name of the package
        version?: string # Filter latest stable version from this version
    ]

    # Show latest stable version for all installed packages
    export extern "asdf latest --all" []

    # List installed package versions
    export extern "asdf list" [
        name?: string@"complete asdf installed" # Name of the package
        version?: string # Filter the version
    ]

    # List all available package versions
    export def "asdf list all" [
        name: string@"complete asdf installed" # Name of the package
        version?: string="" # Filter the version
    ]    {
        ^asdf list all $name $version | lines | parse "{version}" | str trim
    }

    # Show documentation for plugin
    export extern "asdf help" [
        name: string@"complete asdf installed" # Name of the plugin
        version?: string # Version of the plugin
    ]

    # Execute a command shim for the current version
    export extern "asdf exec" [
        command: string # Name of the command
        ...args: any # Arguments to pass to the command
    ]

    # Run util (default: env) inside the environment used for command shim execution
    export extern "asdf env" [
        command?: string # Name of the command
        util?: string = 'env' # Name of util to run
    ]

    # Show information about OS, Shell and asdf Debug
    export extern "asdf info" []

    # Recreate shims for version package
    export extern "asdf reshim" [
        name?: string@"complete asdf installed" # Name of the package
        version?: string # Version of the package
    ]

    # List the plugins and versions that provide a command
    export extern "asdf shim-version" [
        command: string # Name of the command
    ]

    # Update asdf to the latest version on the stable branch
    export extern "asdf update" []

    # Update asdf to the latest version on the main branch
    export extern "asdf update --head" []

}

use asdf *

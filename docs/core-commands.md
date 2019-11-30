## Manage Plugins

| Command                                  | Effect                                                       |
| -----------------------------------------| ------------------------------------------------------------ |
| `asdf plugin add <name> [<git-url>]`     | Add a plugin from the plugin repo OR, add a Git repo         |
|                                          | ...as a plugin by specifying the name and repo url           |
| `asdf plugin list`                       | List installed plugins                                       |
| `asdf plugin list [--urls] [--refs]`     | List installed plugins. Optionally show git urls and git-ref |
| `asdf plugin list all`                   | List plugins registered on asdf-plugins repository with URLs |
| `asdf plugin remove <name>`              | Remove plugin and package versions                           |
| `asdf plugin update <name> [<git-ref>]`  | Update plugin to latest commit or a particular git ref.      |
| `asdf plugin update --all`               | Update all plugins                                           |

## Manage Packages

| Command                                  | Effect                                                                     |
| ---------------------------------------- | -------------------------------------------------------------------------- |
| `asdf install [<name> <version>]`        | Install a specific version of a package, or with no arguments,             |
|                                          | ...install all the package versions listed in the .tool-versions file      |
| `asdf install <name> latest[:<version>]` | Install the latest stable version of a package, or with optional version,  |
|                                          | ...install the latest stable version that begins with the given string     |
| `asdf uninstall <name> <version>`        | Remove a specific version of a package                                     |
| `asdf current`                           | Display current version set or being used for all packages                 |
| `asdf current <name>`                    | Display current version set or being used for package                      |
| `asdf where <name> [<version>]`          | Display install path for an installed or current version                   |
| `asdf which <name>`                      | Display install path for current version                                   |
| `asdf local <name> <version>`            | Set the package local version                                              |
| `asdf global <name> <version>`           | Set the package global version                                             |
| `asdf latest <name> [<version>]`         | Show latest stable version of a package                                    |
| `asdf list <name>`                       | List installed versions of a package                                       |
| `asdf list all <name> [<version>]`       | List all versions of a package and optionally filter the returned versions |

## Utils

| Command                        | Effect                                                |
| ------------------------------ | ----------------------------------------------------- |
| `asdf exec <command> [args]`   | Runs the currently selected version of command        |
| `asdf env <command> [util]`    | Executes util inside the environemnt used for command |
| `asdf reshim <name> <version>` | Recreate shims for version of a package               |
| `asdf shim-versions <command>` | List the plugins and versions that provide a command  |
| `asdf update`                  | Update asdf to the latest stable release              |
| `asdf update --head`           | Update asdf to the latest on the master branch        |

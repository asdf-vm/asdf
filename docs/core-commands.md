## Manage Plugins

| Command                              | Effect                                                       |
| ------------------------------------ | ------------------------------------------------------------ |
| `asdf plugin-add <name> [<git-url>]` | Add a plugin from the plugin repo OR, add a Git repo         |
|                                      | ...as a plugin by specifying the name and repo url           |
| `asdf plugin-list`                   | List installed plugins                                       |
| `asdf plugin-list --urls`            | List installed plugins with repository URLs                  |
| `asdf plugin-list-all`               | List plugins registered on asdf-plugins repository with URLs |
| `asdf plugin-remove <name>`          | Remove plugin and package versions                           |
| `asdf plugin-update <name>`          | Update plugin                                                |
| `asdf plugin-update --all`           | Update all plugins                                           |

## Manage Packages

| Command                           | Effect                                                                |
| --------------------------------- | --------------------------------------------------------------------- |
| `asdf install [<name> <version>]` | Install a specific version of a package, or with no arguments,        |
|                                   | ...install all the package versions listed in the .tool-versions file |
| `asdf uninstall <name> <version>` | Remove a specific version of a package                                |
| `asdf current`                    | Display current version set or being used for all packages            |
| `asdf current <name>`             | Display current version set or being used for package                 |
| `asdf where <name> [<version>]`   | Display install path for an installed or current version              |
| `asdf which <name>`               | Display install path for current version                              |
| `asdf local <name> <version>`     | Set the package local version                                         |
| `asdf global <name> <version>`    | Set the package global version                                        |
| `asdf list <name>`                | List installed versions of a package                                  |
| `asdf list-all <name>`            | List all versions of a package                                        |

## Utils

| Command                        | Effect                                         |
| ------------------------------ | ---------------------------------------------- |
| `asdf reshim <name> <version>` | Recreate shims for version of a package        |
| `asdf update`                  | Update asdf to the latest stable release       |
| `asdf update --head`           | Update asdf to the latest on the master branch |

# Configuration

Configuration of `asdf` encompasses both the sharable `.tool-versions` files as well as user specific customisations with `.asdfrc` and Environment Variables.

## `.tool-versions`

Whenever `.tool-versions` file is present in a directory, the tool versions it declares will be used in that directory and any subdirectories.

::: warning Note

Global defaults can be set in the file `$HOME/.tool-versions`

:::

This is what a `.tool-versions` file looks like:

```
ruby 2.5.3
nodejs 10.15.0
```

You can also include comments:

```
ruby 2.5.3 # This is a comment
# This is another comment
nodejs 10.15.0
```

The versions can be in the following format:

- `10.15.0` - an actual version. Plugins that support downloading binaries, will download binaries.
- `ref:v1.0.2-a` or `ref:39cb398vb39` - tag/commit/branch to download from github and compile
- `path:~/src/elixir` - a path to custom compiled version of a tool to use. For use by language developers and such.
- `system` - this keyword causes asdf to passthrough to the version of the tool on the system that is not managed by asdf.

::: tip

Multiple versions can be set by separating them with a space. For example, to use Python `3.7.2`, fallback to Python `2.7.15` and finally to the `system` Python, the following line can be added to `.tool-versions`.

```
python 3.7.2 2.7.15 system
```

:::

To install all the tools defined in a `.tool-versions` file run `asdf install` with no other arguments in the directory containing the `.tool-versions` file.

To install a single tool defined in a `.tool-versions` file run `asdf install <name>` in the directory containing the `.tool-versions` file. The tool will be installed at the version specified in the `.tool-versions` file.

Edit the file directly or use `asdf local` (or `asdf global`) which updates it.

## `.asdfrc`

The `.asdfrc` file defines the user's machine specific configuration.

`${HOME}/.asdfrc` is the default location used by asdf. This can be set with the [Environment Variable `ASDF_CONFIG_FILE`](#asdfconfigfile).

The below file shows the required format with the default values:

```txt
legacy_version_file = no
use_release_candidates = no
always_keep_download = no
plugin_repository_last_check_duration = 60
disable_plugin_short_name_repository = no
concurrency = auto
```

### `legacy_version_file`

Plugins **with support** can read the versions files used by other version managers, for example, `.ruby-version` in the case of Ruby's `rbenv`.

| Options                                                    | Description                                                                |
| :--------------------------------------------------------- | :------------------------------------------------------------------------- |
| `no` <Badge type="tip" text="default" vertical="middle" /> | Use `.tool-versions` to read versions                                      |
| `yes`                                                      | Use plugin fallback to legacy version files (`.ruby-version`) if available |

### `use_release_candidates`

Configure the `asdf update` command to upgrade to the latest Release Candidate instead of the latest Semantic Version.

| Options                                                    | Description               |
| :--------------------------------------------------------- | :------------------------ |
| `no` <Badge type="tip" text="default" vertical="middle" /> | Semantic Version is used  |
| `yes`                                                      | Release Candidate is used |

### `always_keep_download`

Configure the `asdf install` command to keep or delete the source code or binary it downloads.

| Options                                                    | Description                                           |
| :--------------------------------------------------------- | :---------------------------------------------------- |
| `no` <Badge type="tip" text="default" vertical="middle" /> | Delete source code or binary after successful install |
| `yes`                                                      | Keep source code or binary after install              |

### `plugin_repository_last_check_duration`

Configure the duration (in minutes) between asdf plugin repository syncs. Trigger events result in a check of the duration. If more time has elapsed since the last sync than specified in the duration, a new sync occurs.

| Options                                                                                                 | Description                                                  |
| :------------------------------------------------------------------------------------------------------ | :----------------------------------------------------------- |
| integer in range `1` to `999999999` <br/> `60` is <Badge type="tip" text="default" vertical="middle" /> | Sync on trigger event if duration (in minutes) since last sync has been exceeded |
| `0`                                                                                                     | Sync on each trigger event                                   |
| `never`                                                                                                 | Never sync                                                   |

Sync events occur when the following commands are executed:

- `asdf plugin add <name>`
- `asdf plugin list all`

`asdf plugin add <name> <git-url>` does NOT trigger a plugin sync.

::: warning Note

Setting the value to `never` does not stop the plugin repository from being initially synced, for that behaviour see `disable_plugin_short_name_repository`.

:::

### `disable_plugin_short_name_repository`

Disable synchronization of the asdf plugin short-name repository. Sync events will exit early if the short-name repository is disabled.

| Options                                                    | Description                                               |
| :--------------------------------------------------------- | :-------------------------------------------------------- |
| `no` <Badge type="tip" text="default" vertical="middle" /> | Clone or update the asdf plugin repository on sync events |
| `yes`                                                      | Disable the plugin short-name repository                  |

Sync events occur when the following commands are executed:

- `asdf plugin add <name>`
- `asdf plugin list all`

`asdf plugin add <name> <git-url>` does NOT trigger a plugin sync.

::: warning Note

Disabling the plugin short-name repository does not remove the repository if it has already synced. Remove the plugin repo with `rm --recursive --trash $ASDF_DATA_DIR/repository`.

Disabling the plugin short-name repository does not remove plugins previously installed from this source. Plugins can be removed with `asdf plugin remove <name>`. Removing a plugin will remove all installed versions of the managed tool.

:::

### `concurrency`

The default number of cores to use during compilation.

| Options | Description                                                                                          |
| :------ | :--------------------------------------------------------------------------------------------------- |
| integer | Number of cores to use when compiling the source code                                                |
| `auto`  | Calculate the number of cores using `nproc`, then `sysctl hw.ncpu`, then `/proc/cpuinfo` or else `1` |

Note: the environment variable `ASDF_CONCURRENCY` take precedence if set.

### Plugin Hooks

It is possible to execute custom code:

- Before or after a plugin is installed, reshimed, updated, or uninstalled
- Before or after a plugin command is executed

For example, if a plugin called `foo` is installed and provides a `bar` executable, then the following hooks can be used to execute custom code first:

```text
pre_foo_bar = echo Executing with args: $@
```

The following patterns are supported:

- `pre_<plugin_name>_<command>`
- `pre_asdf_download_<plugin_name>`
- `{pre,post}_asdf_{install,reshim,uninstall}_<plugin_name>`
  - `$1`: full version
- `{pre,post}_asdf_plugin_{add,update,remove,reshim}`
  - `$1`: plugin name
- `{pre,post}_asdf_plugin_{add,update,remove}_<plugin_name>`

See [Create a Plugin](../plugins/create.md) for specifics on what command hooks are ran before or after what commands.

## Environment Variables

Setting environment variables varies depending on your system and Shell. Default locations depend upon your installation location and method (Git clone, Homebrew, AUR).

Environment variables should generally be set before sourcing `asdf.sh`/`asdf.fish` etc. For Elvish set above `use asdf`.

The following describe usage with a Bash Shell.

### `ASDF_CONFIG_FILE`

Path to the `.asdfrc` configuration file. Can be set to any location. Must be an absolute path.

- If Unset: `$HOME/.asdfrc` will be used.
- Usage: `export ASDF_CONFIG_FILE=/home/john_doe/.config/asdf/.asdfrc`

### `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME`

The filename of the file storing the tool names and versions. Can be any valid filename. Typically, you should not set this value unless you want to ignore `.tool-versions` files.

- If Unset: `.tool-versions` will be used.
- Usage: `export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=tool_versions`

### `ASDF_DIR`

The location of `asdf` core scripts. Can be set to any location. Must be an absolute path.

- If Unset: the parent directory of the `bin/asdf` executable is used.
- Usage: `export ASDF_DIR=/home/john_doe/.config/asdf`

### `ASDF_DATA_DIR`

The location where `asdf` will install plugins, shims and tool versions. Can be set to any location. Must be an absolute path.

- If Unset: `$HOME/.asdf` if it exists, or else the value of `ASDF_DIR`
- Usage: `export ASDF_DATA_DIR=/home/john_doe/.asdf`

### `ASDF_CONCURRENCY`

Number of cores to use when compiling the source code. If set, this value takes precedence over the asdf config `concurrency` value.

- If Unset: the asdf config `concurrency` value is used.
- Usage: `export ASDF_CONCURRENCY=32`

### `ASDF_FORCE_PREPEND`

Whether or not to prepend the `asdf` shims and path directories to the front-most (highest-priority) part of the `PATH`.

- If Unset: On macOS, defaults to `yes`; but on other systems, defaults to `no`
- If `yes`: Force `asdf` directories to the front of the `PATH`
- If set to any string _other_ than `yes`: Do _not_ force `asdf` directories to the front of the `PATH`
- Usage: `ASDF_FORCE_PREPEND=no . "<path-to-asdf-directory>/asdf.sh"`

## Full Configuration Example

Following a simple asdf setup with:

- a Bash Shell
- an installation location of `$HOME/.asdf`
- installed via Git
- NO environment variables set
- NO custom `.asdfrc` file

would result in the following outcomes:

| Configuration                         | Value            | Calculated by                                                                                                                                      |
| :------------------------------------ | :--------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| config file location                  | `$HOME/.asdfrc`  | `ASDF_CONFIG_FILE` is empty, so use `$HOME/.asdfrc`                                                                                                |
| default tool versions filename        | `.tool-versions` | `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME` is empty, so use `.tool-versions`                                                                            |
| asdf dir                              | `$HOME/.asdf`    | `ASDF_DIR` is empty, so use parent dir of `bin/asdf`                                                                                               |
| asdf data dir                         | `$HOME/.asdf`    | `ASDF_DATA_DIR` is empty so use `$HOME/.asdf` as `$HOME` exists.                                                                                   |
| concurrency                           | `auto`           | `ASDF_CONCURRENCY` is empty, so rely on `concurrency` value from the [default configuration](https://github.com/asdf-vm/asdf/blob/master/defaults) |
| legacy_version_file                   | `no`             | No custom `.asdfrc`, so use the [default configuration](https://github.com/asdf-vm/asdf/blob/master/defaults)                                      |
| use_release_candidates                | `no`             | No custom `.asdfrc`, so use the [default configuration](https://github.com/asdf-vm/asdf/blob/master/defaults)                                      |
| always_keep_download                  | `no`             | No custom `.asdfrc`, so use the [default configuration](https://github.com/asdf-vm/asdf/blob/master/defaults)                                      |
| plugin_repository_last_check_duration | `60`             | No custom `.asdfrc`, so use the [default configuration](https://github.com/asdf-vm/asdf/blob/master/defaults)                                      |
| disable_plugin_short_name_repository  | `no`             | No custom `.asdfrc`, so use the [default configuration](https://github.com/asdf-vm/asdf/blob/master/defaults)                                      |

## Internal Configuration

Users should not worry about this section as it describes configuration internal to `asdf` useful for Package Managers and integrators.

- `$ASDF_DIR/asdf_updates_disabled`: Updates via the `asdf update` command are disabled when this file is present (content irrelevant). This is used by package managers like Pacman or Homebrew to ensure the correct update method is used for the particular installation.

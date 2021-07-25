# Configuration

Configuration of `asdf` encompasses both the sharable `.tool-versions` files as well as user specific customisations with `.asdfrc` and Environment Variables.

## `.tool-versions`

Whenever `.tool-versions` file is present in a directory, the tool versions it declares will be used in that directory and any subdirectories.

::: warning Note
Global defaults can be set in the file `$HOME/.tool-versions`
:::

This is what a `.tool-versions` file looks like:

```:no-line-numbers
ruby 2.5.3
nodejs 10.15.0
```

The versions can be in the following format:

- `10.15.0` - an actual version. Plugins that support downloading binaries, will download binaries.
- `ref:v1.0.2-a` or `ref:39cb398vb39` - tag/commit/branch to download from github and compile
- `path:/src/elixir` - a path to custom compiled version of a tool to use. For use by language developers and such.
- `system` - this keyword causes asdf to passthrough to the version of the tool on the system that is not managed by asdf.

::: tip

Multiple versions can be set by separating them with a space. For example, to use Python `3.7.2`, fallback to Python `2.7.15` and finally to the `system` Python, the following line can be added to `.tool-versions`.

```:no-line-numbers
python 3.7.2 2.7.15 system
```

:::

To install all the tools defined in a `.tool-versions` file run `asdf install` with no other arguments in the directory containing the `.tool-versions` file.

To install a single tool defined in a `.tool-versions` file run `asdf install <name>` in the directory containing the `.tool-versions` file. The tool will be installed at the version specified in the `.tool-versions` file.

Edit the file directly or use `asdf local` (or `asdf global`) which updates it.

## `$HOME/.asdfrc`

Add an `.asdfrc` file to your home directory and asdf will use the settings specified in the file. The file below shows the required format with the default values to demonstrate:

```:no-line-numbers
legacy_version_file = no
use_release_candidates = no
always_keep_download = no
plugin_repository_last_check_duration = 60
```

### `legacy_version_file`

If set to `yes`, plugins with support will read the versions files used by other version managers (e.g. `.ruby-version` in the case of Ruby's `rbenv`).

- Defaults to `no`
- Valid values: `yes` or `no`

### `use_release_candidates`

If set to `yes`, the `asdf update` command to upgrade will use the latest release candidate release instead of the latest semantic version.

- Defaults to `no`
- Valid values: `yes` or `no`

### `always_keep_download`

If set to `yes`, `asdf install` will always keep the source code or binary it downloads. If set to `no` the source code or binary downloaded by `asdf install` will be deleted after successful installation.

- Defaults to `no`
- Valid values: `yes` or `no`

### `plugin_repository_last_check_duration`

Sets the duration (in minutes) until the asdf plugins repository should be synced since previous sync. The check occurs when command `asdf plugin add <name>` or `asdf plugin list all` are executed.

- Defaults to `60`
- Valid values: `never` or a number in the range `0` to `999999999` (1902 years).


## Environment Variables

- `ASDF_CONFIG_FILE` - Defaults to `~/.asdfrc` as described above. Can be set to any location.
- `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME` - The filename of the file storing the tool names and versions. Defaults to `.tool-versions`. Can be any valid filename. Typically you should not override the default value unless you know you want asdf to ignore `.tool-versions` files.
- `ASDF_DIR` - Defaults to `~/.asdf` - Location of the `asdf` scripts. If you install `asdf` to some other directory, set this to that directory. For example, if you are installing via the AUR, you should set this to `/opt/asdf-vm`.
- `ASDF_DATA_DIR` - Defaults to `~/.asdf` - Location where `asdf` install plugins, shims and installs. Can be set to any location before sourcing `asdf.sh` or `asdf.fish` mentioned in the section above.

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

You can also include comments:

```:no-line-numbers
ruby 2.5.3 # This is a comment
# This is another comment
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

Configure the duration since the last asdf plugin repository sync to the next. Commands `asdf plugin add <name>` or `asdf plugin list all` will trigger a check of the duration, if the duration has passed then a sync occurs.

| Options                                                                                                 | Description                                                  |
| :------------------------------------------------------------------------------------------------------ | :----------------------------------------------------------- |
| integer in range `1` to `999999999` <br/> `60` is <Badge type="tip" text="default" vertical="middle" /> | Sync on trigger event if duration since last sync has passed |
| `0`                                                                                                     | Sync on each trigger event                                   |
| `never`                                                                                                 | Never sync                                                   |

## Environment Variables

- `ASDF_CONFIG_FILE` - Defaults to `~/.asdfrc` as described above. Can be set to any location.
- `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME` - The filename of the file storing the tool names and versions. Defaults to `.tool-versions`. Can be any valid filename. Typically you should not override the default value unless you know you want asdf to ignore `.tool-versions` files.
- `ASDF_DIR` - Defaults to `~/.asdf` - Location of the `asdf` scripts. If you install `asdf` to some other directory, set this to that directory. For example, if you are installing via the AUR, you should set this to `/opt/asdf-vm`.
- `ASDF_DATA_DIR` - Defaults to `~/.asdf` - Location where `asdf` install plugins, shims and installs. Can be set to any location before sourcing `asdf.sh` or `asdf.fish` mentioned in the section above. For Elvish, this can be set above `use asdf`.

## Internal Configuration

Users should not worry about this section as it describes configuration internal to `asdf` useful for Package Managers and integrators.

- `$ASDF_DIR/asdf_updates_disabled`: Updates via the `asdf update` command are disabled when this file is present (content irrelevant). This is used by Package Managers like Pacman or Homebrew to ensure the correct update method is used for the particular installation.

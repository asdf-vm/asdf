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

Add a `.asdfrc` file to your home directory and asdf will use the settings specified in the file. The file should be formatted like this:

```:no-line-numbers
legacy_version_file = yes
```

**Settings**

- `legacy_version_file` - defaults to `no`. If set to yes it will cause plugins that support this feature to read the version files used by other version managers (e.g. `.ruby-version` in the case of Ruby's `rbenv`).
- `use_release_candidates` - defaults to `no`. If set to yes it will cause the `asdf update` command to upgrade to the latest release candidate release instead of the latest semantic version.
- `always_keep_download` - defaults to `no`. If set to `yes` it will cause `asdf install` always keep the source code or binary it downloads. If set to `no` the source code or binary downloaded by `asdf install` will be deleted after successful installation.
- `plugin_repository_last_check_duration` - defaults to `60` mins (1 hrs). It will set asdf plugins repository last check duration. When `asdf plugin add <name>`, `asdf plugin list all` command be executed, it will check last update duration to update repository. If set to `0` it will update asdf plugins repository every time.

## Environment Variables

- `ASDF_CONFIG_FILE` - Defaults to `~/.asdfrc` as described above. Can be set to any location.
- `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME` - The filename of the file storing the tool names and versions. Defaults to `.tool-versions`. Can be any valid filename. Typically you should not override the default value unless you know you want asdf to ignore `.tool-versions` files.
- `ASDF_DIR` - Defaults to `~/.asdf` - Location of the `asdf` scripts. If you install `asdf` to some other directory, set this to that directory. For example, if you are installing via the AUR, you should set this to `/opt/asdf-vm`.
- `ASDF_DATA_DIR` - Defaults to `~/.asdf` - Location where `asdf` install plugins, shims and installs. Can be set to any location before sourcing `asdf.sh` or `asdf.fish` mentioned in the section above.

## Internal Configuration

Users should not worry about this section as it describes configuration internal to `asdf` useful for Package Managers and integrators.

- `$ASDF_DIR/asdf_updates_disabled`: Updates via the `asdf update` command are disabled when this file is present (content irrelevant). This is used by Package Managers like Pacman or Homebrew to ensure the correct update method is used for the particular installation.

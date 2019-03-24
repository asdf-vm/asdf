## .tool-versions

Whenever `.tool-versions` file is present in a directory, the tool versions it declares will be used in that directory and any subdirectories.

?> Global defaults can be set in the file `$HOME/.tool-versions`

This is what a `.tool-versions` file looks like:

```
ruby 2.5.3
nodejs 10.15.0
```

The versions can be in the following format:

- `10.15.0` - an actual version. Plugins that support downloading binaries, will download binaries.
- `ref:v1.0.2-a` or `ref:39cb398vb39` - tag/commit/branch to download from github and compile
- `path:/src/elixir` - a path to custom compiled version of a tool to use. For use by language developers and such.
- `system` - this keyword causes asdf to passthrough to the version of the tool on the system that is not managed by asdf.

Multiple versions can be set by separating them with a space. For example, to use
Python 3.7.2, fallback to Python 2.7.15 and finally to the system Python, the
following line can be added to `.tool-versions`.

```
python 3.7.2 2.7.15 system
```

To install all the tools defined in a `.tool-versions` file run `asdf install` with no other arguments in the directory containing the `.tool-versions` file.

Edit the file directly or use `asdf local` (or `asdf global`) which updates it.

## \$HOME/.asdfrc

Add a `.asdfrc` file to your home directory and asdf will use the settings specified in the file. The file should be formatted like this:

```
legacy_version_file = yes
```

**Settings**

- `legacy_version_file` - defaults to `no`. If set to yes it will cause plugins that support this feature to read the version files used by other version managers (e.g. `.ruby-version` in the case of Ruby's `rbenv`).
- `use_release_candidates` - defaults to `no`. If set to yes it will cause the `asdf update` command to upgrade to the latest release candidate release instead of the latest semantic version.

## Environment Variables

- `ASDF_CONFIG_FILE` - Defaults to `~/.asdfrc` as described above. Can be set to any location.
- `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME` - The name of the file storing the tool names and versions. Defaults to `.tool-versions`. Can be any valid file name.
- `ASDF_DATA_DIR` - Defaults to `~/.asdf` - Location where `asdf` install plugins, shims and installs. Can be set to any location before sourcing `asdf.sh` or `asdf.fish` mentioned in the section above.

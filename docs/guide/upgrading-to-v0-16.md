# Upgrading to 0.16.0

asdf versions 0.15.0 and older were written in Bash and distributed as a set of
Bash scripts with the `asdf` function loaded into your shell. asdf version
0.16.0 is a complete rewrite of asdf in Go. Since it is a complete rewrite
there are a [number of breaking](#breaking-changes) changes and it is now
a binary rather than a set of scripts.

## Installation

Installation of version 0.16.0 is much simpler than previous versions of asdf.
It's just three steps:

* Download the appropriate `asdf` binary for your operating system/architecture combo and place it in a directory on your `$PATH`
* Add `$ASDF_DATA_DIR/shims` to the front of your `$PATH`.
* Optionally, if you previously had a customized location for asdf data, set
`ASDF_DATA_DIR` to the directory you already had the old version installing
plugins, versions, and shims.

If your operating system's package manager already offers asdf 0.16.0 that is
probably the best method for installing it. Upgrading asdf is now only possible
via OS package managers and manual installation. There is no self-upgrade
feature.

### Upgrading Without Losing Data

You can upgrade to the latest version of asdf without losing your existing
install data. It's the same sequence of steps as above.

#### 1. Download the appropriate `asdf` binary for your operating system & architecture

Download the binary and place it in a directory on your path. I chose to place
the asdf binary in `$HOME/bin` and then added `$HOME/bin` to the front of my
`$PATH`:

```
# In .zshrc, .bashrc, etc...
export PATH="$HOME/bin:$PATH"
```

#### 2. Set `ASDF_DATA_DIR`

Run `asdf info` and copy the line containing the `ASDF_DATA_DIR` variable:

```
...
ASDF_DATA_DIR="/home/myuser/.asdf"
...
```

In your shell RC file (`.zshrc` if Zsh, `.bashrc` if Bash, etc...) add a line
to the end setting `ASDF_DATA_DIR` to that same value:

```bash
export ASDF_DATA_DIR="/home/myuser/.asdf"
```

#### 3. Add `$ASDF_DATA_DIR/shims` to the front of your `$PATH`

In your shell RC file (same file as step #2) add `$ASDF_DATA_DIR/shims` to the
front of your path:

```bash
export ASDF_DATA_DIR="/home/myuser/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"
```

### Testing


If you aren't sure if the upgrade to 0.16.0 will break things for you can you
can test by installing 0.16.0 in addition to your existing version as described
above in "Upgrading Without Losing Data". If it turns out that the upgrade to
0.16.0 breaks things for you simply remove the lines you added to your shell
RC file.

## Breaking Changes

### Hyphenated commands have been removed

asdf version 0.15.0 and earlier supported by hyphenated and non-hyphenated
versions of certain commands. With version 0.16.0 only the non-hyphenated
versions are supported. The affected commands:

* `asdf list-all` -> `asdf list all`
* `asdf plugin-add` -> `asdf plugin add`
* `asdf plugin-list` -> `asdf plugin list`
* `asdf plugin-list-all` -> `asdf plugin list all`
* `asdf plugin-update` -> `asdf plugin update`
* `asdf plugin-remove` -> `asdf plugin remove`
* `asdf plugin-test` -> `asdf plugin test`
* `asdf shim-versions` -> `asdf shimversions`

### `asdf global` and `asdf local` commands have been replaced with `asdf set`

`asdf global` and `asdf local` have been removed. The "global" and "local"
terminology was wrong and also misleading. asdf doesn't actually support
"global" versions that apply everywhere. Any version that was specified with
`asdf global` could easily be overridden by a `.tool-versions` file in your
current directory specifying a different version. This was confusing to users.
The new `asdf set` behaves the same as `asdf local` by default, but also has
flags for setting versions in the user's home directory (`--home`) and in an
existing `.tool-versions` file in one of the parent directories (`--parent`).
This new interface will hopefully convey a better understanding of how asdf
resolves versions and provide equivalent functionality.

### `asdf update` command has been removed

Updates can no longer be performed this way. Use your OS package manager or
download the latest binary manually. Additionally, the `asdf update` command
present in versions 0.15.0 and older cannot upgrade to version 0.16.0 because
the install process has changed. **You cannot upgrade to the latest Go
implementation using `asdf update`.**

### `asdf shell` command has been removed

This command actually set an environment variable in the user's current shell
session. It was able to do this because `asdf` was actually a shell function,
not an executable. The new rewrite removes all shell code from asdf, and it is
now a binary rather than a shell function, so setting environment variables
directly in the shell is no longer possible.

### `asdf current` has changed

Instead of three columns in the output, with the last being either the location
the version is set or a suggested command that could be run to set or install a
version. The third column has been split into two columns. The third column now
only indicates the source of the version if it is set (typically either version
file or environment variable) and the fourth is a boolean indicating whether
the specified version is actually installed. If it is not installed, a
suggested install command is shown.

### Plugin extension commands must now be prefixed with `cmd`

Previously plugin extension commands could be run like this:

```
asdf nodejs nodebuild --version
```

Now they must be prefixed with `cmd` to avoid causing confusion with built-in
commands:

```
asdf cmd nodejs nodebuild --version
```

### Extension commands have been redesigned

There are a number of breaking changes for plugin extension commands:

* They must be runnable by `exec` syscall. If your extension commands are shell
scripts in order to be run with `exec` they must start with a proper shebang
line.
* They can now be binaries or scripts in any language. It no
longer makes sense to require a `.bash` extension as it is misleading.
* They must have executable permission set.
* They are no longer sourced by asdf as Bash scripts when they lack executable
permission.

Additionally, only the first argument after plugin name is used to determine
the extension command to run. This means effectively there is the default
`command` extension command that asdf defaults to when no command matching the
first argument after plugin name is found. For example:

```
foo/
  lib/commands/
    command
    command-bar
    command-bat-man
```

Previously these scripts would work like this:

```
$ asdf cmd foo         # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command`
$ asdf cmd foo bar     # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bar`
$ asdf cmd foo bat man # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat-man`
```

Now:

```
$ asdf cmd foo         # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command`
$ asdf cmd foo bar     # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bar`
$ asdf cmd foo bat man # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command bat man`
```

### Executables Shims Resolve to Must Runnable by `syscall.Exec`

The most obvious example of this breaking change are scripts that lack a proper
shebang line. asdf 0.15.0 and older were implemented in Bash, so as long it was
an executable that could be executed with Bash it would run. This mean that
scripts lacking a shebang could still be run by `asdf exec`. With asdf 0.16.x
implemented in Go we now invoke executables via Go's `syscall.Exec` function,
which cannot handle scripts lacking a shebang.

In practice this isn't much of a problem. Most shell scripts DO contain a
shebang line. If a tool managed by asdf provides scripts that don't have a
shebang line one will need to be added to them.

### Custom shim templates are no longer supported

This was a rarely used feature. The only plugin maintained by the core team
that used it was the Elixir plugin, and it no longer needs it. This feature
was originally added so that shim that get evaluated by a program rather than
executed contain code that is suitable for evaluation by a particular program
(in the case of Elixir this was the `iex` shell). Upon further investigation
it seems this feature only exists because the `PATH` for executables was
sometimes improperly set to include the **shims** rather than the other
**executables** for the selected version(s).

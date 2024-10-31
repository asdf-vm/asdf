# Upgrading From Version 0.14.x to 0.15.0

asdf versions 0.14.1 and older were written in Bash and distributed as a set of
Bash scripts with the `asdf` function loaded into your shell. asdf version
0.15.0 is a complete rewrite of asdf in Go. Since it is a complete rewrite
there are a number of breaking changes and it is now distributed as a binary
rather than a set of scripts.

## Breaking Changes

### Hyphenated commands have been removed

asdf version 0.14.1 and earlier supported by hyphenated and non-hyphenated
versions of certain commands. With version 0.15.0 only the non-hyphenated
versions are supported. The affected commands:

* `asdf list-all` -> `asdf list all`
* `asdf plugin-add` -> `asdf plugin add`
* `asdf plugin-list` -> `asdf plugin list`
* `asdf plugin-list-all` -> `asdf plugin list all`
* `asdf plugin-update` -> `asdf plugin update`
* `asdf plugin-remove` -> `asdf plugin remove`

### `asdf global` and `asdf local` commands have been replaced by the `asdf set` command

`asdf global` and `asdf local` have been replaced by `asdf set`, which aims to
provide the same functionality while using terminology that is less likely to
mislead the user. TODO: Add more details here

### `asdf update` command has been removed

Updates can no longer be performed this way. Use your OS package manager or
download the latest binary manually. Additionally, the `asdf update` command
present in versions 0.14.1 and older cannot upgrade to version 0.15.0 because
the install process has changed. **You cannot upgrade to the latest Go
implementation using `asdf update`.**

### `asdf shell` command has been removed

This command actually set an environment variable in the user's current shell
session. It was able to do this because `asdf` was actually a shell function,
not an executable. The new rewrite removes all shell code from asdf, and it is
now a binary rather than a shell function, so setting environment variables
directly in the shell is no longer possible.

### Executables Shims Resolve to Must Runnable by `syscall.Exec`

The most obvious example of this breaking change are scripts that lack a proper
shebang line. asdf 0.14.1 and older were implemented in Bash, so as long it was
an executable that could be executed with Bash it would run. This mean that
scripts lacking a shebang could still be run by `asdf exec`. With asdf 0.15.x
implemented in Go we now invoke executables via Go's `syscall.Exec` function,
which cannot handle scripts lacking a shebang.

In practice this isn't much of a problem. Most shell scripts DO contain a
shebang line. If a tool managed by asdf provides scripts that don't have a
shebang line one will need to be added to them.

## Installation

Installation of version 0.15.0 is much simpler than previous versions of asdf. It's just three steps:

* Download the appropriate `asdf` binary for your operating system/architecture combo and place it in a directory on your `$PATH`
* Set `ASDF_DATA_DIR` to the directory you'd like asdf to install plugins, versions, and shims.
* Add `$ASDF_DATA_DIR/shims` to the front of your `$PATH.

If your operating system's package manager already offers asdf 0.15.0 that is
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
export PATH="$HOME/bin:$PATH"`
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

#### 3. Add `$ASDF_DATA_DIR/shims` to the front of your `$PATH

In your shell RC file (same file as step #2) add `$ASDF_DATA_DIR/shims` to the
front of your path:

```bash
export ASDF_DATA_DIR="/home/myuser/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"
```

### Testing

If you aren't sure if the upgrade to 0.15.0 will break things for you can you
can test by installing 0.15.0 in addition to your existing version as described
above in "Upgrading Without Losing Data". If it turns out that the upgrade to
0.15.0 breaks things for you simply remove the lines you added to your shell
RC file.

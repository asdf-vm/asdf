# Core

The core `asdf` command list is rather small, but can facilitate many workflows.

## Installation & Setup

Covered in the [Getting Started](/guide/getting-started.md) guide.

## Exec

```shell
asdf exec <command> [args...]
```

Executes the command shim for the current version.

<!-- TODO: expand on this with example -->

## Env

```shell
asdf env <command> [util]
```

<!-- TODO: expand on this with example -->

## Info

```shell
asdf info
```

A helper command to print the OS, Shell and `asdf` debug information. Share this when making a bug report.

## Reshim

```shell
asdf reshim <name> <version>
```

This recreates the shims for the current version of a package. By default, shims are created by plugins during installation of a tool. Some tools like the [npm CLI](https://docs.npmjs.com/cli/) allow global installation of executables, for example, installing [Yarn](https://yarnpkg.com/) via `npm install -g yarn`. Since this executable was not installed via the plugin lifecycle, no shim exists for it yet. `asdf reshim nodejs <version>` will force recalculation of shims for any new executables, like `yarn`, for `<version>` of `nodejs` .

## Shim-versions

```shell
asdf shim-versions <command>
```

Lists the plugins and versions that provide shims for a command.

As an example, [Node.js](https://nodejs.org/) ships with two executables, `node` and `npm`. When many versions of the tools are installed with [`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/) `shim-versions` can return:

```shell
➜ asdf shim-versions node
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

```shell
➜ asdf shim-versions npm
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

## Update

`asdf` has a built in command to update which relies on Git (our recommended installation method). If you installed using a different method you should follow the steps for that method:

| Method         | Latest Stable Release                                                                                                          | Latest commit on `master`        |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------ | -------------------------------- |
| asdf (via Git) | `asdf update`                                                                                                                  | `asdf update --head`             |
| Homebrew       | `brew upgrade asdf`                                                                                                            | `brew upgrade asdf --fetch-HEAD` |
| Pacman         | Download a new `PKGBUILD` & rebuild <br/> or use your preferred [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) |                                  |

## Uninstall

To uninstall `asdf` follow these steps:

::: details Bash & Git

1. In your `~/.bashrc` remove the lines that source `asdf.sh` and the completions:

```shell
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
```

2. Remove the `$HOME/.asdf` dir:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Git (macOS)

1. In your `~/.bash_profile` remove the lines that source `asdf.sh` and the completions:

```shell
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
```

2. Remove the `$HOME/.asdf` dir:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Homebrew

1. In your `~/.bashrc` remove the lines that source `asdf.sh` and the completions:

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash
```

Completions may have been [configured as per Homebrew's instructions](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) so follow their guide to find out what to remove.

2. Uninstall with your package manager:

```shell
brew uninstall asdf --force
```

3. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Homebrew (macOS)

If using **macOS Catalina or newer**, the default shell has changed to **ZSH**. If you can't find any config in your `~/.bash_profile` it may be in a `~/.zshrc` in which case please follow the ZSH instructions.

1. In your `~/.bash_profile` remove the lines that source `asdf.sh` and the completions:

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash
```

Completions may have been [configured as per Homebrew's instructions](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) so follow their guide to find out what to remove.

2. Uninstall with your package manager:

```shell
brew uninstall asdf --force
```

3. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Pacman

1. In your `~/.bashrc` remove the lines that source `asdf.sh` and the completions:

```shell
. /opt/asdf-vm/asdf.sh
```

2. Uninstall with your package manager:

```shell
pacman -Rs asdf-vm
```

3. Remove the `$HOME/.asdf` dir:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

4. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Fish & Git

1. In your `~/.config/fish/config.fish` remove the lines that source `asdf.fish`:

```shell
source ~/.asdf/asdf.fish
```

and remove completions with this command:

```shell
rm -rf ~/.config/fish/completions/asdf.fish
```

2. Remove the `$HOME/.asdf` dir:

```shell
rm -rf (string join : -- $ASDF_DATA_DIR $HOME/.asdf)
```

3. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Fish & Homebrew

1. In your `~/.config/fish/config.fish` remove the lines that source `asdf.fish`:

```shell
source "(brew --prefix asdf)"/libexec/asdf.fish
```

2. Uninstall with your package manager:

```shell
brew uninstall asdf --force
```

3. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Fish & Pacman

1. In your `~/.config/fish/config.fish` remove the lines that source `asdf.fish`:

```shell
source /opt/asdf-vm/asdf.fish
```

2. Uninstall with your package manager:

```shell
pacman -Rs asdf-vm
```

3. Remove the `$HOME/.asdf` dir:

```shell
rm -rf (string join : -- $ASDF_DATA_DIR $HOME/.asdf)
```

4. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Git

1. In your `~/.config/elvish/rc.elv` remove the lines that use the `asdf` module:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

and uninstall the `asdf` module with this command:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. Remove the `$HOME/.asdf` dir:

```shell
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

3. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Homebrew

1. In your `~/.config/elvish/rc.elv` remove the lines that use the `asdf` module:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

and uninstall the `asdf` module with this command:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. Uninstall with your package manager:

```shell
brew uninstall asdf --force
```

3. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Pacman

1. In your `~/.config/elvish/rc.elv` remove the lines that use the `asdf` module:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

and uninstall the `asdf` module with this command:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. Uninstall with your package manager:

```shell
pacman -Rs asdf-vm
```

3. Remove the `$HOME/.asdf` dir:

```shell
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

4. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details ZSH & Git

1. In your `~/.zshrc` remove the lines that source `asdf.sh` and completions:

```shell
. "$HOME/.asdf/asdf.sh"
# ...
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit
compinit
```

**OR** the ZSH Framework plugin if used.

2. Remove the `$HOME/.asdf` dir:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details ZSH & Homebrew

1. In your `~/.zshrc` remove the lines that source `asdf.sh`:

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
```

2. Uninstall with your package manager:

```shell
brew uninstall asdf --force && brew autoremove
```

3. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details ZSH & Pacman

1. In your `~/.zshrc` remove the lines that source `asdf.sh`:

```shell
. /opt/asdf-vm/asdf.sh
```

2. Uninstall with your package manager:

```shell
pacman -Rs asdf-vm
```

3. Remove the `$HOME/.asdf` dir:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

4. Run this command to remove all `asdf` config files:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

That's it! 🎉

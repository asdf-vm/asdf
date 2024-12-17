# Getting Started

`asdf` installation involves:

1. Installing dependencies
2. Downloading `asdf` core
3. Installing `asdf`
4. Installing a plugin for each tool/runtime you wish to manage
5. Installing a version of the tool/runtime
6. Setting global and project versions via `.tool-versions` config files

## 1. Install Dependencies

asdf primarily requires `git` & `curl`. Here is a _non-exhaustive_ list of commands to run for _your_ package manager (some might automatically install these tools in later steps).

| OS    | Package Manager | Command                            |
| ----- | --------------- | ---------------------------------- |
| linux | Aptitude        | `apt install curl git`             |
| linux | DNF             | `dnf install curl git`             |
| linux | Pacman          | `pacman -S curl git`               |
| linux | Zypper          | `zypper install curl git`          |
| macOS | Homebrew        | `brew install coreutils curl git`  |
| macOS | Spack           | `spack install coreutils curl git` |

::: tip Note

`sudo` may be required depending on your system configuration.

:::

## 2. Download asdf

### Official Download

<!-- x-release-please-start-version -->


```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1

```

<!-- x-release-please-end -->

### Community Supported Download Methods

We highly recommend using the official `git` method.

| Method   | Command                                                                                                                                                             |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Homebrew | `brew install asdf`                                                                                                                                                 |
| Pacman   | `git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si` or use your preferred [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) |

## 3. Install asdf

There are many different combinations of Shells, OSs & Installation methods all of which affect the configuration here. Expand the selection below that best matches your system.

**macOS users, be sure to read the warning about `path_helper` at the end of this section.**

::: details Bash & Git

Add the following to `~/.bashrc`:

```shell
. "$HOME/.asdf/asdf.sh"
```

Completions must be configured by adding the following to your `.bashrc`:

```shell
. "$HOME/.asdf/completions/asdf.bash"
```

:::

::: details Bash & Git (macOS)

If using **macOS Catalina or newer**, the default shell has changed to **ZSH**. Unless changing back to Bash, follow the ZSH instructions.

Add the following to `~/.bash_profile`:

```shell
. "$HOME/.asdf/asdf.sh"
```

Completions must be configured manually with the following entry in your `.bash_profile`:

```shell
. "$HOME/.asdf/completions/asdf.bash"
```

:::

::: details Bash & Homebrew

Add `asdf.sh` to your `~/.bashrc` with:

```shell
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.bashrc
```

Completions will need to be [configured as per Homebrew's instructions](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) or with the following:

```shell
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bashrc
```

:::

::: details Bash & Homebrew (macOS)

If using **macOS Catalina or newer**, the default shell has changed to **ZSH**. Unless changing back to Bash, follow the ZSH instructions.

Add `asdf.sh` to your `~/.bash_profile` with:

```shell
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.bash_profile
```

Completions will need to be [configured as per Homebrew's instructions](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) or with the following:

```shell
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bash_profile
```

:::

::: details Bash & Pacman

Add the following to `~/.bashrc`:

```shell
. /opt/asdf-vm/asdf.sh
```

[`bash-completion`](https://wiki.archlinux.org/title/bash#Common_programs_and_options) needs to be installed for the completions to work.
:::

::: details Fish & Git

Add the following to `~/.config/fish/config.fish`:

```shell
source ~/.asdf/asdf.fish
```

Completions must be configured manually with the following command:

```shell
mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

:::

::: details Fish & Homebrew

Add `asdf.fish` to your `~/.config/fish/config.fish` with:

```shell
echo -e "\nsource "(brew --prefix asdf)"/libexec/asdf.fish" >> ~/.config/fish/config.fish
```

Completions are [handled by Homebrew for the Fish shell](https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish). Friendly!
:::

::: details Fish & Pacman

Add the following to `~/.config/fish/config.fish`:

```shell
source /opt/asdf-vm/asdf.fish
```

Completions are automatically configured on installation by the AUR package.
:::

::: details Elvish & Git

Add `asdf.elv` to your `~/.config/elvish/rc.elv` with:

```shell
mkdir -p ~/.config/elvish/lib; ln -s ~/.asdf/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

Completions are automatically configured.

:::

::: details Elvish & Homebrew

Add `asdf.elv` to your `~/.config/elvish/rc.elv` with:

```shell
mkdir -p ~/.config/elvish/lib; ln -s (brew --prefix asdf)/libexec/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

Completions are automatically configured.
:::

::: details Elvish & Pacman

Add `asdf.elv` to your `~/.config/elvish/rc.elv` with:

```shell
mkdir -p ~/.config/elvish/lib; ln -s /opt/asdf-vm/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

Completions are automatically configured.
:::

::: details ZSH & Git

Add the following to `~/.zshrc`:

```shell
. "$HOME/.asdf/asdf.sh"
```

**OR** use a ZSH Framework plugin like [asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) which will source this script and setup completions.

Completions are configured by either a ZSH Framework `asdf` plugin or by adding the following to your `.zshrc`:

```shell
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
```

- if you are using a custom `compinit` setup, ensure `compinit` is below your sourcing of `asdf.sh`
- if you are using a custom `compinit` setup with a ZSH Framework, ensure `compinit` is below your sourcing of the framework

**Warning**

If you are using a ZSH Framework the associated `asdf` plugin may need to be updated to use the new ZSH completions properly via `fpath`. The Oh-My-ZSH asdf plugin is yet to be updated, see [ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837).
:::

::: details ZSH & Homebrew

Add `asdf.sh` to your `~/.zshrc` with:

```shell
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
```

**OR** use a ZSH Framework plugin like [asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) which will source this script and setup completions.

Completions are configured by either a ZSH Framework `asdf` or will need to be [configured as per Homebrew's instructions](https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh). If you are using a ZSH Framework the associated plugin for asdf may need to be updated to use the new ZSH completions properly via `fpath`. The Oh-My-ZSH asdf plugin is yet to be updated, see [ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837).
:::

::: details ZSH & Pacman

Add the following to `~/.zshrc`:

```shell
. /opt/asdf-vm/asdf.sh
```

Completions are placed in a ZSH friendly location, but [ZSH must be configured to use the autocompletions](https://wiki.archlinux.org/index.php/zsh#Command_completion).
:::

::: details PowerShell Core & Git

Add the following to `~/.config/powershell/profile.ps1`:

```shell
. "$HOME/.asdf/asdf.ps1"
```

:::

::: details PowerShell Core & Homebrew

Add `asdf.sh` to your `~/.config/powershell/profile.ps1` with:

```shell
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.ps1\"" >> ~/.config/powershell/profile.ps1
```

:::

::: details PowerShell Core & Pacman

Add the following to `~/.config/powershell/profile.ps1`:

```shell
. /opt/asdf-vm/asdf.ps1
```

:::

::: details Nushell & Git

Add `asdf.nu` to your `~/.config/nushell/config.nu` with:

```shell
"\n$env.ASDF_DIR = ($env.HOME | path join '.asdf')\n source " + ($env.HOME | path join '.asdf/asdf.nu') | save --append $nu.config-path
```

Completions are automatically configured
:::

::: details Nushell & Homebrew

Add `asdf.nu` to your `~/.config/nushell/config.nu` with:

```shell
"\n$env.ASDF_DIR = (brew --prefix asdf | str trim | into string | path join 'libexec')\n source " +  (brew --prefix asdf | str trim | into string | path join 'libexec/asdf.nu') | save --append $nu.config-path
```

Completions are automatically configured
:::

::: details Nushell & Pacman

Add `asdf.nu` to your `~/.config/nushell/config.nu` with:

```shell
"\n$env.ASDF_DIR = '/opt/asdf-vm/'\n source /opt/asdf-vm/asdf.nu" | save --append $nu.config-path
```

Completions are automatically configured.
:::

::: details POSIX Shell & Git

Add the following to `~/.profile`:

```shell
export ASDF_DIR="$HOME/.asdf"
. "$HOME/.asdf/asdf.sh"
```

:::

::: details POSIX Shell & Homebrew

Add `asdf.sh` to your `~/.profile` with:

```shell
echo -e "\nexport ASDF_DIR=\"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.profile
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.profile
```

:::

::: details POSIX Shell & Pacman

Add the following to `~/.profile`:

```shell
export ASDF_DIR="/opt/asdf-vm"
. /opt/asdf-vm/asdf.sh
```

:::

`asdf` scripts need to be sourced **after** you have set your `$PATH` and **after** you have sourced your framework (oh-my-zsh etc).

::: warning
On macOS, starting a Bash or Zsh shell automatically calls a utility called `path_helper`. `path_helper` can rearrange items in `PATH` (and `MANPATH`), causing inconsistent behavior for tools that require specific ordering. To workaround this, `asdf` on macOS defaults to forcily adding its `PATH`-entries to the front (taking highest priority). This is controllable with the `ASDF_FORCE_PREPEND` variable.
:::

Restart your shell so that `PATH` changes take effect. Opening a new terminal tab will usually do it.

## Core Installation Complete!

This completes the installation of the `asdf` core :tada:

`asdf` is only useful once you install a **plugin**, install a **tool** and manage its **versions**. Continue the guide below to learn how to do this.

## 4. Install a Plugin

For demonstration purposes we will install & set [Node.js](https://nodejs.org/) via the [`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/) plugin.

### Plugin Dependencies

Each plugin has dependencies so we need to check the plugin repo where they should be listed. For `asdf-nodejs` they are:

| OS                             | Dependency Installation                 |
| ------------------------------ | --------------------------------------- |
| Debian                         | `apt-get install dirmngr gpg curl gawk` |
| CentOS/ Rocky Linux/ AlmaLinux | `yum install gnupg2 curl gawk`          |
| macOS                          | `brew install gpg gawk`                 |

We should install dependencies first as some Plugins have post-install hooks.

### Install the Plugin

```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## 5. Install a Version

Now we have a plugin for Node.js we can install a version of the tool.

We can see which versions are available with `asdf list all nodejs` or a subset of versions with `asdf list all nodejs 14`.

We will just install the `latest` available version:

```shell
asdf install nodejs latest
```

::: tip Note
`asdf` enforces exact versions. `latest` is a helper throughout `asdf` that will resolve to the actual version number at the time of execution.
:::

## 6. Set a Version

`asdf` performs a version lookup of a tool in all `.tool-versions` files from the current working directory up to the `$HOME` directory. The lookup occurs just-in-time when you execute a tool that `asdf` manages.

::: warning
Without a version listed for a tool execution of the tool will **error**. `asdf current` will show you the tool & version resolution, or absence of, from your current directory so you can observe which tools will fail to execute.
:::

### Global

Global defaults are managed in `$HOME/.tool-versions`. Set a global version with:

```shell
asdf global nodejs latest
```

`$HOME/.tool-versions` will then look like:

```
nodejs 16.5.0
```

Some OSs already have tools installed that are managed by the system and not `asdf`, `python` is a common example. You need to tell `asdf` to pass the management back to the system. The [Versions reference section](/manage/versions.md) will guide you.

### Local

Local versions are defined in the `$PWD/.tool-versions` file (your current working directory). Usually, this will be the Git repository for a project. When in your desired directory execute:

```shell
asdf local nodejs latest
```

`$PWD/.tool-versions` will then look like:

```
nodejs 16.5.0
```

### Using Existing Tool Version Files

`asdf` supports the migration from existing version files from other version managers. Eg: `.ruby-version` for the case of `rbenv`. This is supported on a per-plugin basis.

[`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/) supports this via both `.nvmrc` and `.node-version` files. To enable this, add the following to your `asdf` configuration file `$HOME/.asdfrc`:

```
legacy_version_file = yes
```

See the [configuration](/manage/configuration.md) reference page for more config options.

## Guide Complete!

That completes the Getting Started guide for `asdf` :tada: You can now manage `nodejs` versions for your project. Follow similar steps for each type of tool in your project!

`asdf` has many more commands to become familiar with, you can see them all by running `asdf --help` or `asdf`. The core of the commands are broken into three categories:

- [core `asdf`](/manage/core.md)
- [plugins](/manage/plugins.md)
- [versions (of tools)](/manage/versions.md)

# Getting Started

## 1. Install asdf

asdf can be installed in several different ways:

::: details With Package Manager - **Recommended**

| Package Manager   | Command                                                                                                                                                             |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Homebrew | `brew install asdf`                                                                                                                                                 |
| Pacman   | `git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si` or use your preferred [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) |

:::

:::: details Download Pre-Compiled Binary - **Easy**

<!--@include: @/parts/install-dependencies.md-->

##### Install asdf

1. Visit https://github.com/asdf-vm/asdf/releases and download the appropriate archive for your operating system/architecture combination.
2. Extract the `asdf` binary in the archive into a directory on your `$PATH`.
3. Verify `asdf` is on your shell's `$PATH` by running `type -a asdf`. The directory you placed the `asdf` binary in should be listed on the first line of the output from `type`. If it is not that means step #2 was not completed correctly.

::::

:::: details With `go install`

<!--@include: @/parts/install-dependencies.md-->

##### Install asdf

<!-- x-release-please-start-version -->
1. [Install Go](https://go.dev/doc/install)
2. Run `go install github.com/asdf-vm/asdf/cmd/asdf@v0.16.0`
<!-- x-release-please-end -->

::::

:::: details Build from Source

<!--@include: @/parts/install-dependencies.md-->

##### Install asdf

<!-- x-release-please-start-version -->
1. Clone the asdf repository:
  ```shell
  git clone https://github.com/asdf-vm/asdf.git --branch v0.16.0
  ```
<!-- x-release-please-end -->
2. Run `make`
3. Copy the `asdf` binary into a directory on your `$PATH`.
4. Verify `asdf` is on your shell's `$PATH` by running `type -a asdf`. The directory you placed the `asdf` binary in should be listed on the first line of the output from `type`. If it is not that means step #3 was not completed correctly.

::::

## 2. Configure asdf

::: tip Note
Most users **DO NOT** need to customize the location that asdf writes plugin,
install, and shim data to. However, if `$HOME/.asdf` isn't the directory you
want asdf writing too, you can change it. Specify the directory by exporting
a variable named `ASDF_DATA_DIR` in your shell's RC file.
:::

There are many different combinations of Shells, OSs & Installation methods all of which affect the configuration here. Expand the selection below that best matches your system.

**macOS users, be sure to read the warning about `path_helper` at the end of this section.**

::: details Bash

**macOS Catalina or newer**: The default shell has changed to **ZSH**. Unless changing back to Bash, follow the ZSH instructions.

**Pacman**: [`bash-completion`](https://wiki.archlinux.org/title/bash#Common_programs_and_options) needs to be installed for the completions to work.

##### Add shims directory to path (required)

Add the following to `~/.bash_profile`:
```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### Custom data directory (optional)

Add the following to `~/.bash_profile` above the line you added above:

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
```

##### Set up shell completions (optional)

Completions must be configured by adding the following to your `.bashrc`:

```shell
. <(asdf completion bash)
```

:::

::: details Fish

##### Add shims directory to path (required)

Add the following to `~/.config/fish/config.fish`:

```shell
# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims
```

###### Custom data directory (optional)

**Pacman**: Completions are automatically configured on installation by the AUR package.

Add the following to `~/.config/fish/config.fish` above the lines you added above:

```shell
set -gx --prepend ASDF_DATA_DIR "/your/custom/data/dir"
```

##### Set up shell completions (optional)

Completions must be configured manually with the following command:

```shell
$ asdf completion fish > ~/.config/fish/completions/asdf.fish
```

:::

::: details Elvish

##### Add shims directory to path (required)

Add the following to `~/.config/elvish/rc.elv`:

```shell
var asdf_data_dir = ~'/.asdf'
if (and (has-env ASDF_DATA_DIR) (!=s $E:ASDF_DATA_DIR '')) {
  set asdf_data_dir = $E:ASDF_DATA_DIR
}

if (not (has-value $paths $asdf_data_dir'/shims')) {
  set paths = [$path $@paths]
}
```

###### Custom data directory (optional)

Change the following line in the above snippet to set a custom data directory:

```diff
-var asdf_data_dir = ~'/.asdf'
+var asdf_data_dir = '/your/custom/data/dir'
```

##### Set up shell completions (optional)

```shell
$ asdf completion elvish >> ~/.config/elvish/rc.elv
$ echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

:::

::: details ZSH

**Pacman**: Completions are placed in a ZSH friendly location, but [ZSH must be configured to use the autocompletions](https://wiki.archlinux.org/index.php/zsh#Command_completion).

##### Add shims directory to path (required)

Add the following to `~/.zshrc`:
```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### Custom data directory (optional)

Add the following to `~/.zshrc` above the line you added above:

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
```

##### Set up shell completions (optional)

Completions are configured by either a ZSH Framework `asdf` plugin (like [asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf)) or by doing the following:

```shell
$ mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
$ asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
```

Then add the following to your `.zshrc`:

```shell
# append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
```

**Note**

If you are using a custom `compinit` setup with a ZSH Framework, ensure `compinit` is below your sourcing of the framework

Completions are configured by either a ZSH Framework `asdf` or will need to be [configured as per Homebrew's instructions](https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh). If you are using a ZSH Framework the associated plugin for asdf may need to be updated to use the new ZSH completions properly via `fpath`. The Oh-My-ZSH asdf plugin is yet to be updated, see [ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837).
:::

::: details PowerShell Core

##### Add shims directory to path (required)

Add the following to `~/.config/powershell/profile.ps1`:
```shell
# Determine the location of the shims directory
if ($null -eq $ASDF_DATA_DIR -or $ASDF_DATA_DIR -eq '') {
  $_asdf_shims = "${env:HOME}/.asdf/shims"
}
else {
  $_asdf_shims = "$ASDF_DATA_DIR/shims"
}

# Then add it to path
$env:PATH = "${_asdf_shims}:${env:PATH}"
```

###### Custom data directory (optional)

Add the following to `~/.config/powershell/profile.ps1` above the snippet you added above:

```shell
$env:ASDF_DATA_DIR = "/your/custom/data/dir"
```

Shell completions not available for PowerShell

:::

::: details Nushell

##### Add shims directory to path (required)

Add the following to `~/.config/nushell/config.nu`:

```shell
let shims_dir = (
  if ( $env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  } | path join 'shims'
)
$env.PATH = ( $env.PATH | split row (char esep) | where { |p| $p != $shims_dir } | prepend $shims_dir )
```

###### Custom data directory (optional)

Add the following to `~/.config/nushell/config.nu` above the line you added above:

```shell
$env.ASDF_DATA_DIR = "/your/custom/data/dir"
```

##### Set up shell completions (optional)

```shell
# If you've not customized the asdf data directory:
$ mkdir $"($env.HOME)/.asdf/completions"
$ asdf completion nushell | save $"($env.HOME)/.asdf/completions/nushell.nu"

# If you have customized the data directory by setting ASDF_DATA_DIR:
$ mkdir $"($env.ASDF_DATA_DIR)/completions"
$ asdf completion nushell | save $"($env.ASDF_DATA_DIR)/completions/nushell.nu"
```

Then add the following to `~/.config/nushell/config.nu`:

```shell
let asdf_data_dir = (
  if ( $env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  }
)
. "$asdf_data_dir/completions/nushell.nu"
```

:::

::: details POSIX Shell

##### Add shims directory to path (required)

Add the following to `~/.profile`:
```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### Custom data directory (optional)

Add the following to `~/.profile` above the line you added above:

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
```

:::

`asdf` scripts need to be sourced **after** you have set your `$PATH` and **after** you have sourced your framework (oh-my-zsh etc).

::: warning
On macOS, starting a Bash or Zsh shell automatically calls a utility called `path_helper`. `path_helper` can rearrange items in `PATH` (and `MANPATH`), causing inconsistent behavior for tools that require specific ordering. To workaround this, `asdf` on macOS defaults to forcibly adding its `PATH`-entries to the front (taking highest priority). This is controllable with the `ASDF_FORCE_PREPEND` variable.
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

Because asdf looks for a `.tool-versions` file in the current directory first, and if the file is not found it then climbs up the file tree looking for a `.tool-versions` in a parent directory until it finds one. If no `.tool-versions` file is found the version resolution process will fail and an error will be printed.

If you want to set a default version that will apply to all directories you work in you can set a version in `$HOME/.tool-versions`. Any directory under your home directory will have that same version set, unless a particular directory sets another version.

```shell
asdf set -u nodejs 16.5.0
```

`$HOME/.tool-versions` will then look like:

```
nodejs 16.5.0
```

Some OSs already have tools installed that are managed by the system and not `asdf`, `python` is a common example. You need to tell `asdf` to pass the management back to the system. The [Versions reference section](/manage/versions.md) will guide you.

The first place asdf looks for a version is your current working directory (`$PWD/.tool-versions`). This may be a directory containing a source code or Git repository for a project. When in your desired directory execute you can use `asdf set` to set the version:

```shell
asdf set nodejs 16.5.0
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

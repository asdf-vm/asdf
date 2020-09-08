1. [Manage asdf-vm](/core-manage-asdf-vm): install `asdf` **and** add `asdf` to your shell
2. [Manage Plugins](/core-manage-plugins): add a plugin for your tool `asdf plugin add nodejs`
3. [Manage Versions](/core-manage-versions): install a version of that tool `asdf install nodejs 13.14.0`
4. [Configuration](/core-configuration): set global and project tool versions via `.tool-versions` config

## Install

### Dependencies

<!-- select:start -->
<!-- select-menu-labels: Operating System,Installation Method -->

#### -- Linux,Aptitude --

```shell
sudo apt install curl git
```

#### -- Linux,DNF --

```shell
sudo dnf install curl git
```

#### -- Linux,Pacman --

```shell
sudo pacman -S curl git
```

#### -- Linux,Zypper --

```shell
sudo zypper install curl git
```

#### -- macOS,Homebrew --

```shell
brew install coreutils curl git
```

#### -- macOS,Spack --

```shell
spack install coreutils curl git
```

### -- Docsify Select Default --

No match for _Operating System_ and _Installation Method_ selections. Please try another combination.

<!-- select:end -->

### asdf

<!-- select:start -->
<!-- select-menu-labels: Installation Method -->

### --Git--

Clone only the latest branch:

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
```

Alternately, you can clone the whole repo and checkout the latest branch:

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout "$(git describe --abbrev=0 --tags)"
```

### --Homebrew--

!> See `asdf` and Homebrew compatibility [issues in #785](https://github.com/asdf-vm/asdf/issues/785) before continuing.

Install using the Homebrew package manager:

```shell
brew install asdf
```

To use the latest changes, you can point Homebrew to the master branch of the repo:

```shell
brew install asdf --HEAD
```

<!-- select:end -->

### Add to your Shell

<!-- select:start -->
<!-- select-menu-labels: Operating System,Shell,Installation Method -->

#### --Linux,Bash,Git--

Add the following to `~/.bashrc`:

```shell
. $HOME/.asdf/asdf.sh
```

?> Completions must be configured by adding the following to your `.bashrc`:

```shell
. $HOME/.asdf/completions/asdf.bash
```

#### --Linux,Fish,Git--

Add the following to `~/.config/fish/config.fish`:

```shell
source ~/.asdf/asdf.fish
```

?> Completions must be configured manually with the following command:

```shell
mkdir -p ~/.config/fish/completions; and cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

#### --Linux,ZSH,Git--

Add the following to `~/.zshrc`:

```shell
. $HOME/.asdf/asdf.sh
```

**OR** use a ZSH Framework plugin like [asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) which will source this script and setup completions.

?> Completions are configured by either a ZSH Framework `asdf` plugin or by adding the following to your `.zshrc`:

```shell
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit
compinit
```

- if you are using a custom `compinit` setup, ensure `compinit` is below your sourcing of `asdf.sh`
- if you are using a custom `compinit` setup with a ZSH Framework, ensure `compinit` is below your sourcing of the framework

!> if you are using a ZSH Framework the associated `asdf` plugin may need to be updated to use the new ZSH completions properly via `fpath`. The Oh-My-ZSH asdf plugin is yet to be updated, see https://github.com/ohmyzsh/ohmyzsh/pull/8837.

#### --macOS,Bash,Git--

If using **macOS Catalina or newer**, the default shell has changed to **ZSH**. Unless changing back to Bash, follow the ZSH instructions.

Add the following to `~/.bash_profile`:

```shell
. $HOME/.asdf/asdf.sh
```

?> Completions must be configured manually with the following entry in your `.bash_profile`:

```shell
. $HOME/.asdf/completions/asdf.bash
```

#### --macOS,Fish,Git--

Add the following to `~/.config/fish/config.fish`:

```shell
source ~/.asdf/asdf.fish
```

?> Completions must be configured manually with the following command:

```shell
mkdir -p ~/.config/fish/completions; and cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

#### --macOS,ZSH,Git--

Add the following to `~/.zshrc`:

```shell
. $HOME/.asdf/asdf.sh
```

**OR** use a ZSH Framework plugin like [asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) which will source this script and setup completions.

?> Completions are configured by either a ZSH Framework `asdf` plugin or by adding the following to your `.zshrc`:

```shell
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit
compinit
```

- if you are using a custom `compinit` setup, ensure `compinit` is below your sourcing of `asdf.sh`
- if you are using a custom `compinit` setup with a ZSH Framework, ensure `compinit` is below your sourcing of the framework

!> if you are using a ZSH Framework the associated `asdf` plugin may need to be updated to use the new ZSH completions properly via `fpath`. The Oh-My-ZSH asdf plugin is yet to be updated, see https://github.com/ohmyzsh/ohmyzsh/pull/8837.

#### --macOS,Bash,Homebrew--

If using **macOS Catalina or newer**, the default shell has changed to **ZSH**. Unless changing back to Bash, follow the ZSH instructions.

Add `asdf.sh` to your `~/.bash_profile` with:

```shell
echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.bash_profile
```

?> Completions will need to be [configured as per Homebrew's instructions](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) or with the following:

```shell
echo -e "\n. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" >> ~/.bash_profile
```

#### --macOS,Fish,Homebrew--

Add `asdf.fish` to your `~/.config/fish/config.fish` with:

```shell
echo -e "\nsource "(brew --prefix asdf)"/asdf.fish" >> ~/.config/fish/config.fish
```

?> Completions are [handled by Homebrew for the Fish shell](https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish). Friendly!

#### --macOS,ZSH,Homebrew--

Add `asdf.sh` to your `~/.zshrc` with:

```shell
echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.zshrc
```

?> Completions will need to be [configured as per Homebrew's instructions](https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh).

### --Docsify Select Default--

!> The `Homebrew` `asdf` Formulae has not been tested on `Linux` by the core asdf team. Please raise an issue if this has changed and we will update the docs.

<!-- select:end -->

Restart your shell so that PATH changes take effect. (Opening a new terminal
tab will usually do it.)

You are ready to use asdf 🎉

### Having Issues?

If you're having issues with your shell not detecting newly installed shims, it's most-likely due to the sourcing of `asdf.sh` or `asdf.fish` not being at the **BOTTOM** of your `.bash_profile`, `.zshrc`, `config.fish` config file. It needs to be sourced **AFTER** you have set your `$PATH` and **AFTER** you have sourced your framework (oh-my-zsh etc).


### Migrating Tools

If you're migrating from other tools and want to use your existing version files (eg: `.node-version` or `.ruby-version`), look at the `legacy_version_file` [flag in the configuration section](core-configuration?id=homeasdfrc).

## Update

<!-- select:start -->
<!-- select-menu-labels: Installation Method -->

### -- Git --

```shell
asdf update
```

If you want the latest changes that aren't yet included in a stable release:

```shell
asdf update --head
```

### -- Homebrew --

```shell
brew upgrade asdf
```

<!-- select:end -->

## Remove

Uninstalling `asdf` is as simple as:

1.  In your `.bashrc`/`.bash_profile`/`.zshrc`/`config.fish` find the lines that source `asdf.sh` and the completions (this may be a ZSH Framework plugin). In Bash, the lines look something like this:

    ```shell
    . $HOME/.asdf/asdf.sh
    . $HOME/.asdf/completions/asdf.bash
    ```

    Remove these lines and save the file.

2.  Run

    ```shell
    rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf} ~/.tool-versions
    ```

    to completely remove all the asdf files from your system.

3.  _(Optional)_ If you installed asdf using a package manager, you may want to use that package manager to uninstall the core asdf files.

That's it! 🎉

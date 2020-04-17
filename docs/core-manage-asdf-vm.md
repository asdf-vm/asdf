## Install asdf-vm

<!-- select:start -->
<!-- select-menu-labels: Installation Method -->

### --Git--

Clone only the latest branch:

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.8
```

Alternately, you can clone the whole repo and checkout the latest branch:

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout "$(git describe --abbrev=0 --tags)"
```

### --Homebrew--

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

```bash
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
```

#### --Linux,Fish,Git--

[Linux + Fish + Git](_sections/add-to-shell/fish-git.md ':include')

#### --Linux,ZSH,Git--

[Linux + ZSH + Git](_sections/add-to-shell/zsh-git.md ':include')

#### --macOS,Bash,Git--

```bash
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bash_profile
```

Note if you are using Catalina or newer, the default shell has changed to Zsh:

```bash
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zprofile
```

#### --macOS,Fish,Git--

[macOS + Fish + Git](_sections/add-to-shell/fish-git.md ':include')

#### --macOS,ZSH,Git--

[macOS + ZSH + Git](_sections/add-to-shell/zsh-git.md ':include')

#### --macOS,Bash,Homebrew--

?> If you have Homebrew's Bash completions configured, the second line below is
unnecessary. See [Configuring Completions
in Bash](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash)
in the Homebrew docs.

```bash
echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.bash_profile
echo -e "\n. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" >> ~/.bash_profile
```

#### --macOS,Fish,Homebrew--

?> Homebrew takes care of [installing the completions for fish
shell](https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish).
Friendly!

```shell
echo "source "(brew --prefix asdf)"/asdf.fish" >> ~/.config/fish/config.fish
```

#### --macOS,ZSH,Homebrew--

```shell
echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.zshrc
```

Shell completions should automatically be installed and available.

### --Docsify Select Default--

!> `asdf` cannot be installed via Homebrew on Linux.

<!-- select:end -->

Restart your shell so that PATH changes take effect. (Opening a new terminal
tab will usually do it.)

You are ready to use asdf 🎉

### Having Issues?

TODO: REWORD BELOW. REMOVE !> as the page is too loud!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!> If you're having issues with it your shell not detecting newly installed shims, it's most-likely due to the sourcing of above `asdf.bash` or `asdf.fish` not being at the **BOTTOM** of your `~/.bash_profile`, `~/.zshrc`, or `~/.config/fish/config.fish`. It needs to be sourced **AFTER** you have set your `$PATH.` and **AFTER** you have sourced your framework (oh-my-zsh etc).

### Plugin Dependencies

For most plugins, it is good if you have installed the following packages:

<!-- select:start -->
<!-- select-menu-labels: Operating System,Installation Method -->

#### -- Linux,Aptitude --

```shell
sudo apt install \
  automake autoconf libreadline-dev \
  libncurses-dev libssl-dev libyaml-dev \
  libxslt-dev libffi-dev libtool unixodbc-dev \
  unzip curl
```

#### -- Linux,DNF --

```shell
sudo dnf install \
  automake autoconf readline-devel \
  ncurses-devel openssl-devel libyaml-devel \
  libxslt-devel libffi-devel libtool unixODBC-devel \
  unzip curl
```

#### -- macOS,Homebrew --

```shell
brew install \
  coreutils automake autoconf openssl \
  libyaml readline libxslt libtool unixodbc \
  unzip curl
```

#### -- macOS,Spack --

```shell
spack install \
  coreutils automake autoconf openssl \
  libyaml readline libxslt libtool unixodbc \
  unzip curl
```

### -- Docsify Select Default --

No match for _Operating System_ and _Installation Method_ selections.

<!-- select:end -->

### Migrating Tools

If you're migrating from other tools and want to use your existing version files (eg: `.node-version` or `.ruby-version`), look at the [`legacy_version_file` flag in the configuration section](core-configuration?id=homeasdfrc).

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

1.  In your `.bashrc`/`.bash_profile`/`.zshrc`/`config.fish` find the lines that source `asdf.sh` and the autocompletions. The lines should look something like this:

    ```shell
    . $HOME/.asdf/asdf.sh
    . $HOME/.asdf/completions/asdf.bash
    ```

    Remove these lines and save the file.

2.  Run

    ```shell
    rm -rf ~/.asdf/ ~/.tool-versions
    ```

    to completely remove all the asdf files from your system.

3.  _(Optional)_ If you installed asdf using a package manager, you may want to use that package manager to uninstall the core asdf files.

That's it! 🎉

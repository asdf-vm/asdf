## Install asdf-vm

<!-- tabs:start -->

#### ** Git **

Clone only the latest branch:

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.1
```

Alternately, you can clone the whole repo and checkout the latest branch:

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout "$(git describe --abbrev=0 --tags)"
```

#### ** Homebrew **

Install using the Homebrew package manager on macOS:

```shell
brew install asdf
```

<!-- tabs:end -->

### Add to your Shell

<!-- tabs:start -->

#### ** Bash on Linux **

```bash
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
```

#### ** Bash on macOS **

Installation via **Git**:

```bash
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bash_profile
```

Installation via **Homebrew**:

?> If you have Homebrew's Bash completions configured, the second line below is
unnecessary. See [Configuring Completions
in Bash](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash)
in the Homebrew docs.

```bash
echo -e '\n. $(brew --prefix asdf)/asdf.sh' >> ~/.bash_profile
echo -e '\n. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash' >> ~/.bash_profile
```

#### ** ZSH **

If you are using a framework, such as oh-my-zsh, use these lines. (Be sure
that if you make future changes to .zshrc these lines remain _below_ the line
where you source your framework.)

```shell
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc
```

If you are not using a framework, or if on starting your shell you get an
error message like 'command not found: compinit', then add this line before
the ones above.

```shell
autoload -Uz compinit && compinit
```

#### ** Fish **

```shell
echo 'source ~/.asdf/asdf.fish' >> ~/.config/fish/config.fish
mkdir -p ~/.config/fish/completions; and cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

<!-- tabs:end -->

Restart your shell so that PATH changes take effect. (Opening a new terminal
tab will usually do it.)

### Having Issues?

!> If you're having issues with it not detecting the shims you've installed it's most-likely due to the sourcing of above `asdf.bash` or `asdf.fish` not being at the **BOTTOM** of your `~/.bash_profile`, `~/.zshrc`, or `~/.config/fish/config.fish`. It needs to be sourced **AFTER** you have set your `$PATH.`

### Plugin Dependencies

?> For most plugins, it is good if you have installed the following packages OR their equivalent on your OS

<!-- tabs:start -->

#### ** macOS **

Installation via Homebrew:

```shell
brew install \
  coreutils automake autoconf openssl \
  libyaml readline libxslt libtool unixodbc \
  unzip curl
```

Installation via Spack:

```shell
spack install \
  coreutils automake autoconf openssl \
  libyaml readline libxslt libtool unixodbc \
  unzip curl
```

#### ** Ubuntu **

```shell
sudo apt install \
  automake autoconf libreadline-dev \
  libncurses-dev libssl-dev libyaml-dev \
  libxslt-dev libffi-dev libtool unixodbc-dev \
  unzip curl
```

#### **Fedora**

```shell
sudo dnf install \
  automake autoconf readline-devel \
  ncurses-devel openssl-devel libyaml-devel \
  libxslt-devel libffi-devel libtool unixODBC-devel \
  unzip curl
```

<!-- tabs:end -->

That's all! You are ready to use asdf 🎉

?> If you're migrating from other tools and want to use your existing `.node-version` or `.ruby-version` version files, look at the [`legacy_version_file` flag in the configuration section](core-configuration?id=homeasdfrc).

## Update

<!-- tabs:start -->

### ** Git **

```shell
asdf update
```

If you want the latest changes that aren't yet included in a stable release:

```shell
asdf update --head
```

### ** Homebrew **

```shell
brew upgrade asdf
```

<!-- tabs:end -->

## Remove

Uninstalling `asdf` is as simple as:

1.  In your `.bashrc` (or `.bash_profile` if you are on OSX) or `.zshrc` find the lines that source `asdf.sh` and the autocompletions. The lines should look something like this:

    ```shell
    . $HOME/.asdf/asdf.sh
    . $HOME/.asdf/completions/asdf.bash
    ```

    Remove these lines and save the file.

2.  Run `rm -rf ~/.asdf/ ~/.tool-versions` to completely remove all the asdf
    files from your system.

3.  _(Optional)_ If you installed asdf using a package manager, you may want to use
    that package manager to uninstall the core asdf files.

That's it! 🎉

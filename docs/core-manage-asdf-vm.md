## Install asdf-vm

Clone only the latest branch:

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.3
```

Alternately, you can clone the whole repo and checkout the latest branch:

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout "$(git describe --abbrev=0 --tags)"
```

### Add to your Shell

<!-- tabs:start -->

#### ** Bash on Linux **

```bash
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
```

#### ** Bash on macOS **

```bash
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bash_profile
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

Install these via homebrew:

```shell
brew install \
  coreutils automake autoconf openssl \
  libyaml readline libxslt libtool unixodbc
```

#### ** Ubuntu **

```shell
sudo apt install \
  automake autoconf libreadline-dev \
  libncurses-dev libssl-dev libyaml-dev \
  libxslt-dev libffi-dev libtool unixodbc-dev
```

#### **Fedora**

```shell
sudo dnf install \
  automake autoconf readline-devel \
  ncurses-devel openssl-devel libyaml-devel \
  libxslt-devel libffi-devel libtool unixODBC-devel
```

<!-- tabs:end -->

That's all! You are ready to use asdf 🎉

## Update

```shell
asdf update
```

If you want the latest changes that aren't yet included in a stable release:

```shell
asdf update --head
```

## Remove

Uninstalling `asdf` is as simple as:

1.  In your `.bashrc` (or `.bash_profile` if you are on OSX) or `.zshrc` find the lines that source `asdf.sh` and the autocompletions. The lines should look something like this:

    ```shell
    . $HOME/.asdf/asdf.sh
    . $HOME/.asdf/completions/asdf.bash
    ```

    Remove these lines and save the file.

2.  Run `rm -rf ~/.asdf/ ~/.tool-versions` to completely remove all the asdf files from your system.

That's it! 🎉

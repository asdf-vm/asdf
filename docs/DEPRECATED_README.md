# asdf [![Build Status](https://travis-ci.org/asdf-vm/asdf.svg?branch=master)](https://travis-ci.org/asdf-vm/asdf)

### _extendable version manager_

Supported languages include Ruby, Node.js, Elixir and [more][plugins].
Supporting a new language is as simple as [this plugin API][plugin_api].

[plugins]: https://github.com/asdf-vm/asdf-plugins
[plugin_api]: https://github.com/asdf-vm/asdf/blob/master/docs/plugins-create.md

## INSTALLATION

If you're on macOS you can [Install using Homebrew](https://github.com/asdf-vm/asdf#homebrew-on-macos)

### Basic Installation

Copy-paste the following into command line:

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.3
```

### Setup

Depending on your OS and shell, run the following:

* Bash on Ubuntu (and other Linux distros):

  ```bash
  echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
  echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
  ```

* Bash on macOS:

  ```bash
  echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
  echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bash_profile
  ```

* Zsh:

  If you are using a framework, such as oh-my-zsh, use these lines. (Be sure
  that if you make future changes to .zshrc these lines remain _below_ the line
  where you source your framework.)

  ```bash
  echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
  echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc
  ```

  If you are not using a framework, or if on starting your shell you get an
  error message like 'command not found: compinit', then add this line before
  the ones above.

  ```bash
  autoload -Uz compinit && compinit
  ```

* Fish:

  ```bash
  echo 'source ~/.asdf/asdf.fish' >> ~/.config/fish/config.fish
  mkdir -p ~/.config/fish/completions; and cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions
  ```
Restart your shell so that PATH changes take effect. (Opening a new terminal
tab will usually do it.)

Also if you're having issues with it not detecting the shims you've installed
it's most-likely due to the sourcing of above `asdf.bash` or `asdf.fish` not
being at the bottom of your `~/.bash_profile`, `~/.zshrc`, or
`~/.config/fish/config.fish`. It needs to be sourced *after* you've set your
`$PATH.`

> For most plugins, it is good if you have installed the following packages OR
> their equivalent on your OS

> * **macOS**: Install these via homebrew `coreutils automake autoconf openssl libyaml readline libxslt libtool unixodbc`
> * **Ubuntu**: `automake autoconf libreadline-dev libncurses-dev libssl-dev libyaml-dev libxslt-dev libffi-dev libtool unixodbc-dev`
> * **Fedora**: `automake autoconf readline-devel ncurses-devel openssl-devel libyaml-devel libxslt-devel libffi-devel libtool unixODBC-devel`

**That's all ~! You are ready to use asdf**

---

## USAGE

These instructions are for a specific version of asdf. Make sure the version
README you refer to matches the version of asdf you have installed. Checkout a
specific tagged version in the GitHub branches/tags drop-down if you need to.

### Manage plugins

Plugins are how asdf understands how to handle different packages. The [plugins
repository][plugins] lists all of the asdf plugins we know of and there is a
[super-simple API][plugin_api] for supporting more languages.

##### Add a plugin

```bash
asdf plugin-add <name>
# asdf plugin-add erlang
```

If the plugin you want to install is not part of the plugins repository, you
can add it using its repository URL:

```bash
asdf plugin-add <name> <git-url>
# asdf plugin-add elm https://github.com/vic/asdf-elm
```

##### List installed plugins

```bash
asdf plugin-list
# asdf plugin-list
# java
# nodejs
```

```bash
asdf plugin-list --urls
# asdf plugin-list
# java            https://github.com/skotchpine/asdf-java.git
# nodejs          https://github.com/asdf-vm/asdf-nodejs.git
```

##### Remove a plugin

```bash
asdf plugin-remove <name>
# asdf plugin-remove erlang
```

##### Update plugins

```bash
asdf plugin-update --all
```

If you want to update a specific package, just say so.

```bash
asdf plugin-update <name>
# asdf plugin-update erlang
```

##### Update asdf itself

```bash
asdf update
```

If you want the latest changes that aren't yet included in a stable release:

```bash
asdf update --head
```

### Manage versions

```bash
asdf install <name> <version>
# asdf install erlang 17.3

asdf current
# asdf current
# erlang 17.3 (set by /Users/kim/.tool-versions)
# nodejs 6.11.5 (set by /Users/kim/cool-node-project/.tool-versions)

asdf current <name>
# asdf current erlang
# 17.3 (set by /Users/kim/.tool-versions)

asdf uninstall <name> <version>
# asdf uninstall erlang 17.3
```

_If a plugin supports downloading & compiling from source, you can specify
`ref:foo` where `foo` is a specific branch, tag, or commit._ You'll need to use
the same name and reference when uninstalling too.

##### Lists installed versions

```bash
asdf list <name>
# asdf list erlang
```

##### List all available versions

```bash
asdf list-all <name>
# asdf list-all erlang
```

#### View current version

```bash
asdf current <name>
# asdf current erlang
# 17.3 (set by /Users/kim/.tool-versions)
```

#### Set current version

```bash
asdf global <name> <version>
asdf local <name> <version>
# asdf global elixir 1.2.4
```

`global` writes the version to `$HOME/.tool-versions`.

`local` writes the version to `$PWD/.tool-versions`, creating it if needed.

See [The `.tool-versions` file](#the-tool-versions-file) for details.

Alternatively, if you want to set a version only for the current shell session
or for executing just a command under a particular tool version, you
can set an environment variable like `ASDF_${TOOL}_VERSION`.

The following example runs tests on an Elixir project with version `1.4.0`.
The version format is the same supported by the `.tool-versions` file.

```shell
ASDF_ELIXIR_VERSION=1.4.0 mix test
```

### Shims

When asdf installs a package it creates shims for every executable program in
that package in a `$ASDF_DATA_DIR/shims` directory (default `~/.asdf/shims`).
This directory being on the `$PATH` (by means of `asdf.sh` or `asdf.fish`) is
how the installed programs are made available in the environment.

The shims themselves are really simple wrappers that `exec` a helper program
`asdf-exec` passing it the name of the plugin and path to the executable in
the installed package that the shim is wrapping.

The `asdf-exec` helper determines the version of tha package to use (as
specified in `.tool-versions` file, selected by `asdf local ...` or
`asdf global ...`), the final path to the executable in the package
installation directory (this can be manipulated by the `exec-path` callback in
the plugin) and the environment to execute in (also provided by the plugin -
`exec-env` script), and finally it executes it.

Note that because this system uses `exec` calls, any scripts in the package
that are meant to be sourced by the shell instead of executed need to be
accessed directly instead of via the shim wrapper. The two asdf commands:
`which` and `where` can help with this by returning the path to the installed
package:

``` sh
# returns path to main executable in current version
source $(asdf which ${PLUGIN})/../script.sh

# returns path to the package installation directory
source $(asdf where ${PLUGIN} $(asdf current ${PLUGIN}))/bin/script.sh
```

## The `.tool-versions` file

Whenever `.tool-versions` file is present in a directory, the tool versions it
declares will be used in that directory and any subdirectories.
**Global defaults can be set in the file `$HOME/.tool-versions`**

This is what a `.tool-versions` file looks like:

```
ruby 2.2.0
nodejs 0.12.3
```

The versions can be in the following format:

* `0.12.3` - an actual version. Plugins that support downloading binaries, will
  download binaries.
* `ref:v1.0.2-a` or `ref:39cb398vb39` - tag/commit/branch to download from
  github and compile
* `path:/src/elixir` - a path to custom compiled version of a tool to use. For
  use by language developers and such.
* `system` - this keyword causes asdf to passthrough to the version of the tool
  on the system that is not managed by asdf.

To install all the tools defined in a `.tool-versions` file run `asdf install`
with no other arguments in the directory containing the `.tool-versions` file.

Edit the file directly or use `asdf local` (or `asdf global`) which updates it.

## The `$HOME/.asdfrc` config file

Add a `.asdfrc` file to your home directory and asdf will use the settings
specified in the file. The file should be formatted like this:

```
legacy_version_file = yes
```

**Settings**

* `legacy_version_file` - defaults to `no`. If set to yes it will cause plugins
that support this feature to read the version files used by other version
managers (e.g. `.ruby-version` in the case of Ruby's rbenv).

## Environment Variables

* `ASDF_CONFIG_FILE` - Defaults to `~/.asdfrc` as described above. Can be set
  to any location.
* `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME` - The name of the file storing the tool
  names and versions. Defaults to `.tool-versions`. Can be any valid file name.
* `ASDF_DATA_DIR` - Defaults to `~/.asdf` - Location where `asdf` install
  plugins, shims and installs. Can be set to any location before sourcing
  `asdf.sh` or `asdf.fish` mentioned in the section above.

## Uninstall

[Uninstalling asdf is easy](https://github.com/asdf-vm/asdf/blob/master/docs/core-manage-asdf-vm.md#remove).

## Homebrew on macOS

You can also install asdf using the Homebrew package manager for macOS.

```bash
brew update
brew install asdf
```

To upgrade asdf in the future, use upgrade instead of install.

Then follow the rest of the post-installation steps under the [Setup](https://github.com/asdf-vm/asdf#setup) section above.

## Docker images

The [asdf-alpine][asdf-alpine] and [asdf-ubuntu][asdf-ubuntu] projects are an
ongoing effort to provide Dockerized images of some asdf tools. You can use
these docker images as base for your development servers, or for running your
production apps.

[asdf-alpine]: https://github.com/vic/asdf-alpine
[asdf-ubuntu]: https://github.com/vic/asdf-ubuntu

## Development

To develop the project, you can simply `git clone` the master branch. If you
want to try out your changes without making change to your installed `asdf`,
you can set the `$ASDF_DIR` variable to the path where you cloned the
repository, and temporarily prepend the `bin` and `shims` directory of the
directory to your path.

We use [bats](https://github.com/sstephenson/bats) for testing, so make sure
`bats test/` passes after you made your changes.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the contribution guidelines.

## Credits

Me ([@HashNuke](https://github.com/HashNuke)), High-fever, cold, cough.

Copyright 2014 to the end of time ([MIT License](https://github.com/asdf-vm/asdf/blob/master/LICENSE))

### Maintainers

* [@HashNuke](https://github.com/HashNuke)
* [@danhper](https://github.com/danhper)
* [@Stratus3D](https://github.com/Stratus3D)
* [@vic](https://github.com/vic)

---

Read the [ballad](https://github.com/asdf-vm/asdf/blob/master/ballad-of-asdf.md).

# asdf
### _extendable version manager_

> I've built plugins to support the following languages:
> * [Ruby](https://github.com/HashNuke/asdf-ruby)
> * [Erlang](https://github.com/HashNuke/asdf-erlang)
> * [Elixir](https://github.com/HashNuke/asdf-elixir)
> * [Node.js](https://github.com/HashNuke/asdf-nodejs)
>
> There is a [super-simple API](https://github.com/HashNuke/asdf/blob/master/docs/creating-plugins.md) for supporting more languages.

---

## SETUP

Copy-paste the following into command line:

```bash
git clone https://github.com/HashNuke/asdf.git ~/.asdf

```

Depending on your OS, run the following
```bash
# For Ubuntu or other linux distros
echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc

# OR for Max OSX
echo '. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
```

If you use zsh or any other shell, replace `.bashrc` with the config file for the respective shell.

> For most plugins, it is good if you have installed the following packages OR their equivalent on you OS

> * **OS X**: Install these via homebrew `automake autoconf openssl libyaml readline ncurses libxslt libtool unixodbc`
> * **Ubuntu**: `automake autoconf libreadline-dev libncurses-dev libssl-dev libyaml-dev libxslt-dev libffi-dev libtool unixodbc-dev`

**That's all ~! You are ready to use asdf**

-----------------------

## USAGE

### Manage plugins

Plugins are how asdf understands how to handle different packages.


##### Add a plugin

```bash
asdf plugin-add <name> <git-url>
# asdf plugin-add erlang https://github.com/HashNuke/asdf-erlang.git
```

##### List installed plugins

```bash
asdf plugin-list
# asdf plugin-list
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

### Manage versions

```bash
asdf install <name> <version>
# asdf install erlang 17.3

asdf which <name>
# asdf which erlang
# 17.3

asdf uninstall <name> <version>
# asdf uninstall erlang 17.3
```

*If a plugin supports downloading & compiling from source, you can also do this `ref:foo` (replace `foo` with the branch/tag/commit).* You'll have to use the same name when uninstalling too.

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

## The `.tool-versions` file

Add a `.tool-versions` file to your project dir and versions of those tools will be used.
**Global defaults can be set in the file `$HOME/.tool-versions`**

This is what a `.tool-versions` file looks like:

```
ruby 2.2.0
nodejs 0.12.3
```

The versions can be in the following format:

* `0.12.3` - an actual version. Plugins that support downloading binaries, will download binaries.
* `ref:v1.0.2-a` or `ref:39cb398vb39` - tag/commit/branch to download from github and compile
* `path:/src/elixir` - a path to custom compiled version of a tool to use. For use by language developers and such.

## Credits

Me ([@HashNuke](http://github.com/HashNuke)), High-fever, cold, cough.

Copyright 2014 to the end of time

-------

Read the [ballad](https://github.com/HashNuke/asdf/blob/master/ballad-of-asdf.md).

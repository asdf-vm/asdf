# qwer
### _extendable version manager_

> I've built plugins to support the following languages:
> * [Ruby](https://github.com/HashNuke/qwer-ruby)
> * [Erlang](https://github.com/HashNuke/qwer-erlang)
> * [Elixir](https://github.com/HashNuke/qwer-elixir)
> * [Node.js](https://github.com/HashNuke/qwer-nodejs)
>
> There is a [super-simple API](https://github.com/HashNuke/qwer/blob/master/docs/creating-plugins.md) for supporting more languages.

---

## SETUP

Copy-paste the following into command line:

```bash
git clone https://github.com/HashNuke/qwer.git ~/.qwer

```

Depending on your OS, run the following
```bash
# For Ubuntu or other linux distros
echo '. $HOME/.qwer/qwer.sh' >> ~/.bashrc

# OR for Max OSX
echo '. $HOME/.qwer/qwer.sh' >> ~/.bash_profile
```

If you use zsh or any other shell, replace `.bashrc` with the config file for the respective shell.

> For most plugins, it is good if you have installed the following packages OR their equivalent on you OS

> * **OS X**: Install these via homebrew `automake autoconf openssl libyaml readline ncurses libxslt libtool unixodbc`
> * **Ubuntu**: `automake autoconf libreadline-dev libncurses-dev libssl-dev libyaml-dev libxslt-dev libffi-dev libtool unixodbc-dev`

**That's all ~! You are ready to use qwer**

-----------------------

## USAGE

### Manage plugins

Plugins are how qwer understands how to handle different packages.


##### Add a plugin

```bash
qwer plugin-add <name> <git-url>
# qwer plugin-add erlang https://github.com/HashNuke/qwer-erlang.git
```

##### List installed plugins

```bash
qwer plugin-list
# qwer plugin-list
```

##### Remove a plugin

```bash
qwer plugin-remove <name>
# qwer plugin-remove erlang
```


##### Update plugins

```bash
qwer plugin-update --all
```

If you want to update a specific package, just say so.

```bash
qwer plugin-update <name>
# qwer plugin-update erlang
```

### Manage versions

```bash
qwer install <name> <version>
# qwer install erlang 17.3

qwer which <name>
# qwer which erlang
# 17.3

qwer uninstall <name> <version>
# qwer uninstall erlang 17.3
```

*If a plugin supports downloading & compiling from source, you can also do this `ref:foo` (replace `foo` with the branch/tag/commit).* You'll have to use the same name when uninstalling too.

##### Lists installed versions

```bash
qwer list <name>
# qwer list erlang
```

##### List all available versions

```bash
qwer list-all <name>
# qwer list-all erlang
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

Read the [ballad](https://github.com/HashNuke/qwer/blob/master/ballad-of-qwer.md).

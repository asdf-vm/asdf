# asdf
### _extendable version manager_

> I've built plugins to support the following languages:
> * [Ruby](https://github.com/HashNuke/asdf-ruby)
> * [Erlang](https://github.com/HashNuke/asdf-erlang)
> * [Elixir](https://github.com/HashNuke/asdf-elixir)
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
echo 'source $HOME/.asdf/asdf.sh' >> ~/.bashrc

# OR for Max OSX
echo 'source $HOME/.asdf/asdf.sh' >> ~/.bash_profile
```

If you use zsh or any other shell, replace `.bashrc` with the config file for the respective shell.

> For most plugins, it is good if you have installed the following packages OR their equivalent on you OS

> * **OS X**: Install these via homebrew `openssl libyaml readline ncurses libxslt`
> * **Ubuntu**: `libreadline-dev libncurses-dev libssl-dev libyaml-dev libxslt-dev libffi-dev`

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

asdf uninstall <name> <version>
# asdf uninstall erlang 17.3
```

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

##### Use a specific version of a package

```bash
asdf use <name> <version>
# asdf use erlang 17.5
```

This will set the requested version of the package for the current terminal session.

## The `.tool-versions` file

Add a `.tool-versions` file to your project dir and versions of those packages will be used.

```
elixir 1.0.2
erlang 17.3
```

## Credits

Me ([@HashNuke](http://github.com/HashNuke)), High-fever, cold, cough.

Copyright 2014 to the end of time

-------

Read the [ballad](https://github.com/HashNuke/asdf/blob/master/ballad-of-asdf.md).

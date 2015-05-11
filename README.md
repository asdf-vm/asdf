# asdf
### _extendable version manager_

> I've built plugins to support the following languages:
> * [Ruby](#TODO)
> * [Erlang](https://github.com/HashNuke/asdf-erlang)
> * [Elixir](https://github.com/HashNuke/asdf-elixir)
>
> There is a [super-simple API](https://github.com/HashNuke/asdf/blob/master/docs/creating-package-sources.md) for supporting more languages.

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

> *If you use zsh or any other shell, replace `.bashrc` with the config file for the respective shell.*

**That's all ~! You are ready to use asdf**

-----------------------

## USAGE

### Manage sources

Sources are how asdf understands how to handle packages.


##### Add a package source

```bash
asdf source-add <name> <git-url>
# asdf add-source erlang https://github.com/HashNuke/asdf-erlang.git
```

##### Remove a source

```bash
asdf source-remove <name>
# asdf remove-source erlang
```


##### Update sources

```bash
asdf update-source --all
```

If you want to update a specific package, just say so.

```bash
asdf source-update <name>
# asdf update-source erlang
```

### Manage packages

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
# asdf use erlang 17.3
```

It writes the version to the `.versions` file in the current working directory.


## The `.asdf-versions` file

Add a `.asdf-versions` file to your project dir and versions of those packages will be used.

```
elixir 1.0.2
erlang 17.3
```

## Credits

Me ([@HashNuke](http://github.com/HashNuke)), High-fever, cold, cough.

Copyright 2014 to the end of time

-------

Read the [ballad](https://github.com/HashNuke/asdf/blob/master/ballad-of-asdf.md).

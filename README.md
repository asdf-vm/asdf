# asdf
### _extendable version manager_


Feel free to add support for the language you want. There's a [simple API](#creating-package-sources) for it. Read the [ballad](https://github.com/HashNuke/asdf/blob/master/ballad-of-asdf.md).

[![Support via Gratipay](https://cdn.rawgit.com/gratipay/gratipay-badge/2.3.0/dist/gratipay.png)](https://gratipay.com/HashNuke/)

## Table of Contents

* [Install](#install)
* [Manage sources](#manage-sources)
* [Manage packages](#manage-packages)
* [The `.versions` file](#the-versions-file)
* [Creating package sources](#creating-package-sources)


## Install

Copy-paste the following into command line:

```bash
git clone https://github.com/HashNuke/asdf.git ~/.asdf
echo 'export PATH="$HOME/.asdf/bin:$PATH"' >> ~/.bash_profile
```

**That's all ~! You are ready to use asdf**

It clones the adsf repo and adds `~/.asdf/bin` to `$PATH` in `~/.bash_profile`.


## Manage sources

Sources are how asdf understands how to handle packages.


#### Add a package

```bash
# asdf source-add <name> <git-url>
asdf source-add erlang https://github.com/HashNuke/asdf-erlang.git
```

#### Remove a source

```bash
# asdf source-remove <name>
asdf source-remove erlang
```


#### Update sources

```bash
# To update all sources
asdf source-update --all
```

If you want to update a specific package, just say so.

```bash
# asdf source-update <name>
asdf source-update erlang
```

## Manage packages

```bash
# asdf install <name> <version>
asdf install erlang 17.3

# asdf uninstall <name> <version>
asdf uninstall erlang 17.3
```

#### Lists installed versions

```bash
# asdf list <name>
asdf list erlang
```

#### List all available versions

```bash
# asdf list-all <name>
asdf list-all erlang
```

#### Use a specific version of a package

```bash
# asdf use <name> <version>
asdf use erlang 17.3
```

It writes the version to the `.versions` file in the current working directory.


## The `.versions` file

Add a `.versions` file to your project dir and versions of those packages will be used.

```
elixir 1.0.2
erlang 17.3
```


## Creating package sources

A package source is a git repo, with the following executable scripts

* `bin/list-all` - lists all installable versions
* `bin/install` - installs the specified version
* `bin/list-executables` - list executables for the version of the package

#### Options scripts

* `bin/exec-env` - whatever you want to run when a specific version is used (like set an env var?)
* `bin/uninstall` - uninstalls the specified version

### bin/list-all

Must print a string with a space-seperated list of versions. Example output would be the following:

```
1.0.1 1.0.2 1.3.0 1.4
```

### bin/install

This script should install the package. It will be passed the following command-line args (in order).

* *install type* - "version", "tag", "commit"
* *version* - this is the version or commit sha or the tag name that should be installed (use the first argument to figure out what to do).
* *install path* - the dir where the it *should* be installed

**Any other args that comes after this is whatever the user passes to the install command**. Feel free to use them in whatever way you think is appropriate.

These scripts are run when `list-all`, `install`, `uninstall` or `exec-env` commands are run. You can set or unset env vars and do whatever you need.

### bin/list-executables

Must print a string with a space-seperated list of paths to executables. The paths must be relative to the install path passed. Example output would be:

```
bin/abc bin/xyz scripts/jkl
```

### bin/exec-env

Will be passed the following args

* *install type*
* *version*

Must print a string with space-seperated list of env vars to set. Example output would be

### bin/uninstall

Uninstalls a command. Same args as the `bin/install` script.

```
FOO=123 BAR=xyz BAZ=example
```

## Credits

Me ([@HashNuke](http://github.com/HashNuke)), High-fever, cold, cough

Copyright 2014 to the end of time

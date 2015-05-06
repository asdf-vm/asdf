# asdf
### _extendable version manager_

> Feel free to add support for the language you want. There is a [simple API](https://github.com/HashNuke/asdf/blob/master/docs/creating-package-sources.md) for it. For now, I've added support for the following languages:

> * [Ruby](#TODO)
> * [Erlang](https://github.com/HashNuke/asdf-erlang)
> * [Elixir](https://github.com/HashNuke/asdf-elixir)
>
> -- [@HashNuke](https://twitter.com/HashNuke)

[![Support via Gratipay](https://cdn.rawgit.com/gratipay/gratipay-badge/2.3.0/dist/gratipay.png)](https://gratipay.com/HashNuke/)

---

## Install

Copy-paste the following into command line:

```bash
git clone https://github.com/HashNuke/asdf.git ~/.asdf
echo 'export PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"' >> ~/.bash_profile
```

**That's all ~! You are ready to use asdf**

It clones the adsf-related dirs to your `$PATH` in `~/.bash_profile`. If you use a different shell, replace the filename appropriately.


## Manage sources

Sources are how asdf understands how to handle packages.


#### Add a package

```bash
# asdf source-add <name> <git-url>
asdf add-source erlang https://github.com/HashNuke/asdf-erlang.git
```

#### Remove a source

```bash
# asdf source-remove <name>
asdf remove-source erlang
```


#### Update sources

```bash
# To update all sources
asdf update-source --all
```

If you want to update a specific package, just say so.

```bash
# asdf source-update <name>
asdf update-source erlang
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

## Credits

Me ([@HashNuke](http://github.com/HashNuke)), High-fever, cold, cough.

Copyright 2014 to the end of time

-------

Read the [ballad](https://github.com/HashNuke/asdf/blob/master/ballad-of-asdf.md).

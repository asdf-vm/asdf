# asdf version manager

> for everything that needs a version manager


## Commands

asdf install <package> <version>
asdf uninstall <package> <version>
asdf list <package>
asdf list-all <package>
asdf use <package> <version>
asdf source-add <package> <source>
asdf source-remove <package>
asdf source-update --all
asdf source-update <package>


## `.versions` file

```
elixir 1.0.0
erlang 17.3
```


## Package source structure

A package source is a git repo, with the following executable scripts

* `bin/list-all` - lists all installable versions
* `bin/install` - installs the specified version
* `bin/uninstall` - uninstalls the specified version
* `bin/use` - uses the specified version (and also adds the version to `.versions` file in the dir)


These scripts are run when `list-all`, `install`, `uninstall` or `use` commands are run. You can set or unset env vars,

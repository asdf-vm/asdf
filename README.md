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
asdf source-update
asdf source-update <package>

## `.asdf-versions` file

```
elixir 1.0.0
erlang 17.3
```


## Package source structure

A package source is a git repo, with the following files

* `bin/install`
* `bin/uninstall`
* `bin/use`

These scripts are run when `package install`, `package uninstall` or `package use` commands are run. You can set or unset env vars,

## Creating plugins

A plugin is a git repo, with a couple executable scripts, to support versioning another language or tool. These scripts are run when `list-all`, `install` or `uninstall` commands are run. You can set or unset env vars and do anything required to setup the environment for the tool.

### Required scripts

* `bin/list-all` - lists all installable versions
* `bin/install` - installs the specified version


All scripts except `bin/list-all` will have access to the following env vars to act upon:

* `ASDF_INSTALL_TYPE` - `version` or `ref`
* `ASDF_INSTALL_VERSION` - if `ASDF_INSTALL_TYPE` is `version` then this will be the version number. Else it will be the git ref that is passed. Might point to a tag/commit/branch on the repo.
* `ASDF_INSTALL_PATH` - the dir where the it *has been* installed (or *should* be installed in case of the `bin/install` script)


#### bin/list-all

Must print a string with a space-seperated list of versions. Example output would be the following:

```
1.0.1 1.0.2 1.3.0 1.4
```

#### bin/install

This script should install the version, in the path mentioned in `ASDF_INSTALL_PATH`


### Optional scripts

#### bin/list-bin-paths

List executables for the specified version of the tool. Must print a string with a space-seperated list of dir paths that contain executables. The paths must be relative to the install path passed. Example output would be:

```
bin tools veggies
```

This will instruct asdf to create shims for the files in `<install-path>/bin`, `<install-path>/tools` and `<install-path>/veggies`

If this script is not specified, asdf will look for the `bin` dir in an installation and create shims for those.

#### bin/exec-env

Setup the env to run the binaries in the package.

#### bin/uninstall

Uninstalls a specific version of a tool.

#### bin/get_version_from_legacy_file

Prints the version of the tool to use if a legacy version file is found in the current directory (e.g. rbenv's `.ruby-version`). Current directory is passed as the only argument to this script.

### Custom shim templates

**PLEASE use this feature only if absolutely required**

asdf allows custom shim templates. For an executable called `foo`, if there's a `shims/foo` file in the plugin, then asdf will copy that file instead of using it's standard shim template.

This must be used wisely. For now AFAIK, it's only being used in the Elixir plugin, because an executable is also read as an Elixir file apart from just being an executable. Which makes it not possible to use the standard bash shim.

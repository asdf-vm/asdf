## Creating package sources

A package source is a git repo, with a couple executable scripts. These scripts are run when `list-all`, `install`, `uninstall` or `exec-env` commands are run. You can set or unset env vars and do anything required to setup the environment for the tool.

### Required scripts

* `bin/list-all` - lists all installable versions
* `bin/install` - installs the specified version

##### bin/list-all

Must print a string with a space-seperated list of versions. Example output would be the following:

```
1.0.1 1.0.2 1.3.0 1.4
```

##### bin/install

This script should install the package. It will be passed the following command-line args (in order).

* *install type* - "version", "tag", "commit"
* *version* - this is the version or commit sha or the tag name that should be installed (use the first argument to figure out what to do).
* *install path* - the dir where the it *should* be installed


### Optional scripts

* `bin/list-bin-paths` - list executables for the version of the package
* `bin/exec-env` - `echo` a space separated list of "key1=value1 key2=value2" and asdf will set them before running your command
* `bin/uninstall` - uninstalls the specified version


##### bin/list-bin-paths

Must print a string with a space-seperated list of dir paths that contain executables. The paths must be relative to the install path passed. Example output would be:

```
bin tools veggies
```

Shims will be automatically created for each of the binaries/executables. If this script is not specified, asdf will look for the `bin` dir in an installation and create shims for those.

##### bin/exec-env

Will be passed the following args

* *install type*
* *version*

Must print a string with space-seperated list of env vars to set. Example output would be

##### bin/uninstall

Uninstalls a specific version of a tool. Same args as the `bin/install` script.

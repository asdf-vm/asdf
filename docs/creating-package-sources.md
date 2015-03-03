## Creating package sources

A package source is a git repo, with the following executable scripts

* `bin/list-all` - lists all installable versions
* `bin/install` - installs the specified version
* `bin/list-executables` - list executables for the version of the package

##### Options scripts

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

If you need to provide any options, use environment variables.

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

-------------

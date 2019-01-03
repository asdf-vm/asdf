## What's in a Plugin

A plugin is a git repo, with a couple executable scripts, to support versioning another language or tool. These scripts are run when `list-all`, `install` or `uninstall` commands are run. You can set or unset env vars and do anything required to setup the environment for the tool.

## Required Scripts

- `bin/list-all` - lists all installable versions
- `bin/install` - installs the specified version

All scripts except `bin/list-all` will have access to the following env vars to act upon:

- `ASDF_INSTALL_TYPE` - `version` or `ref`
- `ASDF_INSTALL_VERSION` - if `ASDF_INSTALL_TYPE` is `version` then this will be the version number. Else it will be the git ref that is passed. Might point to a tag/commit/branch on the repo.
- `ASDF_INSTALL_PATH` - the dir where the it _has been_ installed (or _should_ be installed in case of the `bin/install` script)

These additional environment variables the `bin/install` script will also have accesss to:

- `ASDF_CONCURRENCY` - the number of cores to use when compiling the source code. Useful for setting `make -j`.

#### bin/list-all

Must print a string with a space-separated list of versions. Example output would be the following:

```
1.0.1 1.0.2 1.3.0 1.4
```

Note that the newest version should be listed last so it appears closer to the user's prompt. This is helpful since the `list-all` command prints each version on it's own line. If there are many versions it's possible the early versions will be off screen.

If versions are being pulled from releases page on a website it's recommended to not sort the versions if at all possible. Often the versions are already in the correct order or, in reverse order, in which case something like `tac` should suffice. If you must sort versions manually you cannot rely on `sort -V` since it is not supported on OSX. An alternate sort function [like this is a better choice](https://github.com/vic/asdf-idris/blob/master/bin/list-all#L6).

#### bin/install

This script should install the version, in the path mentioned in `ASDF_INSTALL_PATH`.

The install script should exit with a status of `0` when the installation is successful. If the installation fails the script should exit with any non-zero exit status.

If possible the script should only place files in the `ASDF_INSTALL_PATH` directory once the build and installation of the tool is deemed successful by the install script. asdf [checks for the existence](https://github.com/asdf-vm/asdf/blob/242d132afbf710fe3c7ec23c68cec7bdd2c78ab5/lib/utils.sh#L44) of the `ASDF_INSTALL_PATH` directory in order to determine if that version of the tool is installed. If the `ASDF_INSTALL_PATH` directory is populated at the beginning of the installation process other asdf commands run in other terminals during the installation may consider that version of the tool installed, even when it is not fully installed.

## Optional Scripts

#### bin/list-bin-paths

List executables for the specified version of the tool. Must print a string with a space-separated list of dir paths that contain executables. The paths must be relative to the install path passed. Example output would be:

```
bin tools veggies
```

This will instruct asdf to create shims for the files in `<install-path>/bin`, `<install-path>/tools` and `<install-path>/veggies`

If this script is not specified, asdf will look for the `bin` dir in an installation and create shims for those.

#### bin/exec-env

Setup the env to run the binaries in the package.

#### bin/exec-path

Get the executable path for the specified version of the tool. Must print a string with the relative executable path. This allows the plugin to conditionally override the shim's specified executable path, otherwise return the default path specified by the shim.

```
Usage:
  plugin/bin/exec-path <install-path> <command> <executable-path>

Example Call:
  ~/.asdf/plugins/foo/bin/exec-path "~/.asdf/installs/foo/1.0" "foo" "bin/foo"

Output:
  bin/foox
```

#### bin/uninstall

Uninstalls a specific version of a tool.

#### bin/list-legacy-filenames

Register additional setter files for this plugin. Must print a string with a space-separated list of filenames.

```
.ruby-version .rvmrc
```

Note: This will only apply for users who have enabled the `legacy_version_file` option in their `~/.asdfrc`.

#### bin/parse-legacy-file

This can be used to further parse the legacy file found by asdf. If `parse-legacy-file` isn't implemented, asdf will simply cat the file to determine the version. The script will be passed the file path as its first argument.

## Custom shim templates

**PLEASE use this feature only if absolutely required**

asdf allows custom shim templates. For an executable called `foo`, if there's a `shims/foo` file in the plugin, then asdf will copy that file instead of using it's standard shim template.

This must be used wisely. For now AFAIK, it's only being used in the Elixir plugin, because an executable is also read as an Elixir file apart from just being an executable. Which makes it not possible to use the standard bash shim.

**Important: Shim metadata**

If you create a custom shim, be sure to include a comment like the following (replacing your plugin name) in it:

```
# asdf-plugin: plugin_name
```

asdf uses this `asdf-plugin` metadata to remove unused shims when uninstalling.

## Testing plugins

`asdf` contains the `plugin-test` command to test your plugin. You can use it as follows

```sh
asdf plugin-test <plugin-name> <plugin-url> [test-command] [--asdf-tool-version version]
```

The two first arguments are required. The second two arguments are optional. The third is a command can also be passed to check it runs correctly. For example to test the NodeJS plugin, we could run

```sh
asdf plugin-test nodejs https://github.com/asdf-vm/asdf-nodejs.git 'node --version'
```

The fourth is a tool version that can be specified if you want the test to install a specific version of the tool. This can be useful if not all versions are compatible with all the operating systems you are testing on. If you do not specify a version the last version in the `list-all` output will be used.

We strongly recommend you test your plugin on TravisCI, to make sure it works on both Linux and OSX.

Here is a sample `.travis.yml` file, customize it to your needs

```yaml
language: c
script: asdf plugin-test nodejs $TRAVIS_BUILD_DIR 'node --version'
before_script:
  - git clone https://github.com/asdf-vm/asdf.git asdf
  - . asdf/asdf.sh
os:
  - linux
  - osx
```

Note:
When using another CI, you will need to check what variable maps to the repo path.

You also have the option to pass a relative path to `plugin-test`.

For example, if the test script is ran in the repo directory: `asdf plugin-test nodejs . 'node --version'`.

## GitHub API Rate Limiting

If your plugin's `list-all` depends on accessing the GitHub API, make sure you provide an Authorization token when accessing it, otherwise your tests might fail due to rate limiting.

To do so, create a [new personal token](https://github.com/settings/tokens/new) with only `public_repo` access.

Then on your travis.ci build settings add a _secure_ environment variable for it named something like `GITHUB_API_TOKEN`. And _DO NOT_ EVER publish your token in your code.

Finally, add something like the following to `bin/list-all`

```shell
cmd="curl -s"
if [ -n "$GITHUB_API_TOKEN" ]; then
 cmd="$cmd -H 'Authorization: token $GITHUB_API_TOKEN'"
fi

cmd="$cmd $releases_path"
```

## Submitting plugins to the official plugins repository

`asdf` can easily install plugins by specifying the plugin repository url, e.g. `plugin-add my-plugin https://github.com/user/asdf-my-plugin.git`.

To make it easier on your users, you can add your plugin to the official plugins repository to have your plugin listed and easily installable using a shorter command, e.g. `asdf plugin-add my-plugin`.

Follow the instruction at the plugins repository: [asdf-vm/asdf-plugins](https://github.com/asdf-vm/asdf-plugins).

# Create a Plugin

## What's in a Plugin

A plugin is a git repo, with a couple executable scripts, to support versioning another language or tool. These scripts are run when `list-all`, `install` or `uninstall` commands are run. You can set or unset env vars and do anything required to setup the environment for the tool.

## Required Scripts

- `bin/list-all` - lists all installable versions
- `bin/download` - download source code or binary for the specified version
- `bin/install` - installs the specified version

## Environment Variables

All scripts except `bin/list-all` will have access to the following env vars to act upon:

- `ASDF_INSTALL_TYPE` - `version` or `ref`
- `ASDF_INSTALL_VERSION` - if `ASDF_INSTALL_TYPE` is `version` then this will be the version number. Else it will be the git ref that is passed. Might point to a tag/commit/branch on the repo.
- `ASDF_INSTALL_PATH` - the dir where the it _has been_ installed (or _should_ be installed in case of the `bin/install` script)

These additional environment variables will be available to the `bin/install` script:

- `ASDF_CONCURRENCY` - the number of cores to use when compiling the source code. Useful for setting `make -j`.
- `ASDF_DOWNLOAD_PATH` - the path to where the source code or binary was downloaded by the `bin/download` script.

These additional environment variables will be available to the `bin/download` script:

- `ASDF_DOWNLOAD_PATH` - the path to where the source code or binary should be downloaded.

#### bin/list-all

Must print a string with a space-separated list of versions. Example output would be the following:

```shell
1.0.1 1.0.2 1.3.0 1.4
```

Note that the newest version should be listed last so it appears closer to the user's prompt. This is helpful since the `list-all` command prints each version on it's own line. If there are many versions it's possible the early versions will be off screen.

If versions are being pulled from releases page on a website it's recommended to not sort the versions if at all possible. Often the versions are already in the correct order or, in reverse order, in which case something like `tac` should suffice. If you must sort versions manually you cannot rely on `sort -V` since it is not supported on OSX. An alternate sort function [like this is a better choice](https://github.com/vic/asdf-idris/blob/master/bin/list-all#L6).

#### bin/download

This script must download the source or binary, in the path contained in the `ASDF_DOWNLOAD_PATH` environment variable. If the downloaded source or binary is compressed, only the uncompressed source code or binary may be placed in the `ASDF_DOWNLOAD_PATH` directory.

The script must exit with a status of `0` when the download is successful. If the download fails the script must exit with any non-zero exit status.

If possible the script should only place files in the `ASDF_DOWNLOAD_PATH`. If the download fails no files should be placed in the directory.

If this script is not present asdf will assume that the `bin/install` script is present and will download and install the version. asdf only works without this script to support legacy plugins. All plugins must include this script, and eventually support for legacy plugins will be removed.

#### bin/install

This script should install the version, in the path mentioned in `ASDF_INSTALL_PATH`. By default, asdf will create shims for any files in `$ASDF_INSTALL_PATH/bin` (this can be customized with the optional [bin/list-bin-paths](#binlist-bin-paths) script).

The install script should exit with a status of `0` when the installation is successful. If the installation fails the script should exit with any non-zero exit status.

If possible the script should only place files in the `ASDF_INSTALL_PATH` directory once the build and installation of the tool is deemed successful by the install script. asdf [checks for the existence](https://github.com/asdf-vm/asdf/blob/242d132afbf710fe3c7ec23c68cec7bdd2c78ab5/lib/utils.sh#L44) of the `ASDF_INSTALL_PATH` directory in order to determine if that version of the tool is installed. If the `ASDF_INSTALL_PATH` directory is populated at the beginning of the installation process other asdf commands run in other terminals during the installation may consider that version of the tool installed, even when it is not fully installed.

If you want your plugin to work with asdf version 0.7._ and earlier and version 0.8._ and newer check for the presence of the `ASDF_DOWNLOAD_PATH` environment variable. If it is not set download the source code in the bin/install callback. If it is set assume the `bin/download` script already downloaded it.

## Optional Scripts

#### bin/help scripts

This is not one callback script but rather a set of callback scripts that each print different documentation to STDOUT. The possible callback scripts are listed below. Note that `bin/help.overview` is a special case as it must be present for any help output to be displayed for the script.

- `bin/help.overview` - This script should output a general description about the plugin and the tool being managed. No heading should be printed as asdf will print headings. Output may be free-form text but ideally only one short paragraph. This script must be present if you want asdf to provide help information for your plugin. All other help callback scripts are optional.
- `bin/help.deps` - This script should output the list of dependencies tailored to the operating system. One dependency per line.
- `bin/help.config` - This script should print any required or optional configuration that may be available for the plugin and tool. Any environment variables or other flags needed to install or compile the tool (for the users operating system when possible). Output can be free-form text.
- `bin/help.links` - This should be a list of links relevant to the plugin and tool (again, tailored to the current operating system when possible). One link per line. Lines may be in the format `<title>: <link>` or just `<link>`.

Each of these scripts should tailor their output to the current operating system. For example, when on Ubuntu the deps script could output the dependencies as apt-get packages that must be installed. The script should also tailor its output to the value of `ASDF_INSTALL_VERSION` and `ASDF_INSTALL_TYPE` when the variables are set. They are optional and will not always be set.

The help callback script MUST NOT output any information that is already covered in the core asdf-vm documentation. General asdf usage information must not be present.

#### bin/latest-stable

If this callback is implemented asdf will use it to determine the latest stable version of your tool instead of trying deduce it for you on its own. `asdf latest` deduces the latest version by looking at the last version printed by the `list-all` callback, after a few types of versions (like release candidate versions) are excluded from the output. This default behavior is undesirable when your plugin's `list-all` callback prints different variations of the same tool and the last version isn't the latest stable version of the variation you'd like to default to. For example with Ruby the latest stable version should be the regular implementation of Ruby (MRI), but truffleruby versions are printed last by the `list-all` callback.

This callback is invoked with a single "filter" string as it's only argument. This should be used for filter all latest stable versions. For example with Ruby, the user may choose to pass in `jruby` to select the latest stable version of `jruby`.

#### bin/list-bin-paths

List executables for the specified version of the tool. Must print a string with a space-separated list of dir paths that contain executables. The paths must be relative to the install path passed. Example output would be:

```shell
bin tools veggies
```

This will instruct asdf to create shims for the files in `<install-path>/bin`, `<install-path>/tools` and `<install-path>/veggies`

If this script is not specified, asdf will look for the `bin` dir in an installation and create shims for those.

#### bin/exec-env

Setup the env to run the binaries in the package.

#### bin/exec-path

Get the executable path for the specified version of the tool. Must print a string with the relative executable path. This allows the plugin to conditionally override the shim's specified executable path, otherwise return the default path specified by the shim.

```shell
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

```shell
.ruby-version .rvmrc
```

Note: This will only apply for users who have enabled the `legacy_version_file` option in their `~/.asdfrc`.

#### bin/parse-legacy-file

This can be used to further parse the legacy file found by asdf. If `parse-legacy-file` isn't implemented, asdf will simply cat the file to determine the version. The script will be passed the file path as its first argument.

#### bin/post-plugin-add

This can be used to run any post-installation actions after the plugin has been added to asdf.

The script has access to the path the plugin was installed (`${ASDF_PLUGIN_PATH}`) and the source URL (`${ASDF_PLUGIN_SOURCE_URL}`), if any was used.

See also the related hooks:

- `pre_asdf_plugin_add`
- `pre_asdf_plugin_add_${plugin_name}`
- `post_asdf_plugin_add`
- `post_asdf_plugin_add_${plugin_name}`

#### bin/post-plugin-update

This can be used to run any post-plugin-update actions after asdf has downloaded the updated plugin

The script has access to the path the plugin was installed (`${ASDF_PLUGIN_PATH}`), previous git-ref (`${ASDF_PLUGIN_PREV_REF}`), and updated git-ref (`${ASDF_PLUGIN_POST_REF}`).

See also the related hooks:

- `pre_asdf_plugin_updated`
- `pre_asdf_plugin_updated_${plugin_name}`
- `post_asdf_plugin_updated`
- `post_asdf_plugin_updated_${plugin_name}`

#### bin/pre-plugin-remove

This can be used to run any pre-removal actions before the plugin will be removed from asdf.

The script has access to the path the plugin was installed in (`${ASDF_PLUGIN_PATH}`).

See also the related hooks:

- `pre_asdf_plugin_remove`
- `pre_asdf_plugin_remove_${plugin_name}`
- `post_asdf_plugin_remove`
- `post_asdf_plugin_remove_${plugin_name}`

## Extension commands for asdf CLI.

It's possible for plugins to define new asdf commands by providing `lib/commands/command*.bash` scripts or executables that
will be callable using the asdf command line interface by using the plugin name as a subcommand.

For example, suppose a `foo` plugin has:

```shell
foo/
  lib/commands/
    command.bash
    command-bat.bash
    command-bat-man.bash
    command-help.bash
```

Users can now execute

```shell
$ asdf foo         # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash`
$ asdf foo bar     # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash bar`
$ asdf foo help    # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-help.bash`
$ asdf foo bat man # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat-man.bash`
$ asdf foo bat baz # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat.bash baz`
```

Plugin authors can use this feature to provide utilities related to their tools,
or even create plugins that are just new command extensions for asdf itself.

When invoked, if extension commands do not have their executable-bit set, they will be
sourced as bash scripts, having all of the functions from `$ASDF_DIR/lib/utils.bash` available.
Also, the `$ASDF_CMD_FILE` resolves to the full path of the file being sourced.
If the executable bit is set, they are just executed and replace the asdf execution.

A good example of this feature is for plugins like [`haxe`](https://github.com/asdf-community/asdf-haxe)
which provides the `asdf haxe neko-dylibs-link` to fix an issue where haxe executables expect to find
dynamic libraries relative to the executable directory.

If your plugin provides an asdf extension command, be sure to mention about it on your plugin's README.

## Custom shim templates

**PLEASE use this feature only if absolutely required**

asdf allows custom shim templates. For an executable called `foo`, if there's a `shims/foo` file in the plugin, then asdf will copy that file instead of using it's standard shim template.

This must be used wisely. For now AFAIK, it's only being used in the Elixir plugin, because an executable is also read as an Elixir file apart from just being an executable. Which makes it not possible to use the standard bash shim.

## Testing plugins

`asdf` contains the `plugin-test` command to test your plugin. You can use it as follows

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]
```

Only the two first arguments are required.
If \__version_ is specified, the tool will be installed with that specific version. Defaults to whatever returns `asdf latest <plugin-name>`.
If _git-ref_ is specified, the plugin itself is checked out at that commit/branch/tag, useful for testing a pull-request on your plugin's CI.

Rest arguments are considered the command to execute to ensure the installed tool works correctly.
Normally it would be something that takes `--version` or `--help`.
For example, to test the NodeJS plugin, we could run

```shell
asdf plugin test nodejs https://github.com/asdf-vm/asdf-nodejs.git node --version
```

We strongly recommend you test your plugin on a CI environment and make sure it works on both Linux and OSX.

#### Example GitHub Action

The [asdf-vm/actions](https://github.com/asdf-vm/actions) repo provides a GitHub Action for testing your plugins hosted on github.

```yaml
steps:
  - name: asdf_plugin_test
    uses: asdf-vm/actions/plugin-test@v1
    with:
      command: "my_tool --version"
    env:
      GITHUB_API_TOKEN: ${{ secrets.GITHUB_TOKEN }} # automatically provided
```

#### Example TravisCI config

Here is a sample `.travis.yml` file, customize it to your needs

```yaml
language: c
script: asdf plugin test nodejs $TRAVIS_BUILD_DIR 'node --version'
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

For example, if the test script is ran in the repo directory: `asdf plugin test nodejs . 'node --version'`.

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

`asdf` can easily install plugins by specifying the plugin repository url, e.g. `plugin add my-plugin https://github.com/user/asdf-my-plugin.git`.

To make it easier on your users, you can add your plugin to the official plugins repository to have your plugin listed and easily installable using a shorter command, e.g. `asdf plugin add my-plugin`.

Follow the instruction at the plugins repository: [asdf-vm/asdf-plugins](https://github.com/asdf-vm/asdf-plugins).

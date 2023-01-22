# Create a Plugin

A plugin is a Git repo with some executable scripts to support versioning a
language / tool. These scripts are run by asdf using specific commands to
support features such as `asdf list-all <name>`, `asdf install <name> <version>`
etc.

## Quickstart

There are two options to get started with creating your own plugin:

1. use the
   [asdf-vm/asdf-plugin-template](https://github.com/asdf-vm/asdf-plugin-template)
   repository to
   [generate](https://github.com/asdf-vm/asdf-plugin-template/generate) a plugin
   repo (named `asdf-<tool_name>`) with default scripts implemented. Once
   generated, clone the repo and run the `setup.bash` script to interactively
   update the template.
2. start your own repo called `asdf-<tool_name>` and implement the required
   scripts as listed in the documentation below.

### Golden Rules for Plugin Scripts

- scripts should **NOT** call other `asdf` commands
- keep your dependency list of Shell tools/commands small
- avoid non-portable tools or command flags. For example, `sort -V`. See our
  asdf core
  [list of banned commands](https://github.com/asdf-vm/asdf/blob/master/test/banned_commands.bats)

## Scripts Overview

The full list of scripts callable from asdf.

<!-- TODO(jthegedus): fill out the overview descriptions -->

| Script                                                                                                | Description                                              |
| :---------------------------------------------------------------------------------------------------- | :------------------------------------------------------- |
| [bin/list-all](#bin-list-all) <Badge type="tip" text="required" vertical="middle" />                  | List all installable versions                            |
| [bin/download](#bin-download) <Badge type="tip" text="required" vertical="middle" />                  | Download source code or binary for the specified version |
| [bin/install](#bin-install) <Badge type="tip" text="required" vertical="middle" />                    | Installs the specified version                           |
| [bin/latest-stable](#bin-latest-stable) <Badge type="warning" text="recommended" vertical="middle" /> | List the latest stable version of the specified tool     |
| [bin/help.overview](#bin-help.overview)                                                               |                                                          |
| [bin/help.deps](#bin-help.deps)                                                                       |                                                          |
| [bin/help.config](#bin-help.config)                                                                   |                                                          |
| [bin/help.links](#bin-help.links)                                                                     |                                                          |
| [bin/list-bin-paths](#bin-list-bin-paths)                                                             |                                                          |
| [bin/exec-env](#bin-exec-env)                                                                         |                                                          |
| [bin/exec-path](#bin-exec-path)                                                                       |                                                          |
| [bin/uninstall](#bin-uninstall)                                                                       |                                                          |
| [bin/list-legacy-filenames](#bin-list-legacy-filenames)                                               |                                                          |
| [bin/parse-legacy-file](#bin-parse-legacy-file)                                                       |                                                          |
| [bin/post-plugin-add](#bin-post-plugin-add)                                                           |                                                          |
| [bin/post-plugin-update](#bin-post-plugin-update)                                                     |                                                          |
| [bin/pre-plugin-remove](#bin-pre-plugin-remove)                                                       |                                                          |

To see which commands invoke which scripts, see the detailed documentation for
each script.

## Environment Variables Overview

The full list of Environment Variables used throughout all scripts.

| Environment Variables    | Description                                                                             |
| :----------------------- | :-------------------------------------------------------------------------------------- |
| `ASDF_INSTALL_TYPE`      | `version` or `ref`                                                                      |
| `ASDF_INSTALL_VERSION`   | full version number or Git Ref depending on `ASDF_INSTALL_TYPE`                         |
| `ASDF_INSTALL_PATH`      | the path to where the tool _should_, or _has been_ installed                            |
| `ASDF_CONCURRENCY`       | the number of cores to use when compiling the source code. Useful for setting `make -j` |
| `ASDF_DOWNLOAD_PATH`     | the path to where the source code or binary was downloaded to in `bin/download`         |
| `ASDF_PLUGIN_PATH`       | the path the plugin was installed                                                       |
| `ASDF_PLUGIN_SOURCE_URL` | the source URL of the plugin                                                            |
| `ASDF_PLUGIN_PREV_REF`   | prevous `git-ref` of the plugin repo                                                    |
| `ASDF_PLUGIN_POST_REF`   | updated `git-ref` of the plugin repo                                                    |
| `ASDF_CMD_FILE`          | resolves to the full path of the file being sourced                                     |

::: tip NOTE

**Not all environment variables are available in all scripts.** Check the
documentation for each script below to see which env vars are available to it.

:::

## Required Scripts

### `bin/list-all` <Badge type="tip" text="required" vertical="middle" />

**Description**

List all installable versions.

**Output Format**

Must print a string with a **space-separated** list of versions. For example:

```text:no-line-numbers
1.0.1 1.0.2 1.3.0 1.4
```

Newest version should be last.

asdf core will print each version on its own line, potentially pushing some
versions offscreen.

**Sorting**

If versions are being pulled from releases page on a website it's recommended to
leave the versions in the provided order as they are often already in the
correct order. If they are in reverse order piping them through `tac` should
suffice.

If sorting is unavoidable, `sort -V` is not portable, so we suggest either:

- [using the Git sort capability](https://github.com/asdf-vm/asdf-plugin-template/blob/main/template/lib/utils.bash)
  (requires Git >= `v2.18.0`)
- [writing a custom sort method](https://github.com/vic/asdf-idris/blob/master/bin/list-all#L6)
  (requires `sed`, `sort` & `awk`)

**Environment Variables available to script**

No environment variables are provided to this script.

**Commands that invoke this script**

- `asdf list all <name> [version]`
- `asdf list all nodejs`: lists all versions as returned by this script, one on
  each line.
- `asdf list all nodejs 18`: lists all versions as returned by this script, one
  on each line, with a filter matching any version beginning with `18` applied.

**Call signature from asdf core**

No parameteres provided.

```bash:no-line-numbers
"${plugin_path}/bin/list-all"
```

---

<!-- TODO(jthegedus): rework from bin/download to bin/pre-plugin-remove -->

### `bin/download` <Badge type="tip" text="required" vertical="middle" />

This script must download the source or binary, in the path contained in the
`ASDF_DOWNLOAD_PATH` environment variable. If the downloaded source or binary is
compressed, only the uncompressed source code or binary may be placed in the
`ASDF_DOWNLOAD_PATH` directory.

The script must exit with a status of `0` when the download is successful. If
the download fails the script must exit with any non-zero exit status.

If possible the script should only place files in the `ASDF_DOWNLOAD_PATH`. If
the download fails no files should be placed in the directory.

If this script is not present asdf will assume that the `bin/install` script is
present and will download and install the version. asdf only works without this
script to support legacy plugins. All plugins must include this script, and
eventually support for legacy plugins will be removed.

**Description**

**Environment Variables available to script**

- ``:
- ``:
- ``:

**Commands that invoke this script**

**Call signature from asdf core**

---

### `bin/install` <Badge type="tip" text="required" vertical="middle" />

This script should install the version, in the path mentioned in
`ASDF_INSTALL_PATH`. By default, asdf will create shims for any files in
`$ASDF_INSTALL_PATH/bin` (this can be customized with the optional
[bin/list-bin-paths](#binlist-bin-paths) script).

The install script should exit with a status of `0` when the installation is
successful. If the installation fails the script should exit with any non-zero
exit status.

If possible the script should only place files in the `ASDF_INSTALL_PATH`
directory once the build and installation of the tool is deemed successful by
the install script. asdf
[checks for the existence](https://github.com/asdf-vm/asdf/blob/242d132afbf710fe3c7ec23c68cec7bdd2c78ab5/lib/utils.sh#L44)
of the `ASDF_INSTALL_PATH` directory in order to determine if that version of
the tool is installed. If the `ASDF_INSTALL_PATH` directory is populated at the
beginning of the installation process other asdf commands run in other terminals
during the installation may consider that version of the tool installed, even
when it is not fully installed.

If you want your plugin to work with asdf version 0.7._ and earlier and version
0.8._ and newer check for the presence of the `ASDF_DOWNLOAD_PATH` environment
variable. If it is not set download the source code in the bin/install callback.
If it is set assume the `bin/download` script already downloaded it.

## Optional Scripts

### `bin/latest-stable` <Badge type="warning" text="recommended" vertical="middle" />

If this callback is implemented asdf will use it to determine the latest stable
version of your tool instead of trying deduce it for you on its own.
`asdf latest` deduces the latest version by looking at the last version printed
by the `list-all` callback, after a few types of versions (like release
candidate versions) are excluded from the output. This default behavior is
undesirable when your plugin's `list-all` callback prints different variations
of the same tool and the last version isn't the latest stable version of the
variation you'd like to default to. For example with Ruby the latest stable
version should be the regular implementation of Ruby (MRI), but truffleruby
versions are printed last by the `list-all` callback.

This callback is invoked with a single "filter" string as its only argument.
This should be used for filter all latest stable versions. For example with
Ruby, the user may choose to pass in `jruby` to select the latest stable version
of `jruby`.

<!-- TODO(jthegedus): removed information -->

<!-- Each of these scripts should tailor their output to the current operating
system. For example, when on Ubuntu the deps script could output the
dependencies as apt-get packages that must be installed. The script should also
tailor its output to the value of `ASDF_INSTALL_VERSION` and `ASDF_INSTALL_TYPE`
when the variables are set. They are optional and will not always be set.

The help callback script MUST NOT output any information that is already covered
in the core asdf-vm documentation. General asdf usage information must not be
present. -->

---

### `bin/help.overview`

`bin/help.overview` - This script should output a general description about the
plugin and the tool being managed. No heading should be printed as asdf will
print headings. Output may be free-form text but ideally only one short
paragraph. This script must be present if you want asdf to provide help
information for your plugin. All other help callback scripts are optional.

This is not one callback script but rather a set of callback scripts that each
print different documentation to STDOUT. The possible callback scripts are
listed below. Note that `bin/help.overview` is a special case as it must be
present for any help output to be displayed for the script.

---

### `bin/help.deps`

<!-- TODO(jthegedus): note, this script requires bin/help.overview -->

This script should output the list of dependencies tailored to the operating
system. One dependency per line.

---

### `bin/help.config`

<!-- TODO(jthegedus): note, this script requires bin/help.overview -->

This script should print any required or optional configuration that may be
available for the plugin and tool. Any environment variables or other flags
needed to install or compile the tool (for the users operating system when
possible). Output can be free-form text.

---

### `bin/help.links`

<!-- TODO(jthegedus): note, this script requires bin/help.overview -->

This should be a list of links relevant to the plugin and tool (again, tailored
to the current operating system when possible). One link per line. Lines may be
in the format `<title>: <link>` or just `<link>`.

---

### `bin/list-bin-paths`

List executables for the specified version of the tool. Must print a string with
a space-separated list of dir paths that contain executables. The paths must be
relative to the install path passed. Example output would be:

```shell
bin tools veggies
```

This will instruct asdf to create shims for the files in `<install-path>/bin`,
`<install-path>/tools` and `<install-path>/veggies`

If this script is not specified, asdf will look for the `bin` dir in an
installation and create shims for those.

---

### `bin/exec-env`

Setup the env to run the binaries in the package.

---

### `bin/exec-path`

Get the executable path for the specified version of the tool. Must print a
string with the relative executable path. This allows the plugin to
conditionally override the shim's specified executable path, otherwise return
the default path specified by the shim.

```shell
Usage:
  plugin/bin/exec-path <install-path> <command> <executable-path>

Example Call:
  ~/.asdf/plugins/foo/bin/exec-path "~/.asdf/installs/foo/1.0" "foo" "bin/foo"

Output:
  bin/foox
```

---

### `bin/uninstall`

Uninstalls a specific version of a tool.

---

### `bin/list-legacy-filenames`

Register additional setter files for this plugin. Must print a string with a
space-separated list of filenames.

```shell
.ruby-version .rvmrc
```

Note: This will only apply for users who have enabled the `legacy_version_file`
option in their `~/.asdfrc`.

---

### `bin/parse-legacy-file`

This can be used to further parse the legacy file found by asdf. If
`parse-legacy-file` isn't implemented, asdf will simply `cat` the file to
determine the version. The script will be passed the file path as its first
argument. Note that this script should be **deterministic** and always return
the same exact version when parsing the same legacy file. The script should
return the same version regardless of what is installed on the machine or
whether the legacy version is valid or complete. Some legacy file formats may
not be suitable.

---

### `bin/post-plugin-add`

This can be used to run any post-installation actions after the plugin has been
added to asdf.

The script has access to the path the plugin was installed
(`${ASDF_PLUGIN_PATH}`) and the source URL (`${ASDF_PLUGIN_SOURCE_URL}`), if any
was used.

See also the related hooks:

- `pre_asdf_plugin_add`
- `pre_asdf_plugin_add_${plugin_name}`
- `post_asdf_plugin_add`
- `post_asdf_plugin_add_${plugin_name}`

---

### `bin/post-plugin-update`

This can be used to run any post-plugin-update actions after asdf has downloaded
the updated plugin

The script has access to the path the plugin was installed
(`${ASDF_PLUGIN_PATH}`), previous git-ref (`${ASDF_PLUGIN_PREV_REF}`), and
updated git-ref (`${ASDF_PLUGIN_POST_REF}`).

See also the related hooks:

- `pre_asdf_plugin_updated`
- `pre_asdf_plugin_updated_${plugin_name}`
- `post_asdf_plugin_updated`
- `post_asdf_plugin_updated_${plugin_name}`

---

### `bin/pre-plugin-remove`

This can be used to run any pre-removal actions before the plugin will be
removed from asdf.

The script has access to the path the plugin was installed in
(`${ASDF_PLUGIN_PATH}`).

See also the related hooks:

- `pre_asdf_plugin_remove`
- `pre_asdf_plugin_remove_${plugin_name}`
- `post_asdf_plugin_remove`
- `post_asdf_plugin_remove_${plugin_name}`

<!-- TODO(jthegedus): rework from bin/download to bin/pre-plugin-remove -->
<!-- TODO(jthegedus): NOTE - below here has already been reworked -->

## Extension Commands for asdf CLI <Badge type="danger" text="advanced" vertical="middle" />

It's possible for plugins to define new asdf commands by providing
`lib/commands/command*.bash` scripts or executables that will be callable using
the asdf command line interface by using the plugin name as a subcommand.

For example, suppose a `foo` plugin has:

```shell:no-line-numbers
foo/
  lib/commands/
    command.bash
    command-bat.bash
    command-bat-man.bash
    command-help.bash
```

Users can now execute:

```shell:no-line-numbers
$ asdf foo         # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash`
$ asdf foo bar     # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash bar`
$ asdf foo help    # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-help.bash`
$ asdf foo bat man # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat-man.bash`
$ asdf foo bat baz # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat.bash baz`
```

Plugin authors can use this feature to provide utilities related to their tools,
or even create plugins that are just new command extensions of asdf itself.

If the executable bit is set, the script is executed, replacing the asdf
execution.

If the executable bit is not set, asdf will source the scripts as Bash scripts.

`$ASDF_CMD_FILE` resolves to the full path of the file being sourced.

[`haxe`](https://github.com/asdf-community/asdf-haxe) is a great example of a
plugin which uses this feature. It provides the `asdf haxe neko-dylibs-link` to
fix an issue where Haxe executables expect to find dynamic libraries relative to
the executable directory.

Be sure to list your asdf Extension Commands in your plugins README.

## Custom Shim Templates <Badge type="danger" text="advanced" vertical="middle" />

::: warning

Please only use if **absolutely** required

:::

asdf allows custom shim templates. For an executable called `foo`, if there's a
`shims/foo` file in the plugin, then asdf will copy that file instead of using
its standard shim template.

**This must be used wisely.**

As far as the asdf core team is aware, this feature is only in use in the
first-party [Elixir plugin](https://github.com/asdf-vm/asdf-elixir). This is
because an executable is also read as an Elixir file in addition to being an
executable. This makes it not possible to use the standard Bash shim.

## Testing

`asdf` contains the `plugin-test` command to test your plugin:

```shell:no-line-numbers
asdf plugin test <plugin_name> <plugin_url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git_ref>] [test_command...]
```

- `<plugin_name>` & `<plugin_url>` are required
- If optional `[--asdf-tool-version <version>]` is specified, the tool will be
  installed with that specific version. Defaults to `asdf latest <plugin-name>`
- If optional `[--asdf-plugin-gitref <git_ref>]` is specified, the plugin itself
  is checked out at that commit/branch/tag. This is useful for testing a
  pull-request on your plugin's CI.
- Optional parameter `[test_command...]` is the command to execute to validate
  the installed tool works correctly. Typically `<tool> --version` or
  `<tool> --help`. For example, to test the NodeJS plugin, we could run
  ```shell:no-line-numbers
  # asdf plugin test <plugin_name>  <plugin_url>                               [test_command]
    asdf plugin test nodejs         https://github.com/asdf-vm/asdf-nodejs.git node --version
  ```

::: tip Note

We recommend testing in both Linux & macOS CI environments

:::

### GitHub Action

The [asdf-vm/actions](https://github.com/asdf-vm/actions) repo provides a GitHub
Action for testing your plugins hosted on GitHub. A sample
`.github/workflows/test.yaml` Actions Workflow:

```yaml
name: Test
on:
  push:
    branches:
      - main
  pull_request:

jobs:
  plugin_test:
    name: asdf plugin test
    strategy:
      matrix:
        os:
          - ubuntu-latest
          - macos-latest
    runs-on: ${{ matrix.os }}
    steps:
      - name: asdf_plugin_test
        uses: asdf-vm/actions/plugin-test@v1
        with:
          command: "<MY_TOOL> --version"
```

### TravisCI Config

A sample `.travis.yml` file, customize it to your needs

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

::: tip NOTE

When using another CI you may need to pass a relative path to to the plugin
location:

```shell:no-line-numbers
asdf plugin test <tool_name> <path> '<tool_command> --version'
```

:::

## API Rate Limiting

If a command depends on accessing an external API, like `bin/list-all` or
`bin/latest-stable`, it may experience rate limiting during automated testing.
To mitigate this, ensure there is a code-path which provides an authentication
token via an environment variable. For example:

```shell
cmd="curl --silent"
if [ -n "$GITHUB_API_TOKEN" ]; then
 cmd="$cmd -H 'Authorization: token $GITHUB_API_TOKEN'"
fi

cmd="$cmd $releases_path"
```

### `GITHUB_API_TOKEN`

To utilise the `GITHUB_API_TOKEN`, create a
[new personal token](https://github.com/settings/tokens/new) with only
`public_repo` access.

Then add this to your CI pipeline environment variables.

::: warning

NEVER publish your authentication tokens in your code repository

:::

## Plugin Shortname Index

::: tip

The recommended installation method for a plugin is via direct URL installation:

```shell:no-line-numbers
# asdf plugin add <name> <git_url>
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs
```

:::

If the `git_url` is not provided, asdf will use the
[Shortname Index repository](https://github.com/asdf-vm/asdf-plugins) to
determine the exact `git_url` to use.

You can add your plugin to the
[Shortname Index](https://github.com/asdf-vm/asdf-plugins) by following the
instructions in that repo.

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

| Script                                                                                                | Description                                                      |
| :---------------------------------------------------------------------------------------------------- |:-----------------------------------------------------------------|
| [bin/list-all](#bin-list-all) <Badge type="tip" text="required" vertical="middle" />                  | List all installable versions                                    |
| [bin/download](#bin-download) <Badge type="tip" text="required" vertical="middle" />                  | Download source code or binary for the specified version         |
| [bin/install](#bin-install) <Badge type="tip" text="required" vertical="middle" />                    | Installs the specified version                                   |
| [bin/latest-stable](#bin-latest-stable) <Badge type="warning" text="recommended" vertical="middle" /> | List the latest stable version of the specified tool             |
| [bin/help.overview](#bin-help.overview)                                                               | Output a general description about the plugin & tool             |
| [bin/help.deps](#bin-help.deps)                                                                       | Output a list of dependencies per Operating System               |
| [bin/help.config](#bin-help.config)                                                                   | Output plugin or tool configuration information                  |
| [bin/help.links](#bin-help.links)                                                                     | Output a list of links for the plugin or tool                    |
| [bin/list-bin-paths](#bin-list-bin-paths)                                                             | List relative paths to directories with binaries to create shims |
| [bin/exec-env](#bin-exec-env)                                                                         | Prepare the environment for running the binaries                 |
| [bin/exec-path](#bin-exec-path)                                                                       | Output the executable path for a version of a tool               |
| [bin/uninstall](#bin-uninstall)                                                                       | Uninstall a specific version of a tool                           |
| [bin/list-legacy-filenames](#bin-list-legacy-filenames)                                               | Output filenames of legacy version files: `.ruby-version`        |
| [bin/parse-legacy-file](#bin-parse-legacy-file)                                                       | Custom parser for legacy version files                           |
| [bin/post-plugin-add](#bin-post-plugin-add)                                                           | Hook to execute after a plugin has been added                    |
| [bin/post-plugin-update](#bin-post-plugin-update)                                                     | Hook to execute after a plugin has been updated                  |
| [bin/pre-plugin-remove](#bin-pre-plugin-remove)                                                       | Hook to execute before a plugin is removed                       |

To see which commands invoke which scripts, see the detailed documentation for
each script.

## Environment Variables Overview

The full list of Environment Variables used throughout all scripts.

| Environment Variables    | Description                                                                             |
| :----------------------- |:----------------------------------------------------------------------------------------|
| `ASDF_INSTALL_TYPE`      | `version` or `ref`                                                                      |
| `ASDF_INSTALL_VERSION`   | full version number or Git Ref depending on `ASDF_INSTALL_TYPE`                         |
| `ASDF_INSTALL_PATH`      | the path to where the tool _should_, or _has been_ installed                            |
| `ASDF_CONCURRENCY`       | the number of cores to use when compiling the source code. Useful for setting `make -j` |
| `ASDF_DOWNLOAD_PATH`     | the path to where the source code or binary was downloaded to by `bin/download`         |
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

```txt
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

No parameters provided.

```bash
"${plugin_path}/bin/list-all"
```

---

### `bin/download` <Badge type="tip" text="required" vertical="middle" />

**Description**

Download the source code or binary for a specific version of a tool to a specified location.

**Implementation Details**

- The script must download the source or binary to the directory specified by `ASDF_DOWNLOAD_PATH`.
- Only the decompressed source code or binary should be placed in the `ASDF_DOWNLOAD_PATH` directory.
- On failure, no files should be placed in `ASDF_DOWNLOAD_PATH`.
- Success should exit with `0`.
- Failure should exit with a non-zero status.

**Legacy Plugins**

Though this script is marked as _required_ for all plugins, it is _optional_ for "legacy" plugins which predate its introduction.

If this script is absent, asdf will assume that the `bin/install` script is present and will download **and** install the version.

All plugins must include this script as support for legacy plugins will eventually be removed.

**Environment Variables available to script**

- `ASDF_INSTALL_TYPE`: `version` or `ref`
- `ASDF_INSTALL_VERSION`:
  - Full version number if `ASDF_INSTALL_TYPE=version`.
  - Git ref (tag/commit/branch) if `ASDF_INSTALL_TYPE=ref`.
- `ASDF_INSTALL_PATH`: The path to where the tool _has been_, or _should be_ installed.
- `ASDF_DOWNLOAD_PATH`: The path to where the source code or binary was downloaded to.

**Commands that invoke this script**

- `asdf install <tool> [version]`
- `asdf install <tool> latest[:version]`
- `asdf install nodejs 18.0.0`: downloads the source code or binary for Node.js
  version `18.0.0` and places it in the `ASDF_DOWNLOAD_PATH` directory. Then runs the `bin/install` script.

**Call signature from asdf core**

No parameters provided.

```bash
"${plugin_path}"/bin/download
```

---

### `bin/install` <Badge type="tip" text="required" vertical="middle" />

**Description**

Install a specific version of a tool to a specified location.

**Implementation Details**

- The script should install the specified version in the path `ASDF_INSTALL_PATH`.
- Shims will be created by default for any files in `$ASDF_INSTALL_PATH/bin`. This behaviour can be customised with the optional
[bin/list-bin-paths](#binlist-bin-paths) script.
- Success should exit with `0`.
- Failure should exit with a non-zero status.
- To avoid TOCTOU (Time-of-Check-to-Time-of-Use) issues, ensure the script only places files in `ASDF_INSTALL_PATH` once the build and installation of the tool is deemed a success.

**Legacy Plugins**

If the `bin/download` script is absent, this script should download **and** install the specified version.

For compatibility with versions of the asdf core earlier than `0.7._` and newer than `0.8._`, check for the presence of the `ASDF_DOWNLOAD_PATH` environment
variable. If set, assume the `bin/download` script already downloaded the version, else download the source code in the `bin/install` script.

**Environment Variables available to script**

- `ASDF_INSTALL_TYPE`: `version` or `ref`
- `ASDF_INSTALL_VERSION`:
  - Full version number if `ASDF_INSTALL_TYPE=version`.
  - Git ref (tag/commit/branch) if `ASDF_INSTALL_TYPE=ref`.
- `ASDF_INSTALL_PATH`: The path to where the tool _has been_, or _should be_ installed.
- `ASDF_CONCURRENCY`: The number of cores to use when compiling source code. Useful for setting flags like `make -j`.
- `ASDF_DOWNLOAD_PATH`: The path where the source code or binary was downloaded to.

**Commands that invoke this script**

- `asdf install`
- `asdf install <tool>`
- `asdf install <tool> [version]`
- `asdf install <tool> latest[:version]`
- `asdf install nodejs 18.0.0`: installs Node.js version `18.0.0` in the
  `ASDF_INSTALL_PATH` directory.

**Call signature from asdf core**

No parameters provided.

```bash
"${plugin_path}"/bin/install
```

## Optional Scripts

### `bin/latest-stable` <Badge type="warning" text="recommended" vertical="middle" />

**Description**

Determine the latest stable version of a tool. If absent, the asdf core will `tail` the `bin/list-all` output which may be undesirable.

**Implementation Details**

- The script should print the latest stable version of the tool to stdout.
- Non-stable or release candidate versions should be omitted.
- A filter query is provided as the first argument to the script. This should be used to filter the output by version number or tool provider.
  - For instance, the output of `asdf list all ruby` from the [ruby plugin](https://github.com/asdf-vm/asdf-ruby) lists versions of Ruby from many providers: `jruby`, `rbx` & `truffleruby` amongst others. The user provided filter could be used by the plugin to filter the semver versions and/or provider.
    ```
    > asdf latest ruby
    3.2.2
    > asdf latest ruby 2
    2.7.8
    > asdf latest ruby truffleruby
    truffleruby+graalvm-22.3.1
    ```
- Success should exit with `0`.
- Failure should exit with a non-zero status.

**Environment Variables available to script**

- `ASDF_INSTALL_TYPE`: `version` or `ref`
- `ASDF_INSTALL_VERSION`:
  - Full version number if `ASDF_INSTALL_TYPE=version`.
  - Git ref (tag/commit/branch) if `ASDF_INSTALL_TYPE=ref`.
- `ASDF_INSTALL_PATH`: The path to where the tool _has been_, or _should be_ installed.

**Commands that invoke this script**

- `asdf global <tool> latest`: set the global version of a tool to the latest stable version for that tool.
- `asdf local <name> latest`: set the local version of a tool to the latest stable version for that tool.
- `asdf install <tool> latest`: installs the latest version of a tool.
- `asdf latest <tool> [<version>]`: outputs the latest version of a tool based on the optional filter.
- `asdf latest --all`: outputs the latest version of all tools managed by asdf and whether they are installed.

**Call signature from asdf core**

The script should accept a single argument, the filter query.

```bash
"${plugin_path}"/bin/latest-stable "$query"
```

---

### `bin/help.overview`

**Description**

Output a general description about the plugin and the tool being managed.

**Implementation Details**

- This script is required for any help output to be displayed for the plugin.
- No heading should be printed as asdf core will print headings.
- Output may be free-form text but ideally only one short paragraph.
- Must not output any information that is already covered in the core asdf-vm documentation.
- Should be tailored to the Operating System and version of the tool being installed (using optionally set Environment Variables `ASDF_INSTALL_VERSION` and `ASDF_INSTALL_TYPE`).
- Success should exit with `0`.
- Failure should exit with a non-zero status.

**Environment Variables available to script**

- `ASDF_INSTALL_TYPE`: `version` or `ref`
- `ASDF_INSTALL_VERSION`:
  - Full version number if `ASDF_INSTALL_TYPE=version`.
  - Git ref (tag/commit/branch) if `ASDF_INSTALL_TYPE=ref`.
- `ASDF_INSTALL_PATH`: The path to where the tool _has been_, or _should be_ installed.

**Commands that invoke this script**

- `asdf help <name> [<version>]`: Output documentation for plugin and tool

**Call signature from asdf core**

```bash
"${plugin_path}"/bin/help.overview
```

---

### `bin/help.deps`

**Description**

Output the list of dependencies tailored to the operating system. One dependency per line.

```bash
git
curl
sed
```

**Implementation Details**

- This script requires `bin/help.overview` for its output to be considered.
- Should be tailored to the Operating System and version of the tool being installed (using optionally set Environment Variables `ASDF_INSTALL_VERSION` and `ASDF_INSTALL_TYPE`).
- Success should exit with `0`.
- Failure should exit with a non-zero status.

**Environment Variables available to script**

- `ASDF_INSTALL_TYPE`: `version` or `ref`
- `ASDF_INSTALL_VERSION`:
  - Full version number if `ASDF_INSTALL_TYPE=version`.
  - Git ref (tag/commit/branch) if `ASDF_INSTALL_TYPE=ref`.
- `ASDF_INSTALL_PATH`: The path to where the tool _has been_, or _should be_ installed.

**Commands that invoke this script**

- `asdf help <name> [<version>]`: Output documentation for plugin and tool

**Call signature from asdf core**

```bash
"${plugin_path}"/bin/help.deps
```

---

### `bin/help.config`

**Description**

Output any required or optional configuration for the plugin and tool. For example, describe any environment variables or other flags needed to install or compile the tool.

**Implementation Details**

- This script requires `bin/help.overview` for its output to be considered.
- Output can be free-form text.
- Should be tailored to the Operating System and version of the tool being installed (using optionally set Environment Variables `ASDF_INSTALL_VERSION` and `ASDF_INSTALL_TYPE`).
- Success should exit with `0`.
- Failure should exit with a non-zero status.

**Environment Variables available to script**

- `ASDF_INSTALL_TYPE`: `version` or `ref`
- `ASDF_INSTALL_VERSION`:
  - Full version number if `ASDF_INSTALL_TYPE=version`.
  - Git ref (tag/commit/branch) if `ASDF_INSTALL_TYPE=ref`.
- `ASDF_INSTALL_PATH`: The path to where the tool _has been_, or _should be_ installed.

**Commands that invoke this script**

- `asdf help <name> [<version>]`: Output documentation for plugin and tool

**Call signature from asdf core**

```bash
"${plugin_path}"/bin/help.config
```

---

### `bin/help.links`

**Description**

Output a list of links relevant to the plugin and tool. One link per line.

```bash
Git Repository:	https://github.com/vlang/v
Documentation:	https://vlang.io
```

**Implementation Details**

- This script requires `bin/help.overview` for its output to be considered.
- One link per line.
- Format must be either:
  - `<title>: <link>`
  - or just `<link>`
- Should be tailored to the Operating System and version of the tool being installed (using optionally set Environment Variables `ASDF_INSTALL_VERSION` and `ASDF_INSTALL_TYPE`).
- Success should exit with `0`.
- Failure should exit with a non-zero status.

**Environment Variables available to script**

- `ASDF_INSTALL_TYPE`: `version` or `ref`
- `ASDF_INSTALL_VERSION`:
  - Full version number if `ASDF_INSTALL_TYPE=version`.
  - Git ref (tag/commit/branch) if `ASDF_INSTALL_TYPE=ref`.
- `ASDF_INSTALL_PATH`: The path to where the tool _has been_, or _should be_ installed.

**Commands that invoke this script**

- `asdf help <name> [<version>]`: Output documentation for plugin and tool

**Call signature from asdf core**

```bash
"${plugin_path}"/bin/help.links
```

---

### `bin/list-bin-paths`

**Description**

List directories containing executables for the specified version of the tool.

**Implementation Details**

- If this script is not present, asdf will look for binaries in the `"${ASDF_INSTALL_PATH}"/bin` directory & create shims for those.
- Output a space-separated list of paths containing executables.
- Paths must be relative to `ASDF_INSTALL_PATH`. Example output would be:

```bash
bin tools veggies
```

This will instruct asdf to create shims for the files in:
- `"${ASDF_INSTALL_PATH}"/bin`
- `"${ASDF_INSTALL_PATH}"/tools`
- `"${ASDF_INSTALL_PATH}"/veggies`

**Environment Variables available to script**

- `ASDF_INSTALL_TYPE`: `version` or `ref`
- `ASDF_INSTALL_VERSION`:
  - Full version number if `ASDF_INSTALL_TYPE=version`.
  - Git ref (tag/commit/branch) if `ASDF_INSTALL_TYPE=ref`.
- `ASDF_INSTALL_PATH`: The path to where the tool _has been_, or _should be_ installed.

**Commands that invoke this script**

- `asdf install <tool> [version]`: initially create shims for binaries.
- `asdf reshim <tool> <version>`: recreate shims for binaries.

**Call signature from asdf core**

```bash
"${plugin_path}/bin/list-bin-paths"
```

---

### `bin/exec-env`

**Description**

Prepare the environment before executing the shims for the binaries for the tool.

**Environment Variables available to script**

- `ASDF_INSTALL_TYPE`: `version` or `ref`
- `ASDF_INSTALL_VERSION`:
  - Full version number if `ASDF_INSTALL_TYPE=version`.
  - Git ref (tag/commit/branch) if `ASDF_INSTALL_TYPE=ref`.
- `ASDF_INSTALL_PATH`: The path to where the tool _has been_, or _should be_ installed.

**Commands that invoke this script**

- `asdf which <command>`: Display the path to an executable
- `asdf exec <command> [args...]`: Executes the command shim for current version
- `asdf env <command> [util]`: Runs util (default: `env`) inside the environment used for command shim execution.

**Call signature from asdf core**

```bash
"${plugin_path}/bin/exec-env"
```

---

### `bin/exec-path`

Get the executable path for the specified version of the tool. Must print a
string with the relative executable path. This allows the plugin to
conditionally override the shim's specified executable path, otherwise return
the default path specified by the shim.

**Description**

Get the executable path for the specified version of the tool.

**Implementation Details**

- Must print a string with the relative executable path.
- Conditionally override the shim's specified executable path, otherwise return the default path specified by the shim.

```shell
Usage:
  plugin/bin/exec-path <install-path> <command> <executable-path>

Example Call:
  ~/.asdf/plugins/foo/bin/exec-path "~/.asdf/installs/foo/1.0" "foo" "bin/foo"

Output:
  bin/foox
```

**Environment Variables available to script**

- `ASDF_INSTALL_TYPE`: `version` or `ref`
- `ASDF_INSTALL_VERSION`:
  - Full version number if `ASDF_INSTALL_TYPE=version`.
  - Git ref (tag/commit/branch) if `ASDF_INSTALL_TYPE=ref`.
- `ASDF_INSTALL_PATH`: The path to where the tool _has been_, or _should be_ installed.

**Commands that invoke this script**

- `asdf which <command>`: Display the path to an executable
- `asdf exec <command> [args...]`: Executes the command shim for current version
- `asdf env <command> [util]`: Runs util (default: `env`) inside the environment used for command shim execution.

**Call signature from asdf core**

```bash
"${plugin_path}/bin/exec-path" "$install_path" "$cmd" "$relative_path"
```

---

### `bin/uninstall`

**Description**

Uninstall the provided version of a tool.

**Output Format**

Output should be sent to `stdout` or `stderr` as appropriate for the user. No output is read by subsequent execution in the core.

**Environment Variables available to script**

No environment variables are provided to this script.

**Commands that invoke this script**

- `asdf list all <name> <version>`
- `asdf uninstall nodejs 18.15.0`: Uninstalls the version `18.15.0` of nodejs, removing all shims including those installed global with `npm i -g`

**Call signature from asdf core**

No parameters provided.

```bash
"${plugin_path}/bin/uninstall"
```

---

### `bin/list-legacy-filenames`

**Description**

List legacy configuration filenames for determining the specified version of the tool.

**Implementation Details**

- Output a space-separated list of filenames.
  ```bash
  .ruby-version .rvmrc
  ```
- Only applies for users who have enabled the `legacy_version_file` option in their `"${HOME}"/.asdfrc`.

**Environment Variables available to script**

- `ASDF_INSTALL_TYPE`: `version` or `ref`
- `ASDF_INSTALL_VERSION`:
  - Full version number if `ASDF_INSTALL_TYPE=version`.
  - Git ref (tag/commit/branch) if `ASDF_INSTALL_TYPE=ref`.
- `ASDF_INSTALL_PATH`: The path to where the tool _has been_, or _should be_ installed.

**Commands that invoke this script**

Any command which reads a tool version.

**Call signature from asdf core**

No parameters provided.

```bash
"${plugin_path}/bin/list-legacy-filenames"
```

---

### `bin/parse-legacy-file`

**Description**

Parse the legacy file found by asdf to determine the version of the tool. Useful to extract version numbers from files like JavaScript's `package.json` or Golangs `go.mod`.

**Implementation Details**

- If not present, asdf will simply `cat` the legacy file to determine the version.
- Should be **deterministic** and always return the same exact version:
  - when parsing the same legacy file.
  - regardless of what is installed on the machine or whether the legacy version is valid or complete. Some legacy file formats may not be suitable.
- Output a single line with the version:
  ```bash
  1.2.3
  ```

**Environment Variables available to script**

No environment variables specifically set before this script is called.

**Commands that invoke this script**

Any command which reads a tool version.

**Call signature from asdf core**

The script should accept a single argument, the path to the legacy file for reading its contents.

```bash
"${plugin_path}/bin/parse-legacy-file" "$file_path"
```

---

### `bin/post-plugin-add`

**Description**

Execute this callback script **after** the plugin has been _added_ to asdf with `asdf plugin add <tool>`.

See also the related command hooks:

- `pre_asdf_plugin_add`
- `pre_asdf_plugin_add_${plugin_name}`
- `post_asdf_plugin_add`
- `post_asdf_plugin_add_${plugin_name}`

**Environment Variables available to script**

- `ASDF_PLUGIN_PATH`: path where the plugin was installed.
- `ASDF_PLUGIN_SOURCE_URL`: URL of the plugin source. Can be a local directory path.

**Call signature from asdf core**

No parameters provided.

```bash
"${plugin_path}/bin/post-plugin-add"
```

---

### `bin/post-plugin-update`

**Description**

Execute this callback script **after** asdf has downloaded the _update_ plugin with `asdf plugin update <tool> [<git-ref>]`.

See also the related command hooks:

- `pre_asdf_plugin_update`
- `pre_asdf_plugin_update_${plugin_name}`
- `post_asdf_plugin_update`
- `post_asdf_plugin_update_${plugin_name}`

**Environment Variables available to script**

- `ASDF_PLUGIN_PATH`: path where the plugin was installed.
- `ASDF_PLUGIN_PREV_REF`: the plugin's previous git-ref
- `ASDF_PLUGIN_POST_REF`: the plugin's updated git-ref

**Call signature from asdf core**

No parameters provided.

```bash
"${plugin_path}/bin/post-plugin-update"
```

---

### `bin/pre-plugin-remove`

**Description**

Execute this callback script **before** asdf has removed the plugin with `asdf plugin remove <tool>`.

See also the related command hooks:

- `pre_asdf_plugin_remove`
- `pre_asdf_plugin_remove_${plugin_name}`
- `post_asdf_plugin_remove`
- `post_asdf_plugin_remove_${plugin_name}`

**Environment Variables available to script**

- `ASDF_PLUGIN_PATH`: path where the plugin was installed.

**Call signature from asdf core**

No parameters provided.

```bash
"${plugin_path}/bin/pre-plugin-remove"
```

<!-- TODO: document command hooks -->
<!-- ## Command Hooks -->

## Extension Commands for asdf CLI <Badge type="danger" text="advanced" vertical="middle" />

It's possible for plugins to define new asdf commands by providing
`lib/commands/command*.bash` scripts or executables that will be callable using
the asdf command line interface by using the plugin name as a subcommand.

For example, suppose a `foo` plugin has:

```shell
foo/
  lib/commands/
    command.bash
    command-bat.bash
    command-bat-man.bash
    command-help.bash
```

Users can now execute:

```shell
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

```shell
asdf plugin test <plugin_name> <plugin_url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git_ref>] [test_command...]
```

- `<plugin_name>` & `<plugin_url>` are required
- If optional `[--asdf-tool-version <version>]` is specified, the tool will be
  installed with that specific version. Defaults to `asdf latest <plugin-name>`
- If optional `[--asdf-plugin-gitref <git_ref>]` is specified, the plugin itself
  is checked out at that commit/branch/tag. This is useful for testing a
  pull-request on your plugin's CI. Defaults to the default branch of the plugin's repository.
- Optional parameter `[test_command...]` is the command to execute to validate
  the installed tool works correctly. Typically `<tool> --version` or
  `<tool> --help`. For example, to test the NodeJS plugin, we could run
  ```shell
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
        uses: asdf-vm/actions/plugin-test@v2
        with:
          command: "<MY_TOOL> --version"
```

### TravisCI Config

A sample `.travis.yml` file, customize it to your needs

```yaml
language: c
script: asdf plugin test <MY_TOOL> $TRAVIS_BUILD_DIR '<MY_TOOL> --version'
before_script:
  - git clone https://github.com/asdf-vm/asdf.git asdf
  - . asdf/asdf.sh
os:
  - linux
  - osx
```

::: tip NOTE

When using another CI you may need to pass a relative path to the plugin
location:

```shell
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

```shell
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

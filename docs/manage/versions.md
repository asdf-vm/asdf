# Versions

## Install Version

```shell
asdf install <name> <version>
# asdf install erlang 17.3
```

If a plugin supports downloading & compiling from source, you can specify `ref:foo` where `foo` is a specific branch, tag, or commit. You'll need to use the same name and reference when uninstalling too.

## Install Latest Stable Version

```shell
asdf install <name> latest
# asdf install erlang latest
```

Install latest stable version that begins with a given string.

```shell
asdf install <name> latest:<version>
# asdf install erlang latest:17
```

## List Installed Versions

```shell
asdf list <name>
# asdf list erlang
```

Filter versions to those that begin with a given string.

```shell
asdf list <name> <version>
# asdf list erlang 17
```

## List All Available Versions

```shell
asdf list all <name>
# asdf list all erlang
```

Filter versions to those that begin with a given string.

```shell
asdf list all <name> <version>
# asdf list all erlang 17
```

## Show Latest Stable Version

```shell
asdf latest <name>
# asdf latest erlang
```

Show latest stable version that begins with a given string.

```shell
asdf latest <name> <version>
# asdf latest erlang 17
```

## Set Version

#### Via `.tool-versions` file

```shell
asdf set [flags] <name> <version> [<version>...]
# asdf set elixir 1.2.4 # set in current dir
# asdf set -u elixir 1.2.4 # set in .tool-versions file in home directory
# asdf set -p elixir 1.2.4 # set in existing .tool-versions file in a parent dir

asdf set <name> latest[:<version>]
# asdf set elixir latest
```

`asdf set` writes the version to a `.tool-versions` file in the current directory,
creating it if needed. It exists purely for convenience. You can think of it as
just doing `echo "<tool> <version>" > .tool-versions`.

With the `-u`/`--home` flag `asdf set` writes to the `.tool-versions` file in
your `$HOME` directory, creating the file if it does not exist.

With the `-p`/`--parent` flag `asdf set` finds a `.tool-versions` file in the
closest parent directory of the current directory.

#### Via Environment Variable

When determining the version looks for an environment variable with the pattern
`ASDF_${TOOL}_VERSION`. The version format is the same supported by the
`.tool-versions` file. If set, the value of this environment variable overrides
any versions set in for the tool in any `.tool-versions` file. For example:

```shell
export ASDF_ELIXIR_VERSION=1.18.1
```

Will tell asdf to use Elixir `1.18.1` in the current shell session.

:::warning
Because this is an environment variable, it only takes effect where it is set.
Any other shell sessions that are running will still use to whatever version is
set in a `.tool-versions` file.

See the `.tool-versions` [file in the Configuration section](/manage/configuration.md) for details.

:::

The following example runs tests on an Elixir project with version `1.4.0`.

```shell
ASDF_ELIXIR_VERSION=1.4.0 mix test
```

## Fallback to System Version

To use the system version of tool `<name>` instead of an asdf managed version you can set the version for the tool to `system`.

Set system with either `asdf set` or via environment variable as outlined in [Set Current Version](#set-current-version) section above.

```shell
asdf set <name> system
# asdf set python system
```

## View Current Version

```shell
asdf current
# asdf current
# erlang          17.3          /Users/kim/.tool-versions
# nodejs          6.11.5        /Users/kim/cool-node-project/.tool-versions

asdf current <name>
# asdf current erlang
# erlang          17.3          /Users/kim/.tool-versions
```

## Uninstall Version

```shell
asdf uninstall <name> <version>
# asdf uninstall erlang 17.3
```

## Shims

When asdf installs a package it creates shims for every executable program in that package in a `$ASDF_DATA_DIR/shims` directory (default `~/.asdf/shims`). This directory being on the `$PATH` (by means of `asdf.sh`, `asdf.fish`, etc) is how the installed programs are made available in the environment.

The shims themselves are really simple wrappers that `exec` a helper program `asdf exec` passing it the name of the plugin and path to the executable in the installed package that the shim is wrapping.

The `asdf exec` helper determines the version of the package to use (as specified in `.tool-versions` file or environment variable), the final path to the executable in the package installation directory (this can be manipulated by the `exec-path` callback in the plugin) and the environment to execute in (also provided by the plugin - `exec-env` script), and finally it executes it.

::: warning Note
Because this system uses `exec` calls, any scripts in the package that are meant to be sourced by the shell instead of executed need to be accessed directly instead of via the shim wrapper. The two `asdf` commands: `which` and `where` can help with this by returning the path to the installed package:
:::

```shell
# returns path to main executable in current version
source $(asdf which ${PLUGIN})/../script.sh

# returns path to the package installation directory
source $(asdf where ${PLUGIN})/bin/script.sh
```

### By-passing asdf shims

If for some reason you want to by-pass asdf shims or want your environment variables automatically set upon entering your project's directory, the [asdf-direnv](https://github.com/asdf-community/asdf-direnv) plugin can be helpful. Be sure to check its README for more details.

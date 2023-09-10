# Plugins

Plugins are how `asdf` knows to handle different tools like Node.js, Ruby, Elixir etc.

See [Creating Plugins](/plugins/create.md) for the plugin API used to support more tools.

## Add

Add plugins via their Git URL:

```shell
asdf plugin add <name> <git-url>
# asdf plugin add elm https://github.com/vic/asdf-elm
```

or via the short-name association in the plugins repository:

```shell
asdf plugin add <name>
# asdf plugin add erlang
```

::: tip Recommendation

Prefer the longer `git-url` method as it is independent of the short-name repo.

:::

## List Installed

```shell
asdf plugin list
# asdf plugin list
# java
# nodejs
```

```shell
asdf plugin list --urls
# asdf plugin list
# java            https://github.com/halcyon/asdf-java.git
# nodejs          https://github.com/asdf-vm/asdf-nodejs.git
```

## List All in Short-name Repository

```shell
asdf plugin list all
```

See [Plugins Shortname Index](https://github.com/asdf-vm/asdf-plugins) for the entire short-name list of plugins.

## Update

```shell
asdf plugin update --all
```

If you want to update a specific package, just say so.

```shell
asdf plugin update <name>
# asdf plugin update erlang
```

This update will fetch the _latest commit_ on the _default branch_ of the _origin_ of the plugin repository. Versioned plugins and updates are currently being developed ([#916](https://github.com/asdf-vm/asdf/pull/916))

## Remove

```bash
asdf plugin remove <name>
# asdf plugin remove erlang
```

Removing a plugin will remove all installations of the tool made with the plugin. This can be used as a shorthand for cleaning/pruning many unused versions of a tool.

## Syncing the asdf Short-name Repository

The short-name repo is synced to your local machine and periodically refreshed. This method to determine a sync is as follows:

- sync events are triggered by commands:
  - `asdf plugin add <name>`
  - `asdf plugin list all`
- if configuration option `disable_plugin_short_name_repository` is set to `yes`, then sync is aborted early. See the [asdf config docs](/manage/configuration.md) for more.
- if there has not been a synchronization in the last `X` minutes then the sync will occur.
  - `X` defaults to `60`, but can be configured in your `.asdfrc` via the `plugin_repository_last_check_duration` option. See the [asdf config docs](/manage/configuration.md) for more.

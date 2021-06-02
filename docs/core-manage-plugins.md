Plugins are how asdf knows how to handle different tools like Node.js, Ruby, Elixir etc.

See [Creating Plugins](plugins-create) for the plugin API used to support more tools.

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

When scripting, prefer the longer `git-url` method as it is independent of the short-name repo.

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

See [All plugins](plugins-all) for the short-name list of plugins.

## Update

```shell
asdf plugin update --all
```

If you want to update a specific package, just say so.

```shell
asdf plugin update <name>
# asdf plugin update erlang
```

This update will fetch the *latest commit* on the *default branch* of the *origin* of the plugin repository. Versioned plugins and updates are currently being developed - https://github.com/asdf-vm/asdf/pull/916

## Remove

```bash
asdf plugin remove <name>
# asdf plugin remove erlang
```

Removing a plugin will remove all installations of the tool made with the plugin. This can be used as a shorthand for cleaning/pruning many unused versions of a tool.

## Syncing the Short-name Repository

The short-name repo is synced to your local machine and periodically refreshed. This period is determined by the following method:

- commands `asdf plugin add <name>` or `asdf plugin list all` can trigger a sync
- a sync occurs if there has not been one in the last `X` minutes
- `X` defaults to `60`, but can be configured in your `.asdfrc` via the `plugin_repository_last_check_duration` option. See the [asdf config docs](core-configuration) for more.

Plugins are how asdf-vm understands handling different packages.

See [All plugins](plugins-all) for the plugins repository which lists all asdf-vm plugins we know.

See [Creating Plugins](plugins-create) for the super-simple API for supporting more languages.

## Add

```shell
asdf plugin-add <name>
# asdf plugin-add erlang
```

If the plugin you want to install is not part of the plugins repository, you
can add it using its repository URL:

```shell
asdf plugin-add <name> <git-url>
# asdf plugin-add elm https://github.com/vic/asdf-elm
```

## List Installed

```shell
asdf plugin-list
# asdf plugin-list
# java
# nodejs
```

```shell
asdf plugin-list --urls
# asdf plugin-list
# java            https://github.com/skotchpine/asdf-java.git
# nodejs          https://github.com/asdf-vm/asdf-nodejs.git
```

## Update

```shell
asdf plugin-update --all
```

If you want to update a specific package, just say so.

```shell
asdf plugin-update <name>
# asdf plugin-update erlang
```

## Remove

```bash
asdf plugin-remove <name>
# asdf plugin-remove erlang
```

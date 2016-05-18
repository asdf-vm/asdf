# asdf
### _extendable version manager_

Supported languages include Ruby, Node.js, Elixir and more. Supporting a new language is as simple as [this plugin API](https://github.com/asdf-vm/asdf/blob/master/docs/creating-plugins.md).

## SETUP

Copy-paste the following into command line:

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

```

Depending on your OS, run the following
```bash
# For Ubuntu or other linux distros
echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc

# OR for Max OSX
echo '. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bash_profile
```

If you use zsh or any other shell, replace `.bashrc` with the config file for the respective shell.

For fish, you can use the following:

```
echo 'source ~/.asdf/asdf.fish' >> ~/.config/fish/config.fish
mkdir -p ~/.config/fish/completions; and cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

> For most plugins, it is good if you have installed the following packages OR their equivalent on you OS

> * **OS X**: Install these via homebrew `automake autoconf openssl libyaml readline libxslt libtool unixodbc`
> * **Ubuntu**: `automake autoconf libreadline-dev libncurses-dev libssl-dev libyaml-dev libxslt-dev libffi-dev libtool unixodbc-dev`

**That's all ~! You are ready to use asdf**

-----------------------


## USAGE

### Manage plugins

Plugins are how asdf understands how to handle different packages. Below is a list of plugins for languages. There is a [super-simple API](https://github.com/asdf-vm/asdf/blob/master/docs/creating-plugins.md) for supporting more languages.

| Language  | Repository  |
|-----------|-------------|
| Elixir    | [asdf-vm/asdf-elixir](https://github.com/asdf-vm/asdf-elixir)
| Erlang    | [asdf-vm/asdf-erlang](https://github.com/asdf-vm/asdf-erlang)
| Go        | [kennyp/asdf-golang](https://github.com/kennyp/asdf-golang)
| Lua       | [Stratus3D/asdf-lua](https://github.com/Stratus3D/asdf-lua)
| OpenResty | [smashedtoatoms/asdf-openresty](https://github.com/smashedtoatoms/asdf-openresty)
| Node.js   | [asdf-vm/asdf-nodejs](https://github.com/asdf-vm/asdf-nodejs)
| Postgres  | [smashedtoatoms/asdf-postgres](https://github.com/smashedtoatoms/asdf-postgres)
| Redis     | [smashedtoatoms/asdf-redis](https://github.com/smashedtoatoms/asdf-redis)
| Riak      | [smashedtoatoms/asdf-riak](https://github.com/smashedtoatoms/asdf-riak)
| Ruby      | [asdf-vm/asdf-ruby](https://github.com/asdf-vm/asdf-ruby)


##### Add a plugin

```bash
asdf plugin-add <name> <git-url>
# asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
```

##### List installed plugins

```bash
asdf plugin-list
# asdf plugin-list
```

##### Remove a plugin

```bash
asdf plugin-remove <name>
# asdf plugin-remove erlang
```


##### Update plugins

```bash
asdf plugin-update --all
```

If you want to update a specific package, just say so.

```bash
asdf plugin-update <name>
# asdf plugin-update erlang
```

### Manage versions

```bash
asdf install <name> <version>
# asdf install erlang 17.3

asdf which <name>
# asdf which erlang
# 17.3

asdf uninstall <name> <version>
# asdf uninstall erlang 17.3
```

*If a plugin supports downloading & compiling from source, you can also do this `ref:foo` (replace `foo` with the branch/tag/commit).* You'll have to use the same name when uninstalling too.

##### Lists installed versions

```bash
asdf list <name>
# asdf list erlang
```

##### List all available versions

```bash
asdf list-all <name>
# asdf list-all erlang
```

#### View current version

```bash
asdf local [name]
asdf global [name]
# asdf local
# asdf global
# asdf local elixir
# asdf global elixir
```

`global` reads from `$HOME/.tool-versions`.

`local` reads from `$PWD/.tool-versions` if it exists,
or searches recursively in the parent directories until it finds a `.tool-versions` file.

#### Set current version

```bash
asdf global <name> <version>
asdf local <name> <version>
asdf global elixir 1.2.4
```

`global` writes the version to `$HOME/.tool-versions`.

`local` writes the version to `$PWD/.tool-versions`, creating it if needed.

## The `.tool-versions` file

Add a `.tool-versions` file to your project dir and versions of those tools will be used.
**Global defaults can be set in the file `$HOME/.tool-versions`**

This is what a `.tool-versions` file looks like:

```
ruby 2.2.0
nodejs 0.12.3
```

The versions can be in the following format:

* `0.12.3` - an actual version. Plugins that support downloading binaries, will download binaries.
* `ref:v1.0.2-a` or `ref:39cb398vb39` - tag/commit/branch to download from github and compile
* `path:/src/elixir` - a path to custom compiled version of a tool to use. For use by language developers and such.

To install all the tools defined in a `.tool-versions` file run the `asdf install` command with no other arguments in the directory containing the `.tool-versions` file.

You can view/modify the file by hand or use `asdf local` and `asdf global` to manage it.

## Credits

Me ([@HashNuke](http://github.com/HashNuke)), High-fever, cold, cough.

Copyright 2014 to the end of time ([MIT License](https://github.com/asdf-vm/asdf/blob/master/LICENSE))

### Maintainers

- [@HashNuke](http://github.com/HashNuke)
- [@tuvistavie](http://github.com/tuvistavie)
- [@Stratus3D](https://github.com/Stratus3D)

-------

Read the [ballad](https://github.com/asdf-vm/asdf/blob/master/ballad-of-asdf.md).

# asdf [![Build Status](https://travis-ci.org/asdf-vm/asdf.svg?branch=master)](https://travis-ci.org/asdf-vm/asdf)
### _extendable version manager_

Supported languages include Ruby, Node.js, Elixir and more. Supporting a new language is as simple as [this plugin API](https://github.com/asdf-vm/asdf/blob/master/docs/creating-plugins.md).

## SETUP

Copy-paste the following into command line:

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.2.1

```

Depending on your OS, run the following
```bash
# For Ubuntu or other linux distros
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc

# OR for Mac OSX
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bash_profile
```

If you use zsh or any other shell, replace `.bashrc` with the config file for the respective shell.

For fish, you can use the following:

```
echo 'source ~/.asdf/asdf.fish' >> ~/.config/fish/config.fish
mkdir -p ~/.config/fish/completions; and cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

> For most plugins, it is good if you have installed the following packages OR their equivalent on your OS

> * **OS X**: Install these via homebrew `automake autoconf openssl libyaml readline libxslt libtool unixodbc`
> * **Ubuntu**: `automake autoconf libreadline-dev libncurses-dev libssl-dev libyaml-dev libxslt-dev libffi-dev libtool unixodbc-dev`
> * **Fedora**: `automake autoconf readline-devel ncurses-devel openssl-devel libyaml-devel libxslt-devel libffi-devel libtool unixODBC-devel`

**That's all ~! You are ready to use asdf**

-----------------------


## USAGE

### Manage plugins

Plugins are how asdf understands how to handle different packages. Below is a list of plugins for languages. There is a [super-simple API](https://github.com/asdf-vm/asdf/blob/master/docs/creating-plugins.md) for supporting more languages.

| Language  | Repository  | CI Status
|-----------|-------------|----------
| Clojure   | [vic/asdf-clojure](https://github.com/vic/asdf-clojure) | [![Build Status](https://travis-ci.org/vic/asdf-clojure.svg?branch=master)](https://travis-ci.org/vic/asdf-clojure)
| D (DMD)   | [sylph01/asdf-dmd](https://github.com/sylph01/asdf-dmd) | [![Build Status](https://travis-ci.org/sylph01/asdf-dmd.svg?branch=master)](https://travis-ci.org/sylph01/asdf-dmd)
| Elixir    | [asdf-vm/asdf-elixir](https://github.com/asdf-vm/asdf-elixir) | [![Build Status](https://travis-ci.org/asdf-vm/asdf-elixir.svg?branch=master)](https://travis-ci.org/asdf-vm/asdf-elixir)
| Elm       | [vic/asdf-elm](https://github.com/vic/asdf-elm) | [![Build Status](https://travis-ci.org/vic/asdf-elm.svg?branch=master)](https://travis-ci.org/vic/asdf-elm)
| Erlang    | [asdf-vm/asdf-erlang](https://github.com/asdf-vm/asdf-erlang) | [![Build Status](https://travis-ci.org/asdf-vm/asdf-erlang.svg?branch=master)](https://travis-ci.org/asdf-vm/asdf-erlang)
| Go        | [kennyp/asdf-golang](https://github.com/kennyp/asdf-golang) | [![Build Status](https://travis-ci.org/kennyp/asdf-golang.svg?branch=master)](https://travis-ci.org/kennyp/asdf-golang)
| Haskell   | [vic/asdf-haskell](https://github.com/vic/asdf-haskell) | [![Build Status](https://travis-ci.org/vic/asdf-haskell.svg?branch=master)](https://travis-ci.org/vic/asdf-haskell)
| Idris     | [vic/asdf-idris](https://github.com/vic/asdf-idris) | [![Build Status](https://travis-ci.org/vic/asdf-idris.svg?branch=master)](https://travis-ci.org/vic/asdf-idris)
| Julia     | [rkyleg/asdf-julia](https://github.com/rkyleg/asdf-julia) | [![Build Status](https://travis-ci.org/rkyleg/asdf-julia.svg?branch=master)](https://travis-ci.org/rkyleg/asdf-julia)
| LFE       | [vic/asdf-lfe](https://github.com/vic/asdf-lfe) | [![Build Status](https://travis-ci.org/vic/asdf-lfe.svg?branch=master)](https://travis-ci.org/vic/asdf-lfe)
| Lua       | [Stratus3D/asdf-lua](https://github.com/Stratus3D/asdf-lua) | [![Build Status](https://travis-ci.org/Stratus3D/asdf-lua.svg?branch=master)](https://travis-ci.org/Stratus3D/asdf-lua)
| LuaJIT | [smashedtoatoms/asdf-luaJIT](https://github.com/smashedtoatoms/asdf-luaJIT) | [![Build Status](https://travis-ci.org/smashedtoatoms/asdf-luaJIT.svg?branch=master)](https://travis-ci.org/smashedtoatoms/asdf-luaJIT)
| OpenResty | [smashedtoatoms/asdf-openresty](https://github.com/smashedtoatoms/asdf-openresty) | [![Build Status](https://travis-ci.org/smashedtoatoms/asdf-openresty.svg?branch=master)](https://travis-ci.org/smashedtoatoms/asdf-openresty)
| MongoDB   | [sylph01/asdf-mongodb](https://github.com/sylph01/asdf-mongodb) | [![Build Status](https://travis-ci.org/sylph01/asdf-mongodb.svg?branch=master)](https://travis-ci.org/sylph01/asdf-mongodb)
| Node.js   | [asdf-vm/asdf-nodejs](https://github.com/asdf-vm/asdf-nodejs) | [![Build Status](https://travis-ci.org/asdf-vm/asdf-nodejs.svg?branch=master)](https://travis-ci.org/asdf-vm/asdf-nodejs)
| PHP  | [odarriba/asdf-php](https://github.com/odarriba/asdf-php) | [![Build Status](https://travis-ci.org/odarriba/asdf-php.svg?branch=master)](https://travis-ci.org/odarriba/asdf-php)
| Postgres  | [smashedtoatoms/asdf-postgres](https://github.com/smashedtoatoms/asdf-postgres) | [![Build Status](https://travis-ci.org/smashedtoatoms/asdf-postgres.svg?branch=master)](https://travis-ci.org/smashedtoatoms/asdf-postgres)
| Python    | [tuvistavie/asdf-python](https://github.com/tuvistavie/asdf-python) | [![Build Status](https://travis-ci.org/tuvistavie/asdf-python.svg?branch=master)](https://travis-ci.org/tuvistavie/asdf-python)
| Redis     | [smashedtoatoms/asdf-redis](https://github.com/smashedtoatoms/asdf-redis) | [![Build Status](https://travis-ci.org/smashedtoatoms/asdf-redis.svg?branch=master)](https://travis-ci.org/smashedtoatoms/asdf-redis)
| Riak      | [smashedtoatoms/asdf-riak](https://github.com/smashedtoatoms/asdf-riak) | [![Build Status](https://travis-ci.org/smashedtoatoms/asdf-riak.svg?branch=master)](https://travis-ci.org/smashedtoatoms/asdf-riak)
| Ruby      | [asdf-vm/asdf-ruby](https://github.com/asdf-vm/asdf-ruby) | [![Build Status](https://travis-ci.org/asdf-vm/asdf-ruby.svg?branch=master)](https://travis-ci.org/asdf-vm/asdf-ruby)
| Rust      | [code-lever/asdf-rust](https://github.com/code-lever/asdf-rust) | [![Build Status](https://travis-ci.org/code-lever/asdf-rust.svg?branch=master)](https://travis-ci.org/code-lever/asdf-rust)
| SBT       | [lerencao/asdf-sbt](https://github.com/lerencao/asdf-sbt) | [![Build Status](https://travis-ci.org/lerencao/asdf-sbt.svg?branch=master)](https://travis-ci.org/lerencao/asdf-sbt)
| Scala     | [mtatheonly/asdf-scala](https://github.com/mtatheonly/asdf-scala)| [![Build Status](https://travis-ci.org/mtatheonly/asdf-scala.svg?branch=master)](https://travis-ci.org/mtatheonly/asdf-scala)
| Terraform | [neerfri/asdf-terraform](https://github.com/neerfri/asdf-terraform) | [![Build Status](https://travis-ci.org/neerfri/asdf-terraform.svg?branch=master)](https://travis-ci.org/neerfri/asdf-terraform)

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

asdf current <name>
# asdf current erlang
# 17.3 (set by /Users/kim/.tool-versions)

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
asdf current <name>
# asdf current erlang
# 17.3 (set by /Users/kim/.tool-versions)
```

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

## The `$HOME/.asdfrc` config file

Add a `.asdfrc` file to your home directory and asdf will use the settings specified in the file. The file should be formatted like this:

```
legacy_version_file = yes
```

**Settings**

* `legacy_version_file` - defaults to `no`. If set to yes it will cause plugins that support this feature to read the version files used by other version managers (e.g. `.ruby-version` in the case of Ruby's rbenv).

## Credits

Me ([@HashNuke](http://github.com/HashNuke)), High-fever, cold, cough.

Copyright 2014 to the end of time ([MIT License](https://github.com/asdf-vm/asdf/blob/master/LICENSE))

### Maintainers

- [@HashNuke](http://github.com/HashNuke)
- [@tuvistavie](http://github.com/tuvistavie)
- [@Stratus3D](https://github.com/Stratus3D)

-------

Read the [ballad](https://github.com/asdf-vm/asdf/blob/master/ballad-of-asdf.md).

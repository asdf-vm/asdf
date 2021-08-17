# Introduction

`asdf` is a tool version manager. All tool version definitions are contained within one file (`.tool-versions`) which you can check in to your project's Git repository to share with your team, ensuring everyone is using the **exact** same versions of tools.

The old way of working required multiple CLI version managers, each with their distinct API, configurations files and implementation (e.g. `$PATH` manipulation, shims, environment variables, etc...). `asdf` provides a single interface and configuration file to simplify development workflows, and can be extended to all tools and runtimes via a simple plugin interface.

## How It Works

Once `asdf` core is set up with your Shell configuration, plugins are installed to manage particular tools. When a tool is installed by a plugin, the executables that are installed have [shims](<https://en.wikipedia.org/wiki/Shim_(computing)>) created for each of them. When you try and run one of these executables, the shim is run instead, allowing `asdf` to identify which version of the tool is set in `.tool-versions` and execute that version.

## Related Projects

### nvm / n / rbenv etc

Tools like [nvm](https://github.com/nvm-sh/nvm), [n](https://github.com/tj/n) and [rbenv](https://github.com/rbenv/rbenv) are all written as Shell scripts which create shims for the executables installed by these tools.

`asdf` is very similar and was built to compete in this space of tool/runtime version management. The differentiating factor for `asdf` is its plugin system which removes the need for a manager per tool/runtime, different commands per manager and different `*-version` files in your repo.

<!-- ### pyenv

TODO: someone with Python background expand on this

`asdf` has some similarities to `pyenv` but is missing some key features. The `asdf` team is looking at introducing some of these `pyenv` specific features, though no roadmap or timeline is available. -->

### direnv

> augments existing shells with a new feature that can load and unload environment variables depending on the current directory.

`asdf` does not manage Environment Variables, however there is a plugin [`asdf-direnv`](https://github.com/asdf-community/asdf-direnv) to integrate direnv behaviour with `asdf`.

See [direnv docs](https://direnv.net/) for more.

### Homebrew

> The Missing Package Manager for macOS (or Linux)

Homebrew manages your packages and their upstream dependencies. `asdf` does not manage upstream dependencies, it is not a package manager, that burden is upon the user, though we try and keep the dependency list small.

See [Homebrew docs](https://brew.sh/) for more.

### NixOS

> Nix is a tool that takes a unique approach to package management and system configuration

NixOS aims to build truly reproducible environments by managing exact versions of packages up the entire dependency tree of each tool, something `asdf` does not do. NixOS does this with its own programming language, many CLI tools and a package collection of over 60,000 packages.

Again, `asdf` does not manage upstream dependencies and is not a package manager.

See [NixOS docs](https://nixos.org/guides/how-nix-works.html) for more.

## Why use asdf?

`asdf` ensures teams are using the **exact** same versions of tools, with support for **many** tools via a plugin system, and the _simplicity and familiarity_ of being a single **Shell** script you include in your Shell config.

::: tip Note
`asdf` is not intended to be a system package manager. It is a tool version manager. Just because you can create a plugin for any tool and manage its versions with `asdf`, does not mean that is the best course of action for that specific tool.
:::

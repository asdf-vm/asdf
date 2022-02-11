# Core

> Hi, we've recently migrated our docs and added some new pages. If you would like to help translate this page, see the "Edit this page" link at the bottom of the page.

The core `asdf` command list is rather small, but can facilitate many workflows.

## Installation & Setup

Covered in the [Getting Started](/pt-br/guide/getting-started.md) guide.

## Exec

```shell:no-line-numbers
asdf exec <command> [args...]
```

Executes the command shim for the current version.

<!-- TODO: expand on this with example -->

## Env

```shell:no-line-numbers
asdf env <command> [util]
```

<!-- TODO: expand on this with example -->

## Info

```shell:no-line-numbers
asdf info
```

A helper command to print the OS, Shell and `asdf` debug information. Share this when making a bug report.

## Reshim

```shell:no-line-numbers
asdf reshim <name> <version>
```

This recreates the shims for the current version of a package. By default, shims are created by plugins during installation of a tool. Some tools like the [npm CLI](https://docs.npmjs.com/cli/) allow global installation of executables, for example, installing [Yarn](https://yarnpkg.com/) via `npm install -g yarn`. Since this executable was not installed via the plugin lifecycle, no shim exists for it yet. `asdf reshim nodejs <version>` will force recalculation of shims for any new executables, like `yarn`, for `<version>` of `nodejs` .

## Shim-versions

```shell:no-line-numbers
asdf shim-versions <command>
```

Lists the plugins and versions that provide shims for a command.

As an example, [Node.js](https://nodejs.org/) ships with two executables, `node` and `npm`. When many versions of the tools are installed with [`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/) `shim-versions` can return:

```shell:no-line-numbers
➜ asdf shim-versions node
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

```shell:no-line-numbers
➜ asdf shim-versions npm
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

## Atualizar

`asdf` has a built in command to update which relies on Git (our recommended installation method). If you installed using a different method you should follow the steps for that method:

| Method         | Latest Stable Release                                                                                                                          | Latest commit on `master`        |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| asdf (via Git) | `asdf update`                                                                                                                                  | `asdf update --head`             |
| Homebrew       | `brew upgrade asdf`                                                                                                                            | `brew upgrade asdf --fetch-HEAD` |
| Pacman         | Obter manualmente um novo `PKGBUILD` e <br/> reconstruir ou usar suas preferências de [AUR](https://wiki.archlinux.org/index.php/AUR_helpers). |                                  |

## Desinstalar

Para desinstalar `asdf` siga os passos:

::: details Bash & Git

1. Em seu `~/.bashrc` remova as linhas do `asdf.sh` e seus complementos:

```shell
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
```

2. Remova o diretório `$HOME/.asdf`:

```shell
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Bash & Git (macOS)

1. Em seu `~/.bash_profile` remova as linhas do `asdf.sh` e remova seus complementos:

```shell
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
```

2. Remova o diretório `$HOME/.asdf`:

```shell
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Bash & Homebrew (macOS)

Caso esteja usando **macOs Catalina ou mais recente**, por padrão o _shell_ é **ZSH**. Se não achar alguma configuração em seu `~/.bash_profile` talvez esteja em `~/.zshrc` em cada caso siga as intruções do ZSH.

1. Em seu `~/.bash_profile` remova as linhas do `asdf.sh` e remova seus complementos:

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash
```

?> Os complementos precisam [instruções de configuração do Homebrew](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) e siga o guia de remoção.

2. Desinstale usando seu gerenciador de pacotes:

```shell
brew uninstall asdf --force
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Bash & Pacman

1. Em seu `~/.bashrc` remova as linhas do `asdf.sh` e seus complementos:

```shell
. /opt/asdf-vm/asdf.sh
```

2. Desinstale usando seu gerenciador de pacotes:

```shell
pacman -Rs asdf-vm
```

3. Remova o diretório `$HOME/.asdf`:

```shell
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

4. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Fish & Git

1. Em seu `~/.config/fish/config.fish` remova as linhas do `asdf.sh`:

```shell
source ~/.asdf/asdf.fish
```

e remova os complementos de com esse comando:

```shell
rm -rf ~/.config/fish/completions/asdf.fish
```

2. Remova o diretório `$HOME/.asdf`:

```shell
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Fish & Homebrew

1. Em seu `~/.config/fish/config.fish` remova as linhas do `asdf.fish`:

```shell
source "(brew --prefix asdf)"/libexec/asdf.fish
```

2. Desinstale usando seu gerenciador de pacotes:

```shell
brew uninstall asdf --force
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Fish & Pacman

1. Em seu `~/.config/fish/config.fish` remova as linhas do `asdf.fish`:

```shell
source /opt/asdf-vm/asdf.fish
```

2. Desinstale usando seu gerenciador de pacotes:

```shell
pacman -Rs asdf-vm
```

3. Remova o diretório `$HOME/.asdf`:

```shell
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

4. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Elvish & Git

1. Em seu `~/.config/elvish/rc.elv` remova as linhas que importa o módulo `asdf`:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

e desinstale o módulo `asdf` com este comando:

```shell:no-line-numbers
rm -f ~/.config/elvish/lib/asdf.elv
```

2. Remova o diretório `$HOME/.asdf`:

```shell:no-line-numbers
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

3. Execute este comando para remover todos os arquivos de configuração `asdf`:

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Elvish & Homebrew

1. Em seu `~/.config/elvish/rc.elv` remova as linhas que importa o módulo `asdf`:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

e desinstale o módulo `asdf` com este comando:

```shell:no-line-numbers
rm -f ~/.config/elvish/lib/asdf.elv
```

2. Desinstale com seu gerenciador de pacotes:

```shell:no-line-numbers
brew uninstall asdf --force
```

3. Execute este comando para remover todos os arquivos de configuração `asdf`:

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details Elvish & Pacman

1. Em seu `~/.config/elvish/rc.elv` remova as linhas que importa o módulo `asdf`:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

e desinstale o módulo `asdf` com este comando:

```shell:no-line-numbers
rm -f ~/.config/elvish/lib/asdf.elv
```

2. Desinstale com seu gerenciador de pacotes:

```shell:no-line-numbers
pacman -Rs asdf-vm
```

3. Remova o diretório `$ HOME/.asdf`:

```shell:no-line-numbers
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

4. Execute este comando para remover todos os arquivos de configuração `asdf`:

```shell:no-line-numbers
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details ZSH & Git

1. Em seu `~/.zshrc` remova as linhas do `asdf.sh` e seus complementos:

```shell
. $HOME/.asdf/asdf.sh
# ...
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit
compinit
```

**Ou** use ZSH Framework plugin.

2. Remova o diretório `$HOME/.asdf`:

```shell
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details ZSH & Homebrew

1. Em seu `~/.zshrc` remova as linhas do `asdf.sh`:

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
```

2. Desinstale usando seu gerenciador de pacotes:

```shell
brew uninstall asdf --force
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

::: details ZSH & Pacman

1. Em seu `~/.zshrc` remova as linhas do `asdf.sh`:

```shell
. /opt/asdf-vm/asdf.sh
```

2. Desinstale usando seu gerenciador de pacotes:

```shell
pacman -Rs asdf-vm
```

3. Remova o diretório `$HOME/.asdf`:

```shell
rm -rf ${ASDF_DATA_DIR:-$HOME/.asdf}
```

4. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

:::

Tudo pronto! 🎉

# Core

> Hi, we've recently migrated our docs and added some new pages. If you would like to help translate this page, see the "Edit this page" link at the bottom of the page.

A lista de comandos do núcleo `asdf` é bastante pequena, mas pode facilitar muitos fluxos de trabalho.

## Instalação e configuração

Baseado no [Guia de Introdução](/pt-br/guide/getting-started.md).

## Execute

```shell
asdf exec <command> [args...]
```

Executa o comando shim para a versão atual

<!-- TODO: expand on this with example -->

## Variável de Ambiente

```shell
asdf env <command> [util]
```

<!-- TODO: expand on this with example -->

## Informações

```shell
asdf info
```

 Um comando auxiliar para imprimir as informações de depuração do SO, Shell e `asdf`. Compartilhe isso ao fazer um relatório de bug.

## Reshim

```shell
asdf reshim <name> <version>
```

Isso recria os shims para a versão atual de um pacote. Por padrão, os calços são criados por plugins durante a instalação de uma ferramenta. Algumas ferramentas como a [npm CLI](https://docs.npmjs.com/cli/) permitem a instalação global de executáveis, por exemplo, instalando [Yarn](https://yarnpkg.com/) via `npm install -g fio`.  Como este executável não foi instalado por meio do ciclo de vida do plug-in, ainda não existe shim para ele. `asdf reshim nodejs <version>` forçará o recálculo de shims para quaisquer novos executáveis, como `yarn`, para `<version>` de `nodejs`.

## Versionamento do Shim

```shell
asdf shim-versions <command>
```

Lista os plugins e versões que fornecem shims para um comando.

Como exemplo, o [Node.js](https://nodejs.org/) vem com dois executáveis, `node` e `npm`. Quando muitas versões das ferramentas são instaladas com [`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/) `shim-versions` pode retornar:

```shell
➜ asdf shim-versions node
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

```shell
➜ asdf shim-versions npm
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

## Atualizar

`asdf` tem um comando embutido para atualização que depende do Git (nosso método de instalação recomendado). Se você instalou usando um método diferente, siga as etapas para esse método:

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
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
```

2. Remova o diretório `$HOME/.asdf`:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Git (macOS)

1. Em seu `~/.bash_profile` remova as linhas do `asdf.sh` e remova seus complementos:

```shell
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
```

2. Remova o diretório `$HOME/.asdf`:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Homebrew

1. Em seu `~/.bashrc` remova as linhas do `asdf.sh` e remova seus complementos:

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
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
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
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
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
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

4. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
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
rm -rf (string join : -- $ASDF_DATA_DIR $HOME/.asdf)
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
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
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
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
rm -rf (string join : -- $ASDF_DATA_DIR $HOME/.asdf)
```

4. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Git

1. Em seu `~/.config/elvish/rc.elv` remova as linhas que importa o módulo `asdf`:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

e desinstale o módulo `asdf` com este comando:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. Remova o diretório `$HOME/.asdf`:

```shell
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

3. Execute este comando para remover todos os arquivos de configuração `asdf`:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Homebrew

1. Em seu `~/.config/elvish/rc.elv` remova as linhas que importa o módulo `asdf`:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

e desinstale o módulo `asdf` com este comando:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. Desinstale com seu gerenciador de pacotes:

```shell
brew uninstall asdf --force
```

3. Execute este comando para remover todos os arquivos de configuração `asdf`:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Pacman

1. Em seu `~/.config/elvish/rc.elv` remova as linhas que importa o módulo `asdf`:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

e desinstale o módulo `asdf` com este comando:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. Desinstale com seu gerenciador de pacotes:

```shell
pacman -Rs asdf-vm
```

3. Remova o diretório `$ HOME/.asdf`:

```shell
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

4. Execute este comando para remover todos os arquivos de configuração `asdf`:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details ZSH & Git

1. Em seu `~/.zshrc` remova as linhas do `asdf.sh` e seus complementos:

```shell
. "$HOME/.asdf/asdf.sh"
# ...
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit
compinit
```

**Ou** use ZSH Framework plugin.

2. Remova o diretório `$HOME/.asdf`:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
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
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
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
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

4. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

Tudo pronto! 🎉

# Começando

> Hi, we've recently migrated our docs and added some new pages. If you would like to help translate this page, see the "Edit this page" link at the bottom of the page.

A instalação do `asdf` envolve:

1. Instalar as dependências
2. Instalar o núcleo do `asdf`
3. Adicionar o `asdf` ao seu shell
4. Instalar um plugin para cada ferramenta que você gostaria de gerenciar
5. Instalar uma versão desta ferramenta
6. Definir uma versão global e uma versão local através do arquivo de configuração `.tool-versions`

Você pode também acompanhar o passo a passo da instalação através [deste vídeo](https://youtu.be/8W3xaSPjeog).

## 1. Instalando as dependências

asdf primarily requires `git` & `curl`. Here is a _non-exhaustive_ list of commands to run for _your_ package manager (some might automatically install these tools in later steps).

| OS    | Package Manager | Command                            |
| ----- | --------------- | ---------------------------------- |
| linux | Aptitude        | `apt install curl git`             |
| linux | DNF             | `dnf install curl git`             |
| linux | Pacman          | `pacman -S curl git`               |
| linux | Zypper          | `zypper install curl git`          |
| macOS | Homebrew        | `brew install coreutils curl git`  |
| macOS | Spack           | `spack install coreutils curl git` |

::: tip Note

`sudo` may be required depending on your system configuration.

:::

## 2. Download asdf

### Official Download

<!-- x-release-please-start-version -->

```shell:no-line-numbers
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0
```

<!-- x-release-please-end -->

### Community Supported Download Methods

We highly recommend using the official `git` method.

| Method   | Command                                                                                                                                                             |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Homebrew | `brew install asdf`                                                                                                                                                 |
| Pacman   | `git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si` or use your preferred [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) |

## 3. Adicionando ao seu shell

Existem diversas combinações de shells, sistemas operacionais e métodos de instalação que podem impactar a configuração. Abaixo, expanda a seção que se adeque mais com o seu sistema:

::: details Bash & Git

Adicione esta linha ao seu `~/.bashrc`:

```shell
. "$HOME/.asdf/asdf.sh"
```

O auto completar deve ser configurado manualmente a partir da adição da seguinte linha ao `.bashrc`:

```shell
. "$HOME/.asdf/completions/asdf.bash"
```

:::

::: details Bash & Git (macOS)

Se você estiver usando o **macOS Catalina ou mais recente**, o shell padrão mudou para o **ZSH**. A não ser que você tenha voltado para o bash, siga as instruções de instalação para o ZSH.

Adicione esta linha ao seu `~/.bash_profile`:

```shell
. "$HOME/.asdf/asdf.sh"
```

O auto completar deve ser configurado manualmente a partir da adição da seguinte linha ao `.bash_profile`:

```shell
. "$HOME/.asdf/completions/asdf.bash"
```

:::

::: details Bash & Homebrew

Adicione `asdf.sh` ao `~/.bashrc` através do comando:

```shell:no-line-numbers
echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.bashrc
```

O auto completar deve ser configurado seguindo as [instruções da Homebrew](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash), ou as seguintes:

```shell:no-line-numbers
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bashrc
```

:::

::: details Bash & Homebrew (macOS)

Se você estiver usando o **macOS Catalina ou mais recente**, o shell padrão mudou para o **ZSH**. A não ser que você tenha voltado para o bash, siga as instruções de instalação para o ZSH.

Adicione `asdf.sh` ao `~/.bash_profile` através do comando:

```shell:no-line-numbers
echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.bash_profile
```

O auto completar deve ser configurado seguindo as [instruções da Homebrew](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash), ou as seguintes:

```shell:no-line-numbers
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bash_profile
```

:::

::: details Bash & Pacman

Adicione a seguinte linha ao seu `~/.bashrc`:

```shell
. /opt/asdf-vm/asdf.sh
```

O [pacote `bash-completion`](https://wiki.archlinux.org/title/bash#Common_programs_and_options) precisa ser instalado para o auto completar funcionar.
:::

::: details Fish & Git

Adicione a seguinte linha ao seu `~/.config/fish/config.fish`:

```shell
source ~/.asdf/asdf.fish
```

O auto completar deve ser configurado manualmente através do seguinte comando:

```shell:no-line-numbers
mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

:::

::: details Fish & Homebrew

Adicione `asdf.fish` ao seu `~/.config/fish/config.fish` através do comando:

```shell:no-line-numbers
echo -e "\nsource "(brew --prefix asdf)"/asdf.fish" >> ~/.config/fish/config.fish
```

O auto completar é [configurado pela Homebrew para o fish shell](https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish).
:::

::: details Fish & Pacman

Adicione a seguinte linha ao seu `~/.config/fish/config.fish`:

```shell
source /opt/asdf-vm/asdf.fish
```

O auto completar é configurado automaticamente durante a instalação do pacote AUR.
:::

::: details Elvish & Git

Adicione `asdf.elv` ao `~/.config/elvish/rc.elv` através do comando:

```shell:no-line-numbers
mkdir -p ~/.config/elvish/lib; ln -s ~/.asdf/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

Ao concluir atualizará automaticamente

:::

::: details Elvish & Homebrew

Adicione `asdf.elv` ao `~/.config/elvish/rc.elv` através do comando:

```shell:no-line-numbers
mkdir -p ~/.config/elvish/lib; ln -s (brew --prefix asdf)/libexec/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

Ao concluir atualizará automaticamente
:::

::: details Elvish & Pacman

Adicione `asdf.elv` ao `~/.config/elvish/rc.elv` através do comando:

```shell:no-line-numbers
mkdir -p ~/.config/elvish/lib; ln -s /opt/asdf-vm/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

Ao concluir atualizará automaticamente
:::

::: details ZSH & Git

Adicione a seguinte linha ao seu `~/.zshrc`:

```shell
. "$HOME/.asdf/asdf.sh"
```

**OU** utilize um framework para ZSH, como [asdf para oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) que irá adicionar o script e o auto completar.

O auto completar pode ser configurado ou pelo plugin do asdf para framework para ZSH, ou através da adição das seguintes linhas ao seu `.zshrc`:

```shell
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
```

- Se você está utilizando uma configuração `compinit` customizada, garanta que `compinit` esteja abaixo chamada `asdf.sh`
- Se você está utilizando uma configuração `compinit` customizada com um framework para ZSH, garanta que `compinit` esteja abaixo da chamada do framework.

**Aviso**

Se você está utilizando um framework para ZSH, o plugin do asdf pode precisar ser atualizado para utilização adequada do novo auto completar do ZSH através do `fpath`. O plugin do asdf para o oh-my-zsh ainda não foi atualizado, veja: [ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837).
:::

::: details ZSH & Homebrew

Adicione `asdf.sh` ao seu `~/.zshrc` através do comando:

```shell
echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
```

**OU** utilize um framework para ZSH, como [asdf para oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) que irá adicionar o script e o auto completar.

O auto completar pode ser configurado ou pelo framework para ZSH, ou de acordo com as [instruções da Homebrew](https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh). Se você está usando um framework para ZSH, pode ser que seja necessário atualizar o plugin do asdf para que o novo auto completar funcione adequadamente através do `fpath`. O plugin do asdf para o Oh-My-ZSH ainda será atualizado, veja: [ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837).
:::

::: details ZSH & Pacman

Adicione a seguinte linha ao seu `~/.zshrc`:

```shell
. /opt/asdf-vm/asdf.sh
```

::: details PowerShell Core & Git

Adicione a seguinte linha ao seu `~/.config/powershell/profile.ps1`:

```shell
. "$HOME/.asdf/asdf.ps1"
```

:::

::: details PowerShell Core & Homebrew

Adicione `asdf.ps1` ao seu `~/.config/powershell/profile.ps1` através do comando:

```shell:no-line-numbers
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.ps1\"" >> ~/.config/powershell/profile.ps1
```

:::

::: details PowerShell Core & Pacman

Adicione a seguinte linha ao seu `~/.config/powershell/profile.ps1`:

```shell
. /opt/asdf-vm/asdf.ps1
```

:::

::: details Nushell & Git

Adicione `asdf.nu` ao seu `~/.config/nushell/config.nu` através do comando:

```shell
"\nlet-env ASDF_NU_DIR = ($env.HOME | path join '.asdf')\n source " + ($env.HOME | path join '.asdf/asdf.nu') | save --append $nu.config-path
```

Ao concluir atualizará automaticamente
:::

::: details Nushell & Homebrew

Adicione `asdf.nu` ao seu `~/.config/nushell/config.nu` através do comando:

```shell:no-line-numbers
"\nlet-env ASDF_NU_DIR = (brew --prefix asdf | str trim | into string | path join 'libexec')\n source " +  (brew --prefix asdf | into string | path join 'libexec/asdf.nu') | save --append $nu.config-path
```

Ao concluir atualizará automaticamente
:::

::: details Nushell & Pacman

Adicione `asdf.nu` ao seu `~/.config/nushell/config.nu` através do comando:

```shell
"\nlet-env ASDF_NU_DIR = '/opt/asdf-vm/'\n source /opt/asdf-vm/asdf.nu" | save --append $nu.config-path
```

Ao concluir atualizará automaticamente
:::

::: details POSIX Shell & Git

Adicione a seguinte linha ao seu `~/.profile`:

```shell
export ASDF_DIR="$HOME/.asdf"
. "$HOME/.asdf/asdf.sh"
```

:::

::: details POSIX Shell & Homebrew

Adicione `asdf.sh` ao `~/.profile` através do comando:

```shell:no-line-numbers
echo -e "\nexport ASDF_DIR=\"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.profile
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.profile
```

:::

::: details POSIX Shell & Pacman

Adicione a seguinte linha ao seu `~/.profile`:

```shell
export ASDF_DIR="/opt/asdf-vm"
. /opt/asdf-vm/asdf.sh
```

:::

O auto completar é colocado em um local familiar para o ZSH, [mas o ZSH deve ser configurado para conseguir utilizá-lo](https://wiki.archlinux.org/index.php/zsh#Command_completion).
:::

Os scripts do `asdf` precisam ser chamados **depois** de ter configurado a sua variável `$PATH` e **depois** de ter chamado o seu framework para ZSH (oh-my-zsh etc).

Reinicie seu shell para que as mudanças na variável `PATH` tenham efeito. Abrir uma nova janela/sessão de terminal o fará.

## 4. Instalando um plugin

Para demonstração, vamos instalar e configurar o [Node.js](https://nodejs.org/) através do plugin [`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/).

### Dependências dos plugins

Cada plugin possui algumas dependências, por isso precisamos checar no repositório onde elas estão listadas. Por exemplo, para o `asdf-nodejs` são:

| SO             | Instalação de dependencia               |
| -------------- | --------------------------------------- |
| Linux (Debian) | `apt-get install dirmngr gpg curl gawk` |
| macOS          | `brew install gpg gawk`                 |

Devemos instalar instalar as dependências primeiro, pois alguns plugins exigem algumas ações após a instalação.

### Instalando o plugin

```shell:no-line-numbers
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## 5. Instalando uma versão

Agora temos o plugin para o Node.js, nós podemos instalar uma versão desta ferramenta.

Podemos ver quais versões tão disponíveis através do comando `asdf list all nodejs`, ou uma lista específica de versões com `asdf list all nodejs 14`

Vamos instalar somente a última versão disponível, utilizando a tag `latest`:

```shell:no-line-numbers
asdf install nodejs latest
```

::: tip Nota
`asdf` exige versões exatas. A palavra `latest` resulta na instalação da versão atual na data da execução.
:::

## 6. Definindo uma versão

`asdf` executa uma verificação das versões das ferramentas a serem utilizadas através do arquivo `.tool-versions` presente desde diretório atual, até o diretório `$HOME`. A varredura ocorre no momento em que você executa uma ferramenta que o asdf gerencia.

::: warning
Se uma versão não for especificada para uma ferramenta, ao executá-la resultará em erro. `asdf current` mostrará a ferramenta e sua versão, ou então a falta dela no seu diretório atual para que você possa observar quais ferramentas falharão ao serem executadas.
:::

### Versões globais

Os padrões globais são gerenciados em `$HOME/.tool-versions`. Defina uma versão global através do comando:

```shell:no-line-numbers
asdf global nodejs latest
```

`$HOME/.tool-versions` ficará assim:

```
nodejs 16.5.0
```

Alguns sistemas operacionais vêm por padrão com ferramentas que são gerenciadas pelo próprio sistema e não pelo `asdf`, `python` é um exemplo. Você precisa indicar para o `asdf` para devolver o gerenciamento para o sistema. A [seção de referência de versões](/pt-br/manage/versions.md) irá guiá-lo.

### Versões locais

Versões locais são definidas no arquivo `$PWD/.tool-versions` (seu diretório atual). Geralmente, será um repositório Git para um projeto. Quando estiver no diretório desejado, execute:

```shell:no-line-numbers
asdf local nodejs latest
```

`$PWD/.tool-versions` ficará assim:

```
nodejs 16.5.0
```

### Usando arquivos de versão existentes

`asdf` suporta a migração de arquivos de versão provenientes de outros gerenciadores de versão. Por exemplo: `.ruby-version` para o `rbenv`. Essa funcionalidade é baseada no plugin de cada ferramenta.

O [`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/) suporta tanto arquivos `.nvmrc` quanto `.node-version`. Para ativar essa funcionalidade, adicione a seguinte linha ao seu arquivo de configuração do `asdf` - `$HOME/.asdfrc`:

```
legacy_version_file = yes
```

Veja a página de refencia da [configuração](/pt-br/manage/configuration.md) para mais opções de configuração.

## Setup finalizado!

A configuração inicial do `asdf` foi finalizada :tada:. Agora, você pode gerenciar versões do `nodejs` para o seus projetos. Siga passos semelhantes para cada ferramenta do seu projeto.

O `asdf` possui diversos outros comandos para se acustomar ainda, você pode ver todos eles através do comando `asdf --help` ou simplesmente `asdf`. Eles estão divididos em três categorias:

- [núcleo `asdf`](/pt-br/manage/core.md)
- [plugins](/pt-br/manage/plugins.md)
- [versões (de ferramentas)](/pt-br/manage/versions.md)

1. [Gerenciar asdf](/pt-br/core-manage-asdf): instalar `asdf` **e** adicionar `asdf` ao seu shell
2. [Gerenciar Plugins](/pt-br/core-manage-plugins): adicionar plugin para sua ferramenta `asdf plugin add nodejs`
3. [Gerenciar Versões](/pt-br/core-manage-versions): instalar uma versão da sua ferramenta `asdf install nodejs 13.14.0`
4. [Configuração](/pt-br/core-configuration): configurações globais e de seu projeto em `.tool-versions`

## Instalar

### Dependências

<!-- select:start -->
<!-- select-menu-labels: Sistema Operacional,Método de Instalação -->

#### -- Linux,Aptitude --

```shell
sudo apt install curl git
```

#### -- Linux,DNF --

```shell
sudo dnf install curl git
```

#### -- Linux,Pacman --

```shell
sudo pacman -S curl git
```

#### -- Linux,Zypper --

```shell
sudo zypper install curl git
```

#### -- macOS,Homebrew --

Dependências seram instaladas automaticamente pelo Homebrew. 

#### -- macOS,Spack --

```shell
spack install coreutils curl git
```

### -- Docsify Select Default --

Não encontrado seleção para seu _Sistema Operacional_ e _Método de Instalação_. Por favor tente outra combinação.

<!-- select:end -->

### asdf

<!-- select:start -->
<!-- select-menu-labels: Método de Instalação -->

### --Git--

Clone somente a _branch_ mais recente:

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
```

Alternativa, você pode clonar o repositório completo e verificar a _branch_ mais recente:

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout "$(git describe --abbrev=0 --tags)"
```

### --Homebrew--

Seja a compatibilidade de `asdf` e Homebrew em [issues in #785](https://github.com/asdf-vm/asdf/issues/785).

Instalar usando o gerenciador de pacotes Homebrew:

```shell
brew install asdf
```

Para pegar as mudanças mais recentes, você pode mandar o Homebrew obter a _branch_ central do repositório: 

```shell
brew install asdf --HEAD
```

### --Pacman--

Instalar usando `pacman`:

```shell
git clone https://aur.archlinux.org/asdf-vm.git
cd asdf-vm
makepkg -si
```
Ou use outro de sua preferência [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) 

<!-- select:end -->

### Adicionando ao seu Shell

<!-- select:start -->
<!-- select-menu-labels: Sistema Operacional,Shell,Método de Instalação -->

#### --Linux,Bash,Git--

Adicione em seu `~/.bashrc`:

```shell
. $HOME/.asdf/asdf.sh
```

?> Adicione também em seu `.bashrc`:

```shell
. $HOME/.asdf/completions/asdf.bash
```

#### --Linux,Fish,Git--

Adicione em seu `~/.config/fish/config.fish`:

```shell
source ~/.asdf/asdf.fish
```

?> Execute o comando:

```shell
mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

#### --Linux,ZSH,Git--

Adicione em seu `~/.zshrc`:

```shell
. $HOME/.asdf/asdf.sh
```
**Ou** use o ZSH Framework plugin descrito em [asdf para oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) para concluir sua configuração.

?> As configurações são completadas através do ZSH Framework `asdf` plugin ou pelas modificações feitas em `.zshrc`:

```shell
# adicione ao seu fpath
fpath=(${ASDF_DIR}/completions $fpath)
# termine usando os comandos do ZSH's compinit
autoload -Uz compinit
compinit
```
 
- Caso tiver usando uma costumização de `compinit`, garanta que seu `compinit` esteja dentro do arquivo `asdf.sh`
- Caso tiver usando uma costumização de `compinit` e ZSH Framework, garanta que `compinit` esteja dentro do framework

!> Caso tiver usando ZSH Framework em conjunto com `asdf`, talvez seja necessário atualizar os complementos de ZSH no `fpath`. Para atualizar Oh-My-ZSH asdf plugin, seja em https://github.com/ohmyzsh/ohmyzsh/pull/8837.

#### --Linux,Bash,Pacman--

Adicione em seu `~/.bashrc`:

```shell
. /opt/asdf-vm/asdf.sh
```

?> [`bash-completion` needs to be installed for the completions to work](https://wiki.archlinux.org/title/bash#Common_programs_and_options)

#### --Linux,Fish,Pacman--

Adicione em seu `~/.config/fish/config.fish`:

```shell
source /opt/asdf-vm/asdf.fish
```

!> Os complementos são automaticamente configurados na instalação feita pelo pacote AUR.

#### --Linux,ZSH,Pacman--

Adicione em seu `~/.zshrc`:

```shell
. /opt/asdf-vm/asdf.sh
```

?> Os complementos são colocados em um local escolhido pelo ZHS, para mais [ZSH deve ser usado para configurações dos complementos](https://wiki.archlinux.org/index.php/zsh#Command_completion).

#### --macOS,Bash,Git--

Caso esteja usando **macOs Catalina ou mais recente**, por padrão o _shell_ é **ZSH**. Para voltar ao _Bash_ siga as instruções do ZSH.

Adicione em seu `~/.bash_profile`:

```shell
. $HOME/.asdf/asdf.sh
```
 
?> Os complementos precisam ser configurados manualmente em seu arquivo `.bash_profile`:

```shell
. $HOME/.asdf/completions/asdf.bash
```

#### --macOS,Fish,Git--

Adicione em seu `~/.config/fish/config.fish`:

```shell
source ~/.asdf/asdf.fish
```

?> Os complementos precisam ser configurados manualmente com esse comando:

```shell
mkdir -p ~/.config/fish/completions; and cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

#### --macOS,ZSH,Git--

Adicione em seu `~/.zshrc`:

```shell
. $HOME/.asdf/asdf.sh
```

**Ou** use ZSH Framework plugin descrito em [asdf para oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) que irá realizar as configurações.  

?> Os complementos são conficurados usando ZSH Framework `asdf` plugin ou através do arquivo `.zshrc`:

```shell
# adicione em seu fpath
fpath=(${ASDF_DIR}/completions $fpath)
# termine usando os comandos do ZSH's compinit
autoload -Uz compinit
compinit
```
- Caso tiver usando uma costumização de `compinit`, garanta que seu `compinit` esteja dentro do arquivo `asdf.sh`
- Caso tiver usando uma costumização de `compinit` e ZSH Framework, garanta que `compinit` esteja dentro do framework

!> Caso tiver usando ZSH Framework em conjunto com `asdf`, talvez seja necessário atualizar os complementos de ZSH no `fpath`. Para atualizar Oh-My-ZSH asdf plugin, seja em https://github.com/ohmyzsh/ohmyzsh/pull/8837.

#### --macOS,Bash,Homebrew--

Caso esteja usando **macOs Catalina ou mais recente**, por padrão o _shell_ é **ZSH**. Para voltar ao _Bash_ siga as instruções do ZSH.

Adicione `asdf.sh` ao seu `~/.bash_profile` usando:

```shell
echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.bash_profile
```

?> Os complementos precisam [instruções de configuração do Homebrew](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) ou usando:

```shell
echo -e "\n. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" >> ~/.bash_profile
```

#### --macOS,Fish,Homebrew--

Adicione `asdf.fish` ao seu `~/.config/fish/config.fish` usando:

```shell
echo -e "\nsource "(brew --prefix asdf)"/asdf.fish" >> ~/.config/fish/config.fish
```

?> Os complementos são [manipulados pelo Homebrew para o Fish shell](https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish). Legal!

#### --macOS,ZSH,Homebrew--

Adicione `asdf.sh` ao seu `~/.zshrc` usando:

```shell
echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
```

**Ou** use ZSH Framework plugin descrito em [asdf para oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) que irá realizar as configurações.

?> Os complementos são configurados pelo ZSH Framework `asdf` ou precisam [instruções de configuração do Homebrew](https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh)

Caso tiver usando ZSH Framework em conjunto com `asdf`, talvez seja necessário atualizar os complementos de ZSH no `fpath`. Para atualizar Oh-My-ZSH asdf plugin, seja em https://github.com/ohmyzsh/ohmyzsh/pull/8837.

### --Docsify Select Default--

!> O `Homebrew` `asdf` não possui testes no `Linux` feitos pelo time central do asdf. Por favor reporte os problemas para que possamos atualizar nossa documentação.

<!-- select:end -->

Reinicie seu _shell_ para que as mudanças no _PATH_ sejam efetivadas.

Esta tudo pronto para usar asdf 🎉

### Possui questionamentos?

Caso tenha questionamentos sobre seu _shell_ não detectadas em instalações mais recentes, pode ser que `asdf.sh` ou `asdf.fish` não iniciou o **BOTTOM** em seu arquivo de configuração `.bash_profile`, `.zshrc`, `config.fish`. É preciso do **AFETER** em seu `$PATH` e **AFTER** precisa estar em seu framework (oh-my-zsh etc).
you have sourced your framework (oh-my-zsh etc).

### Migrando de ferramentas

Caso tenha migrado para outra ferramenta e precisar usar as arquivos de versão (ex: `.node-version` ou `.ruby-version`),
olhe em seu `legacy_version_file` [marcação de seleção de configuração](core-configuration?id=homeasdfrc).

## Atualizar

<!-- select:start -->
<!-- select-menu-labels: Método de Instalação -->

### -- Git --

```shell
asdf update
```

Caso queira as últimas mudanças, essas mudanças não estão incluídas na versão estável:

```shell
asdf update --head
```

### -- Homebrew --

```shell
brew upgrade asdf
```

### -- Pacman --

Obter manualmente um novo `PKGBUILD` e reconstruir ou usar suas preferências de AUR.

<!-- select:end -->

## Remover

Para desinstalar `asdf` siga os passos:

<!-- select:start -->
<!-- select-menu-labels: Sistema Operacional,Shell,Método de Instalação -->

### --Linux,Bash,Git--

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

### --Linux,Fish,Git--

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

### --Linux,ZSH,Git--

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

### --Linux,Bash,Pacman--

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

### --Linux,Fish,Pacman--

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

### --Linux,ZSH,Pacman--

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

### --macOS,Bash,Git--

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

### --macOS,Fish,Git--

1. Em seu `~/.config/fish/config.fish` remova as linhas do `asdf.fish`:

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

### --macOS,ZSH,Git--

1. Em seu `~/.zshrc` remova as linhas do `asdf.sh` e remova seus complementos:

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

### --macOS,Bash,Homebrew--

Caso esteja usando **macOs Catalina ou mais recente**, por padrão o _shell_ é **ZSH**. Se não achar alguma configuração em seu `~/.bash_profile` talvez esteja em `~/.zshrc` em cada caso siga as intruções do ZSH.

1. Em seu `~/.bash_profile` remova as linhas do `asdf.sh` e remova seus complementos:

```shell
. $(brew --prefix asdf)/asdf.sh
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

### --macOS,Fish,Homebrew--

1. Em seu `~/.config/fish/config.fish` remova as linhas do `asdf.fish`:

```shell
source "(brew --prefix asdf)"/asdf.fish
```

2. Desinstale usando seu gerenciador de pacotes:

```shell
brew uninstall asdf --force
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

### --macOS,ZSH,Homebrew--

1. Em seu `~/.zshrc` remova as linhas do `asdf.sh`:

```shell
. $(brew --prefix asdf)/asdf.sh
```

2. Desinstale usando seu gerenciador de pacotes:

```shell
brew uninstall asdf --force
```

3. Execute o comando para remover todos os arquivos de configurações do `asdf`:

```shell
rm -rf $HOME/.tool-versions $HOME/.asdfrc
```

<!-- select:end -->

Tudo pronto! 🎉

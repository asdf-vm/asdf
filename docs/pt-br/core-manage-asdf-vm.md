## Instalar o asdf-vm

Clonar apenas o branch mais atual:

```shell
git clone git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.3
```

Alternativamente, você pode clonar o repositório inteiro e fazer checkout para o último branch:

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout "$(git describe --abbrev=0 --tags)"
```

### Adicione ao seu Shell

<!-- tabs:start -->

#### ** Bash no Linux **

```bash
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
```

#### ** Bash no macOS **

```bash
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bash_profile
```

#### **ZSH**

Se você estiver usando um framework, como o oh-my-zsh, use essas linhas. (Certifique-se de que caso você faça alterações futuras no .zshrc essas linhas permaneçam _abaixo_ da linha onde você define seu framework).

```shell
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc
```

Se você não estiver usando um framwork, ou se ao iniciar seu shell você obtiver uma mensagem de erro como 'command not found: compinit', adicione esta linha antes das linhas acima.

```shell
autoload -Uz compinit && compinit
```

#### ** Fish **

```shell
echo 'source ~/.asdf/asdf.fish' >> ~/.config/fish/config.fish
mkdir -p ~/.config/fish/completions; and cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

<!-- tabs:end -->

Reinicie seu shell para que as alterações no PATH entrem em vigor. (Abrir uma nova aba do terminal geralmente faz isso)

### Com problenas?

!> Se você está tendo problemas com o asdf não detectando os shims que você instalou, é mais provável que seja devido à referência acima ao `asdf.bash` ou `asdf.fish` não estar no **fim** do seu `~/.bash_profile`, `~/.zshrc`, ou `~/.config/fish/config.fish`. Ele precisa ser referenciado **APÓS** a definição do seu `$PATH`.

## Dependências de Plugins

?> Para a maioria dos plugins, é bom que você tenha instalado os seguintes pacotes OU seus equivalentes no seu SO

<!-- tabs:start -->

#### ** macOS **

Instale via homebrew:

```shell
brew install \
  coreutils automake autoconf openssl \
  libyaml readline libxslt libtool unixodbc
```

#### ** Ubuntu **

```shell
sudo apt install \
  automake autoconf libreadline-dev \
  libncurses-dev libssl-dev libyaml-dev \
  libxslt-dev libffi-dev libtool unixodbc-dev
```

#### **Fedora**

```shell
sudo dnf install \
  automake autoconf readline-devel \
  ncurses-devel openssl-devel libyaml-devel \
  libxslt-devel libffi-devel libtool unixODBC-devel
```

<!-- tabs:end -->

Isso é tudo! Você está pronto para usar o asdf 🎉

## Atualização

```shell
asdf update
```

Se você quiser as últimas mudanças que ainda não foram incluídas em um release estável:

```shell
asdf update --head
```

## Remover

Desinstalar o `asdf` é tão simples quanto:

1. No seu arquivo `.bashrc` (or `.bash_profile` se estiver no OSX) ou `.zshrc` encontre as linhas que referenciam o `asdf.sh` e as autocompletions. As linhas devem se parecer com isso:

    ```shell
    . $HOME/.asdf/asdf.sh
    . $HOME/.asdf/completions/asdf.bash
    ```

    Remova essas linhas e salve o arquivo.

2. Execute `rm -rf ~/.asdf/ ~/.tool-versions` para remover por completo todos os arquivos to asdf de seu sistema.

É isso aí! 🎉
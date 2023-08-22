# asdf

> Hi, we've recently migrated our docs and added some new pages. If you would like to help translate this page, see the "Edit this page" link at the bottom of the page.

guia de contribuição principal `asdf`.

## Configuração inicial

Fork `asdf` no GitHub e/ou Git clone o branch padrão:

```shell
# clone your fork
git clone https://github.com/<GITHUB_USER>/asdf.git
# or clone asdf
git clone https://github.com/asdf-vm/asdf.git
```

As ferramentas para o desenvolvimento do núcleo estão em `.tool-versions` deste repositório.  Se você deseja gerenciar com o próprio `asdf`, adicione os plugins:

```shell
asdf plugin add bats https://github.com/timgluz/asdf-bats.git
asdf plugin add shellcheck https://github.com/luizm/asdf-shellcheck.git
asdf plugin add shfmt https://github.com/luizm/asdf-shfmt.git
```

Instale as versões para desenvolver `asdf` com:

```shell
asdf install
```

_pode_ ser útil não usar `asdf` para gerenciar as ferramentas durante o desenvolvimento em sua máquina local, pois você pode precisar quebrar funcionalidades que, então, quebrariam suas ferramentas de desenvolvimento.  Aqui está a lista bruta de ferramentas:

- [bats-core](https://github.com/bats-core/bats-core): Bash Automated Testing System, para testes unitários de scripts compatíveis com Bash ou POSIX.
- [shellcheck](https://github.com/koalaman/shellcheck): Ferramenta de análise estática para scripts de shell.
- [shfmt](https://github.com/mvdan/sh): Um analisador, formatador e interpretador de shell com suporte a bash; inclui shfmt

## Desenvolvimento

Se você quiser testar suas alterações sem fazer alterações em seu `asdf` instalado, você pode definir a variável `$ASDF_DIR` para o caminho onde você clonou o repositório e anexar temporariamente o diretório `bin` e `shims` do diretório para o seu caminho.

É melhor formatar, lint e testar seu código localmente antes de confirmar ou enviar para o controle remoto. Use os seguintes scripts/comandos:

```shell
# Shellcheck
./scripts/shellcheck.bash

# Format
./scripts/shfmt.bash

# Test: all tests
bats test/
# Test: for specific command
bats test/list_commands.bash
```

::: tip

 **Adicione testes!** - Os testes são **necessários** para novos recursos e aceleram a revisão de correções de bugs.  Por favor, cubra novos caminhos de código antes de criar um Pull Request.  Consulte [documentação do bats-core](https://bats-core.readthedocs.io/en/stable/index.html)

:::

## Teste de BATS

É **fortemente recomendado** examinar o conjunto de testes existente e a [documentação do bats-core](https://bats-core.readthedocs.io/en/stable/index.html) antes de escrever os testes.

A depuração de BATs pode ser difícil às vezes. Usar a saída TAP com o sinalizador `-t` permitirá que você imprima saídas com o descritor de arquivo especial `>&3` durante a execução do teste, simplificando a depuração. Como um exemplo:

```shell
# test/some_tests.bats

printf "%s\n" "Will not be printed during bats test/some_tests.bats"
printf "%s\n" "Will be printed during bats -t test/some_tests.bats" >&3
```

Isso está documentado em bats-core [Imprimindo no Terminal](https://bats-core.readthedocs.io/en/stable/writing-tests.html#printing-to-the-terminal).

## Pull Requests, Releases e Commits Convencionais

O `asdf` está usando uma ferramenta de lançamento automatizada chamada [Release Please](https://github.com/googleapis/release-please) para aumentar automaticamente a versão [SemVer](https://semver.org/) e gerar a [Changelog](https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md).  Essas informações são determinadas lendo o histórico de confirmação desde a última versão.

[Mensagens de confirmação convencionais](https://www.conventionalcommits.org/) definem o formato do título da solicitação pull que se torna o formato da mensagem de confirmação na ramificação padrão. Isso é aplicado com GitHub Action [`amannn/action-semantic-pull-request`](https://github.com/amannn/action-semantic-pull-request).

O Commit Convencional segue este formato:

```
<type>[optional scope][optional !]: <description>

<!-- examples -->
fix: some fix
feat: a new feature
docs: some documentation update
docs(website): some change for the website
feat!: feature with breaking change
```

A lista completa de `<types>` é: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

O `!` indica uma mudança de ruptura.

`fix`: will create a new SemVer `patch`
`feat`: will create a new SemVer `minor`
`<type>!`: will create a new SemVer `major`

O título da solicitação pull deve seguir este formato.

::: tip

Use o formato de mensagem de confirmação convencional para seu título de solicitação de pull.

:::

## Imagens Docker

Os projetos [asdf-alpine](https://github.com/vic/asdf-alpine) e [asdf-ubuntu](https://github.com/vic/asdf-ubuntu) são um esforço contínuo para fornecer imagens de algumas ferramentas asdf.  Você pode usar essas imagens docker como base para seus servidores de desenvolvimento ou para executar seus aplicativos de produção.

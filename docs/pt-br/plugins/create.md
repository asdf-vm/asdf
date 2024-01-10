# Criar um plug-in

> Hi, we've recently migrated our docs and added some new pages. If you would like to help translate this page, see the "Edit this page" link at the bottom of the page.

## O que há em um plug-in

Um plugin é um repositório git, com alguns scripts executáveis, para dar suporte ao versionamento de outra linguagem ou ferramenta.  Esses scripts são executados quando os comandos `list-all`, `install` ou `uninstall` são executados.  Você pode definir ou desmarcar env vars e fazer qualquer coisa necessária para configurar o ambiente para a ferramenta.

## Scripts obrigatórios


- `bin/list-all` - lista todas as versões instaláveis
- `bin/download` - baixe o código fonte ou binário para a versão especificada
- `bin/install` - instala a versão especificada

## Variavéis de Ambiente

Todos os scripts, exceto `bin/list-all`, terão acesso aos seguintes env vars para agir:

- `ASDF_INSTALL_TYPE` - `version` ou `ref`
- `ASDF_INSTALL_VERSION` - se `ASDF_INSTALL_TYPE` é `version` então este será o número da versão. Caso contrário, será o git ref que será passado. Pode apontar para uma tag/commit/branch no repositório.
- `ASDF_INSTALL_PATH` - o diretório onde _foi_ instalado (ou _deve_ ser instalado no caso do script `bin/install`)

Essas variáveis de ambiente adicionais estarão disponíveis para o script `bin/install`:

- `ASDF_CONCURRENCY` - o número de núcleos a serem usados ao compilar o código-fonte. Útil para definir `make -j`.
- `ASDF_DOWNLOAD_PATH` - o caminho para onde o código fonte ou binário foi baixado pelo script `bin/download`.

Essas variáveis de ambiente adicionais estarão disponíveis para o script `bin/download`:

- `ASDF_DOWNLOAD_PATH` - o caminho para onde o código-fonte ou binário deve ser baixado.

#### bin/list-all

Deve imprimir uma string com uma lista de versões separadas por espaço. A saída de exemplo seria a seguinte:

```shell
1.0.1 1.0.2 1.3.0 1.4
```

Observe que a versão mais recente deve ser listada por último para que apareça mais próxima do prompt do usuário. Isso é útil já que o comando `list-all` imprime cada versão em sua própria linha. Se houver muitas versões, é possível que as primeiras versões fiquem fora da tela.

Se as versões estiverem sendo extraídas da página de lançamentos em um site, é recomendável não classificar as versões, se possível. Muitas vezes as versões já estão na ordem correta ou, na ordem inversa, nesse caso algo como `tac` deve ser suficiente. Se você precisar classificar as versões manualmente, não poderá confiar em `sort -V`, pois não é suportado no OSX. Uma função de classificação alternativa [como esta é uma escolha melhor](https://github.com/vic/asdf-idris/blob/master/bin/list-all#L6).

#### bin/download

Este script deve baixar o código fonte ou binário, no caminho contido na variável de ambiente `ASDF_DOWNLOAD_PATH`. Se o código-fonte ou binário baixado estiver compactado, apenas o código-fonte ou binário descompactado poderá ser colocado no diretório `ASDF_DOWNLOAD_PATH`.

O script deve sair com um status de `0` quando o download for bem-sucedido. Se o download falhar, o script deve sair com qualquer status de saída diferente de zero.

Se possível, o script deve apenas colocar arquivos no `ASDF_DOWNLOAD_PATH`.  Se o download falhar, nenhum arquivo deve ser colocado no diretório.

Se este script não estiver presente, o asdf assumirá que o script `bin/install` está presente e fará o download e instalará a versão. asdf só funciona sem este script para suportar plugins legados. Todos os plugins devem incluir este script e, eventualmente, o suporte para plugins legados será removido.

#### bin/install

Este script deve instalar a versão, no caminho mencionado em `ASDF_INSTALL_PATH`. Por padrão, o asdf criará shims para qualquer arquivo em `$ASDF_INSTALL_PATH/bin` (isso pode ser personalizado com o script opcional [bin/list-bin-paths](#binlist-bin-paths)).

O script de instalação deve sair com um status de `0` quando a instalação for bem-sucedida.  Se a instalação falhar, o script deve sair com qualquer status de saída diferente de zero.

Se possível, o script deve apenas colocar os arquivos no diretório `ASDF_INSTALL_PATH` uma vez que a compilação e instalação da ferramenta são consideradas bem sucedidas pelo script de instalação. asdf [verifica a existência](https://github.com/asdf-vm/asdf/blob/242d132afbf710fe3c7ec23c68cec7bdd2c78ab5/lib/utils.sh#L44) do diretório `ASDF_INSTALL_PATH` para determinar se essa versão da ferramenta está instalado. Se o diretório `ASDF_INSTALL_PATH` for preenchido no início do processo de instalação, outros comandos asdf executados em outros terminais durante a instalação podem considerar essa versão da ferramenta instalada, mesmo quando não estiver totalmente instalada.

Se você quiser que seu plugin funcione com asdf versão 0.7._ e anterior e versão 0.8._ e mais recente, verifique a presença da variável de ambiente `ASDF_DOWNLOAD_PATH`.  Se não estiver definido, baixe o código-fonte no retorno de chamada bin/install.  Se estiver definido, suponha que o script `bin/download` já tenha baixado.

## Scripts Opcional

#### scripts bin/help

Este não é um script de retorno de chamada, mas sim um conjunto de scripts de retorno de chamada que imprimem documentação diferente para STDOUT. Os scripts de retorno de chamada possíveis estão listados abaixo. Observe que `bin/help.overview` é um caso especial, pois deve estar presente para que qualquer saída de ajuda seja exibida para o script.

- `bin/help.overview` - Este script deve gerar uma descrição geral sobre o plugin e a ferramenta que está sendo gerenciada. Nenhum título deve ser impresso, pois o asdf imprimirá títulos. A saída pode ser um texto de formato livre, mas idealmente apenas um parágrafo curto. Este script deve estar presente se você quiser que o asdf forneça informações de ajuda para seu plugin. Todos os outros scripts de retorno de chamada de ajuda são opcionais.
- `bin/help.deps` - Esse script deve gerar a lista de dependências adaptadas ao sistema operacional. Uma dependência por linha.
- `bin/help.config` - Este script deve imprimir qualquer configuração obrigatória ou opcional que possa estar disponível para o plug-in e a ferramenta. Quaisquer variáveis de ambiente ou outros sinalizadores necessários para instalar ou compilar a ferramenta (para o sistema operacional dos usuários quando possível). A saída pode ser texto de formato livre.
- `bin/help.links` - Esta deve ser uma lista de links relevantes para o plug-in e a ferramenta (mais uma vez, adaptados ao sistema operacional atual, quando possível). Um link por linha. As linhas podem estar no formato `<title>: <link>` ou apenas `<link>`.

Cada um desses scripts deve adaptar sua saída ao sistema operacional atual. Por exemplo, quando no Ubuntu, o script deps pode gerar as dependências como pacotes apt-get que devem ser instalados. O script também deve adaptar sua saída ao valor de `ASDF_INSTALL_VERSION` e `ASDF_INSTALL_TYPE` quando as variáveis forem definidas.  Eles são opcionais e nem sempre serão definidos.

O script de retorno de chamada de ajuda NÃO DEVE gerar nenhuma informação que já esteja coberta na documentação principal do asdf-vm. As informações gerais de uso do asdf não devem estar presentes.

#### bin/list-bin-paths

Liste os executáveis para a versão especificada da ferramenta. Deve imprimir uma string com uma lista separada por espaços de caminhos de diretórios que contêm executáveis. Os caminhos devem ser relativos ao caminho de instalação passado. A saída de exemplo seria:

```shell
bin tools veggies
```

Isso instruirá o asdf a criar shims para os arquivos em `<install-path>/bin`, `<install-path>/tools` e `<install-path>/veggies`

Se este script não for especificado, o asdf procurará o diretório `bin` em uma instalação e criará shims para eles.

#### bin/exec-env

Configure o env para executar os binários no pacote.

#### bin/exec-path

Obtenha o caminho executável para a versão especificada da ferramenta. Deve imprimir uma string com o caminho executável relativo. Isso permite que o plug-in substitua condicionalmente o caminho executável especificado do shim, caso contrário, retorne o caminho padrão especificado pelo shim.

```shell
Usage:
  plugin/bin/exec-path <install-path> <command> <executable-path>

Example Call:
  ~/.asdf/plugins/foo/bin/exec-path "~/.asdf/installs/foo/1.0" "foo" "bin/foo"

Output:
  bin/foox
```

#### bin/uninstall

Desinstala uma versão específica de uma ferramenta.

#### bin/list-legacy-filenames

Registre arquivos setter adicionais para este plugin. Deve imprimir uma string com uma lista de nomes de arquivos separados por espaços.

```shell
.ruby-version .rvmrc
```

Nota: Isso só se aplica a usuários que habilitaram a opção `legacy_version_file` em seu `~/.asdfrc`.

#### bin/parse-legacy-file

Isso pode ser usado para analisar ainda mais o arquivo legado encontrado pelo asdf. Se o `parse-legacy-file` não for implementado, o asdf simplesmente irá cat o arquivo para determinar a versão. O script receberá o caminho do arquivo como seu primeiro argumento.

#### bin/post-plugin-add

Isso pode ser usado para executar qualquer ação pós-instalação depois que o plug-in for adicionado ao asdf.

O script tem acesso ao caminho em que o plugin foi instalado (`${ASDF_PLUGIN_PATH}`) e o URL de origem (`${ASDF_PLUGIN_SOURCE_URL}`), se algum foi usado.

Veja também os ganchos relacionados:

- `pre_asdf_plugin_add`
- `pre_asdf_plugin_add_${plugin_name}`
- `post_asdf_plugin_add`
- `post_asdf_plugin_add_${plugin_name}`

#### bin/pre-plugin-remove

Isso pode ser usado para executar qualquer ação de pré-remoção antes que o plug-in seja removido do asdf.

O script tem acesso ao caminho em que o plugin foi instalado (`${ASDF_PLUGIN_PATH}`).

Veja também os ganchos relacionados:

- `pre_asdf_plugin_remove`
- `pre_asdf_plugin_remove_${plugin_name}`
- `post_asdf_plugin_remove`
- `post_asdf_plugin_remove_${plugin_name}`

## Comandos de extensão para asdf CLI.


É possível que plugins definam novos comandos asdf fornecendo scripts ou executáveis `lib/commands/command*.bash` que será chamado usando a interface de linha de comando asdf usando o nome do plug-in como um subcomando.

Por exemplo, suponha que um plugin `foo` tenha:

```shell
foo/
  lib/commands/
    command.bash
    command-bat.bash
    command-bat-man.bash
    command-help.bash
```

Os usuários agora podem executar

```shell
$ asdf foo         # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash`
$ asdf foo bar     # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash bar`
$ asdf foo help    # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-help.bash`
$ asdf foo bat man # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat-man.bash`
$ asdf foo bat baz # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat.bash baz`
```

Os autores de plugins podem usar esse recurso para fornecer utilitários relacionados às suas ferramentas,
ou até mesmo criar plugins que são apenas novas extensões de comando para o próprio asdf.

Quando invocados, se os comandos de extensão não tiverem seus bits executáveis definidos, eles serão
originado como scripts bash, tendo todas as funções de `$ASDF_DIR/lib/utils.bash` disponíveis.
Além disso, o `$ASDF_CMD_FILE` resolve para o caminho completo do arquivo que está sendo originado.
Se o bit executável estiver definido, eles são apenas executados e substituem a execução do asdf.

Um bom exemplo desse recurso é para plugins como [`haxe`](https://github.com/asdf-community/asdf-haxe)
que fornece o `asdf haxe neko-dylibs-link` para corrigir um problema onde os executáveis haxe esperam encontrar
bibliotecas dinâmicas relativas ao diretório executável.

Se o seu plug-in fornecer um comando de extensão asdf, certifique-se de mencioná-lo no README do seu plug-in.

## Modelos de calços personalizados

**POR FAVOR, use este recurso apenas se for absolutamente necessário**

asdf permite modelos de calços personalizados. Para um executável chamado `foo`, se houver um arquivo `shims/foo` no plug-in, o asdf copiará esse arquivo em vez de usar seu modelo padrão de shim.

Isso deve ser usado com sabedoria. Por enquanto AFAIK, está sendo usado apenas no plugin Elixir, porque um executável também é lido como um arquivo Elixir, além de ser apenas um executável. O que torna impossível usar o calço bash padrão.

## Testando plug-ins

 `asdf` contém o comando `plugin-test` para testar seu plugin. Você pode usá-lo da seguinte forma

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]
```

Apenas os dois primeiros argumentos são necessários.
Se \__version_ for especificado, a ferramenta será instalada com essa versão específica. O padrão é o que retorna `asdf latest <plugin-name>`.
Se _git-ref_ for especificado, o plug-in em si é verificado nesse commit/branch/tag, útil para testar um pull-request no CI do seu plug-in. O padrão é o branch _default_ do repositório do plugin.

Os argumentos Rest são considerados o comando a ser executado para garantir que a ferramenta instalada funcione corretamente.
Normalmente seria algo que leva `--version` ou `--help`.
Por exemplo, para testar o plugin NodeJS, podemos executar

```shell
asdf plugin test nodejs https://github.com/asdf-vm/asdf-nodejs.git node --version
```

É altamente recomendável que você teste seu plug-in em um ambiente CI e verifique se ele funciona no Linux e no OSX.

#### Exemplo GitHub Action

O repositório [asdf-vm/actions](https://github.com/asdf-vm/actions) fornece uma ação do GitHub para testar seus plugins hospedados no github.

```yaml
steps:
  - name: asdf_plugin_test
    uses: asdf-vm/actions/plugin-test@v1
    with:
      command: "my_tool --version"
    env:
      GITHUB_API_TOKEN: ${{ secrets.GITHUB_TOKEN }} # automatically provided
```

#### Exemplo de configuração do TravisCI

Aqui está um arquivo `.travis.yml` de amostra, personalize-o de acordo com suas necessidades

```yaml
language: c
script: asdf plugin test nodejs $TRAVIS_BUILD_DIR 'node --version'
before_script:
  - git clone https://github.com/asdf-vm/asdf.git asdf
  - . asdf/asdf.sh
os:
  - linux
  - osx
```

Notas:
Ao usar outro IC, você precisará verificar qual variável mapeia para o caminho do repositório.

Você também tem a opção de passar um caminho relativo para `plugin-test`.

Por exemplo, se o script de teste for executado no diretório: `asdf plugin test nodejs . 'node --version'`.

## Limitação de taxa da API do GitHub

Se o `list-all` do seu plug-in depender do acesso à API do GitHub, certifique-se de fornecer um token de autorização ao acessá-lo, caso contrário, seus testes podem falhar devido à limitação de taxa.

Para fazer isso, crie um [novo token pessoal](https://github.com/settings/tokens/new) com apenas acesso `public_repo`.

Em seguida, nas configurações de compilação do travis.ci, adicione uma variável de ambiente _secure_ para ela chamada algo como `GITHUB_API_TOKEN`.  E _NUNCA_ publique seu token em seu código.

Finalmente, adicione algo como o seguinte para `bin/list-all`

```shell
cmd="curl -s"
if [ -n "$GITHUB_API_TOKEN" ]; then
 cmd="$cmd -H 'Authorization: token $GITHUB_API_TOKEN'"
fi

cmd="$cmd $releases_path"
```

## Enviando plugins para o repositório oficial de plugins

`asdf` pode facilmente instalar plugins especificando o url do repositório de plugins, por exemplo. `plugin add my-plugin https://github.com/user/asdf-my-plugin.git`.

Para facilitar para seus usuários, você pode adicionar seu plugin ao repositório oficial de plugins para ter seu plugin listado e facilmente instalável usando um comando mais curto, por exemplo `asdf plugin add my-plugin`.

Siga as instruções no repositório de plugins: [asdf-vm/asdf-plugins](https://github.com/asdf-vm/asdf-plugins).

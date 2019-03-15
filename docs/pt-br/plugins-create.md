## O que há em um Plugin

Um plugin é um repositório git, com alguns scripts executáveis, para suportar o versionamento de outra linguagem ou ferramenta. Estes scripts são executados quando os comandos `list-all`, `install` ou `uninstall` são executados. Você pode definir ou redefinir variáveis de ambiente e fazer qualquer coisa necessária para configurar o ambiente para a ferramenta.

## Scripts Obrigatórios

- `bin/list-all` - lista todas as versões instaláveis
- `bin/install` - instala a versão especificada

Todos os scripts, exceto `bin/list-all`, terão acesso às seguintes variáveis de ambiente para atuar sobre:

- `ASDF_INSTALL_TYPE` - `version` ou `ref`
- `ASDF_INSTALL_VERSION` - se `ASDF_INSTALL_TYPE` for `version`, então este será o número da versão. Caso contrário, será a git ref passada. Pode apontar para uma tag, commit ou branch no repositório.
- `ASDF_INSTALL_PATH` - o diretório onde a ferramenta _foi_ instalada (ou _deve ser_ instalada, no caso do script `bin/install`)

O script `bin/install` também terá acesso a estas variáveis de ambiente adicionais:

- `ASDF_CONCURRENCY` - o número de núcleos a serem usados quando compilar o cõdigo fonte. Útil para definir `make-j`.

#### bin/list-all

Deve imprimir uma string com uma lista de versões separadas por espaços. Um exemplo de saída seria o seguinte:

```
1.0.1 1.0.2 1.3.0 1.4
```

Note que a versão mais recente deve ser listada por último, para que pareça mais próxima do prompt do usuário. Isso é útil porque o comando `list-all` imprime cada versão em sua própria linha. Se houver muitas versões, é possível que as primeiras versões estejam fora da tela.

Se versões estão sendo extraídas da página de releases de um site, recomenda-se não classificar as versões, se possível. Muitas vezes as versões já estão na ordem correta ou, em ordem inversa, caso em que algo como `tac` deve ser suficiente. Se você deve ordenar versões manualmente, você não pode confiar em `sort -V`, uma vez que não é suportado no OSX. Uma função de classificação alternativa [como esta é uma opção melhor](https://github.com/vic/asdf-idris/blob/master/bin/list-all#L6).

#### bin/install

Este script deve instalar a versão, no caminho definido em `ASDF_INSTALL_PATH`.

O script de instalação deve encerrar com status `0` quando a instalação for executada com sucesso. Caso a instalação falhe, o script deve encerrar com qualquer status diferente de zero.

Se possível, o script somente deve colocar arquivos no diretório `ASDF_INSTALL_PATH` quando o build e a instalação da ferramenta forem consideradas bem-sucedidas pelo script de instalação. O asdf [verifica a existência](https://github.com/asdf-vm/asdf/blob/242d132afbf710fe3c7ec23c68cec7bdd2c78ab5/lib/utils.sh#L44) do diretório `ASDF_INSTALL_PATH` para determinar se essa versão da ferramenta está instalada. Se o diretório `ASDF_INSTALL_PATH` for preenchido no início do processo de instalação, outros comandos asdf executados em outros terminais durante a instalação podem considerar essa versão da ferramenta instalada, mesmo quando não estiver totalmente instalada.

## Scripts Opcionais

#### bin/list-bin-paths

Lista os executáveis para a versão especificada da ferramenta. Deve imprimir uma string com uma lista separada por espaços dos caminhos dos diretórios que contém executáveis. Os caminhos devem ser relativos ao caminho de instalação passado. Um exemplo de saída seria:

```
bin tools veggies
```

Isso irá instruir o asdf a criar shims para os arquivos em `<install-path>/bin`, `<install-path>/tools` e `<install-path>/veggies`

Se este script não for especificado, o asdf procurará o diretório `bin` em uma instalação e criará shims para eles.

#### bin/exec-env

Configura o ambiente para executar os binários no pacote

#### bin/exec-path

Obtem o caminho do executável para a versão especificada da ferramenta. Deve imprimir uma string com o caminho relativo do executável. Isso permite que o plugin substitua condicionalmente o caminho do executável especificado do shim, caso contrário, retorne o caminho padrão especificado pelo shim.

```
Uso:
  plugin/bin/exec-path <install-path> <command> <executable-path>

Exemplo de chamada:
  ~/.asdf/plugins/foo/bin/exec-path "~/.asdf/installs/foo/1.0" "foo" "bin/foo"

Saída:
  bin/foox
```

#### bin/uninstall

Desinstala uma versão específica de uma ferramenta.

#### bin/list-legacy-filenames

Registra arquivos de configuração adicionais para este plugin. Deve imprimir uma string com a uma lista de nomes de arquivos separados por vírgula.

```
.ruby-version .rvmrc
```

Nota: Isso será aplicado somente para usuários que ativaram a opção `legacy_version_file` em seu`~/.asdfrc`.

#### bin/parse-legacy-file

Isso pode ser usado para analisar mais detalhadamente o arquivo legado encontrado pelo asdf. Se o `parse-legacy-file` não estiver implementado, o asdf simplesmente analisará o arquivo para determinar a versão. O caminho do arquivo será passado como primeiro argumento para o script.

## Modelos de shim personalizados

**POR FAVOR, use este recurso somente se for absolutamente necessário**

O asdf permite modelos de shim personalizados. Para um executável chamado `foo`, se houver um arquivo`shims/foo` no plugin, o asdf copiará esse arquivo em vez de usar o modelo de shim padrão.

Isso deve ser usado com sabedoria. Por enquanto, até onde se sabe, só está sendo usado no plugin Elixir, porque um executável também é lido como um arquivo Elixir, além de ser apenas um executável. O que torna impossível usar o shim bash padrão.

**Importante: Metadados do Shim**

Se você criar um shim personalizado, não se esqueça de incluir um comentário como o seguinte (substituindo o nome do seu plugin):

```
# asdf-plugin: plugin_name
```

O asdf usa este metadado `asdf-plugin` para remover shims não-utilizados durante a desinstalação.

## Testando Plugins

O `asdf` possui o comando `plugin-test` para testar seu plugin. Você pode usá-lo da seguinte maneira:

```sh
asdf plugin-test <plugin-name> <plugin-url> [test-command] [--asdf-tool-version version]
```

Os dois primeiros argumentos são obrigatórios. Os próximos dois são opcionais. O terceiro é um comando que também pode ser passado para checar se está rodando corretamente. Por exemplo, para testar o plugin NodeJS, poderíamos executar

```sh
asdf plugin-test nodejs https://github.com/asdf-vm/asdf-nodejs.git 'node --version'
```

O quarto argumento é uma versão de ferramenta que pode ser especificada se você quiser que o teste instale uma versão específica da ferramenta. Isto pode ser útil se nem todas as versões forem compatíveis com todos os sistemas operacionais em que você está testando. Caso você não especifique uma versão, a última versão da saída do comando `list-all` será utilizada.

Nós recomendamos fortemente que você teste seu plugin no TravisCI, para se certificar de que funciona no Linux e OSX.

Aqui está um arquivo `.travis.yml` de exemplo, personalize-o conforme suas necessidades

```yaml
language: c
script: asdf plugin-test nodejs $TRAVIS_BUILD_DIR 'node --version'
before_script:
  - git clone https://github.com/asdf-vm/asdf.git asdf
  - . asdf/asdf.sh
os:
  - linux
  - osx
```

Nota:
Quando estiver utilizando outro CI, você terá que verificar qual variável mapeia o caminho do repositório.

Você também tem a opção de passar um caminho relativo para `plugin-test`.

Por exemplo, se o script de teste é executado no diretório do repositório: `asdf plugin-test nodejs . 'node --version'`.

## Rate Limiting da GitHub API

Se o `list-all` do seu plugin precisa acessar a API do GitHub, certifique-se de fornecer um Token de Autorização ao acessá-la, caso contrário seus testes podem falhar devido ao rate limiting.

Para isso, crie um [novo token pessoal](https://github.com/settings/tokens/new) com acesso apenas a `public_repo`.

Então nas suas configurações de build do TravisCI adicione uma variável de ambiente _segura_ para o token, chamando-a de algo como `GITHUB_API_TOKEN`. E _NUNCA_ publique seu token em seu código.

Por fim, adicione algo como o seguinte no `bin/list-all`

```shell
cmd="curl -s"
if [ -n "$GITHUB_API_TOKEN" ]; then
 cmd="$cmd -H 'Authorization: token $GITHUB_API_TOKEN'"
fi

cmd="$cmd $releases_path"
```

## Enviando plugins para o repositório oficial de plugins

O `asdf` pode instalar plugins facilmente especificando a url do repositório, por exemplo: `plugin-add my-plugin https://github.com/user/asdf-my-plugin.git`.

Para tornar isso mais fácil aos seus usuários, você pode adicionar seu plugin ao repositório oficial de plugins e, assim, ter seu plugin listado e facilmente instalável usando um comando mais curto, por exemplo: `asdf plugin-add my-plugin`.

Siga as instruções no repositório de plugins: [asdf-vm/asdf-plugins](https://github.com/asdf-vm/asdf-plugins).
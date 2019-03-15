## Instalar uma Versão

```shell
asdf install <nome> <versao>
# asdf install erlang 17.3
```

_Se um plugin suporta o download e compilação do código-fonte, você pode especificar `ref:foo` onde `foo` é um branch, tag ou commit específicos. Você também vai precisar usar o mesmo nome e referência quando desinstalar._

## Listar Versões instaladas

```shell
asdf list <nome>
# asdf list erlang
```

## Listar todas as Versões disponíveis

```shell
asdf list-all <nome>
# asdf list-all erlang
```

## Definir Versão atual

```shell
asdf global <nome> <versao>
adfg local <nome> <versao>
# asdf global elixir 1.2.4
```

`global` escreve a versão definida em `$HOME/.tool-versions`.
`local` escreve a versão definida em `$PWD/.tool-versions`, criando este arquivo caso seja necessário.

Veja o arquivo `.tool-version` [na seção Configuração](pt-br/core-configuration) para mais detalhes.

?> Como alternativa, se você deseja definir uma versão apenas para a sessão atual do shell ou para executar apenas um comando sob uma versão de ferramenta específica, você pode definir uma variável de ambiente como `ASDF_${TOOL}_VERSION`.

O exemplo a seguir roda testes em um projeto Elixir com a versão `1.4.0`.
O formato da versão é o mesmo suportado pelo arquivo `.tool-versions`.

```shell
ASDF_ELIXIR_VERSION=1.4.0 mix test
```

## Visualizar Versão atual

```shell
asdf current
# asdf current
# erlang 17.3 (set by /Users/kim/.tool-versions)
# nodejs 6.11.5 (set by /Users/kim/cool-node-project/.tool-versions)

asdf current <nome>
# asdf current erlang
# 17.3 (set by /Users/kim/.tool-versions)
```

## Desinstalar uma Versão

```shell
asdf uninstall <nome> <versao>
# asdf uninstall erlang 17.3
```

## Shims

Quando o asdf-vm instala um pacote, ele cria shims para cada programa executável naquele pacote em um diretório `$ASDF_DATA_DIR/shims` (padrão `~/.asdf/shims`).  Este diretório que está no `$PATH` (por meio de `asdf.sh` ou `asdf.fish`) é como os programas instalados são disponibilizados no ambiente.

Os shims em si são simples wrappers que `executam` um programa auxiliar `asdf-exec` passando o nome do plugin e o caminho para o executável no pacote instalado que o shim está envolvendo.

O helper `asdf-exec` determina a versão daquele pacote a ser usada (como especificado no arquivo `.tool-versions`, selecionado por `asdf local ...` ou `asdf global ...`) o caminho final para o executável no diretório de instalação do pacote (isso pode ser manipulado pelo callback `exec-path` no plugin) e o ambiente para executar (também fornecido pelo plugin - script `exec-env`), e finalmente o executa.

!> Note que, como esse sistema usa chamadas `exec`, quaisquer scripts no pacote que devam ser originados pelo shell em vez de executados, precisam ser acessados diretamente, ao invés do wrapper do shim. Os dois comandos do asdfm-vm: `which` e `where` podem ajudar com isso retornando o caminho para o pacote instalado:

```shell
# retorna o caminho para o executável principal da versão atual
source $(asdf which ${PLUGIN})/../script.sh

# retorna o caminho para o diretório de instalação do pacote
source $(asdf where ${PLUGIN} $(asdf current ${PLUGIN}))/bin/script.sh
```
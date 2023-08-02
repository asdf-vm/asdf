# Versões

> Hi, we've recently migrated our docs and added some new pages. If you would like to help translate this page, see the "Edit this page" link at the bottom of the page.

## Instalar Versão

```shell
asdf install <name> <version>
# asdf install erlang 17.3
```

Se um plugin suporta o download e compilação do código-fonte, você pode especificar `ref:foo` no qual `foo` é uma 'branch' especifica, 'tag', ou 'commit'. Você também precisará usar o mesmo nome e referência ao desinstalar.

## Instalar última versão estável

```shell
asdf install <name> latest
# asdf install erlang latest
```

Instale a última versão estável que inicia com um texto.

```shell
asdf install <name> latest:<version>
# asdf install erlang latest:17
```

## Listar versões instaladas

```shell
asdf list <name>
# asdf list erlang
```

Limite as versões que inicie com um determinado texto.

```shell
asdf list <name> <version>
# asdf list erlang 17
```

## Listar todas as versões disponíveis

```shell
asdf list all <name>
# asdf list all erlang
```

Limite as versões que inicie com um determinado texto.

```shell
asdf list all <name> <version>
# asdf list all erlang 17
```

## Mostrar última versão estável

```shell
asdf latest <name>
# asdf latest erlang
```

Mostrar última versão estável que inicie com um determinado texto.

```shell
asdf latest <name> <version>
# asdf latest erlang 17
```

## Selecionar versão atual

```shell
asdf global <name> <version> [<version>...]
asdf shell <name> <version> [<version>...]
asdf local <name> <version> [<version>...]
# asdf global elixir 1.2.4

asdf global <name> latest[:<version>]
asdf local <name> latest[:<version>]
# asdf global elixir latest
```

`global` escreve a versão para `$HOME/.tool-versions`.

`shell` selecione a versão na variável de ambiente `ASDF_${LANG}_VERSION`, para a atual seção do _shell_.

`local` escreve a versão para `$PWD/.tool-versions`, crie se necessário .

Veja em `.tool-versions` [arquivo de seleção de configuração](/pt-br/manage/configuration) para mais detalhes.

::: warning Alternativa
Se você quiser selecionar a versão atual do seu _shell_ ou para executar um comando em uma versão específica de sua ferramenta, você pode selecionar a versão na variável de ambiente `ASDF_${TOOL}_VERSION`.
:::

O seguinte exemplo executa os testes em um projeto Elixir na versão `1.4.0`.
O formato da versão é o mesmo suportado pelo arquivo `.tool-versions`.

```shell
ASDF_ELIXIR_VERSION=1.4.0 mix test
```

## Resposta do sistema de versão

Para usar o sistema de versão da ferramenta `<name>` inicie um gerenciador de versões do asdf para selecionar a versão na ferramenta do `system`.

Selecione o sistema com `global`, `local` ou `shell`
Set system with either `global`, `local` or `shell` conforme descrito em [Selecionar versão atual](#selecionar-versão-atual).

```shell
asdf local <name> system
# asdf local python system
```

## Verificar a versão atual

```shell
asdf current
# asdf current
# erlang 17.3 (set by /Users/kim/.tool-versions)
# nodejs 6.11.5 (set by /Users/kim/cool-node-project/.tool-versions)

asdf current <name>
# asdf current erlang
# 17.3 (set by /Users/kim/.tool-versions)
```

## Desinstalar versão

```shell
asdf uninstall <name> <version>
# asdf uninstall erlang 17.3
```

## Shims

Quando asdf instala um pacote é criado _shims_ para cada programa executado no pacote do diretório `$ASDF_DATA_DIR/shims` (padrão `~/.asdf/shims`). Esse diretório começa no `$PATH` (pelos `asdf.sh`, `asdf.fish`, etc) é como o programa instalado é disponibilizado no ambiente do sistema.

Os _shims_ em si são atalhos simples que executam um programa auxiliar `asdf exec` passando o nome do plugin e o caminho para o executável no pacote instalado que o _shim_ está contido.

O `asdf exec` ajuda a determinar a versão do pacote usado (como especificado no arquivo `.tool-versions`, pelo `asdf local ...` ou `asdf global ...`), o final do _path_ do executavél no pacote instalado no diretório (pode ser manipulado pelo `exec-path` no _callback_ do plugin) e o ambiente executado em (também fornecido pelo plugin - `exec-env`) e finalmente executado.

::: warning Observação
Observe que, como este sistema usa chamadas `exec`, qualquer _scripts_ no pacote devem ser fornecidos pelo _shell_, a instancia em execução precisa ser aessado diretamente ao invés do _shim_. Os dois comandos do asdf: `which` e `where` pode ajudar com o retorno do caminho para o pacote instalado:
:::

```shell
# retorna o 'path' da versão atual em execução
source $(asdf which ${PLUGIN})/../script.sh

# retorna o 'path' do pacote instalado no diretório
source $(asdf where ${PLUGIN} $(asdf current ${PLUGIN}))/bin/script.sh
```

### Ignorando _shims_ do asdf

Se por algum motivo você deseja ignorar _shims_ do asdf ou deseja que suas variáveis de ambiente sejam definidas automaticamente ao entrar no diretório do seu projeto, pode ser útil o [asdf-direnv](https://github.com/asdf-community/asdf-direnv). Verifique o README para mais detalhes.

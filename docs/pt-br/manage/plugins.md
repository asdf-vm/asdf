# Plugins

> Hi, we've recently migrated our docs and added some new pages. If you would like to help translate this page, see the "Edit this page" link at the bottom of the page.

Plugins são como `asdf` sabe lidar com diferentes ferramentas, tais quais Node.js, Ruby, Elixir etc.

Veja [Criando Plugins](/pt-br/plugins/create.md) para a API do plugin usada para suportar mais ferramentas.

## Adicionar

Adicione os plugins via sua Url Git:

```shell
asdf plugin add <name> <git-url>
# asdf plugin add elm https://github.com/vic/asdf-elm
```

ou pelo nome abreviado dentro do repositório de plugins:

```shell
asdf plugin add <name>
# asdf plugin add erlang
```

::: tip Recommendation
Prefira o método mais longo `git-url`, pois ele é independente do repositório de nome abreviado.
:::

## Listar Instalados

```shell
asdf plugin list
# asdf plugin list
# java
# nodejs
```

```shell
asdf plugin list --urls
# asdf plugin list
# java            https://github.com/halcyon/asdf-java.git
# nodejs          https://github.com/asdf-vm/asdf-nodejs.git
```

## Listar todos nomes abreviados no repositório

```shell
asdf plugin list all
```

Veja [Plugins Shortname Index](https://github.com/asdf-vm/asdf-plugin-template) para toda a lista de nomes curtos de plugins.

## Atualizar

```shell
asdf plugin update --all
```

Se você quiser atualizar um pacote específico, apenas use.

```shell
asdf plugin update <name>
# asdf plugin update erlang
```

Esta atualização irá buscar o último _commit_ na _branch_ padrão no _origin_ de seu respositório. Plugins e atualizações das versões estão sendo desenvolvidas ([#916](https://github.com/asdf-vm/asdf/pull/916))

## Remover

```bash
asdf plugin remove <name>
# asdf plugin remove erlang
```

Removendo o plugin irá remover todas as instalações feitas com o plugin. Isso pode ser usado como um atalho para apagar/remover sujeiras de versões não utilizadas de uma ferramenta.

## Sincronizar nome abreviado no repositório

O nome abreviado do repositório é sincronizado em seu máquina local e periodicamente atualizado. Esse período pode ser determinado com o seguinte método:

- comandos `asdf plugin add <name>` ou `asdf plugin list all` disparam a sincronização
- ocorre uma sincronização se não houver nenhuma nos últimos `X` minutos
- `X` por padrão é `60`, mas pode ser mudado em `.asdfrc` via as opções do `plugin_repository_last_check_duration`. Seja mais em [asdf documentação de configuração](/pt-br/manage/configuration.md).

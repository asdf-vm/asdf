Plugins são a forma do asdf-vm entender como lidar com diferentes pacotes.

Veja em [Todos os Plugins](plugins-all) o repositório de plugins, que lista todos os plugins conhecidos para o asdf-vm.

Veja [Criando Plugins](plugins-create) para conhecer a API super simples para suportar mais linguagens.

## Adicionar

```shell
asdf plugin-add <nome>
# asdf plugin-add erlang
```

Se o plugin que você quer instalar não faz parte do repositório de plugins, você pode adicioná-lo usando a URL do seu repositório:

```shell
asdf plugin-add <nome> <git-url>
# asdf plugin-add elm https://github.com/vic/asdf-elm
```

## Listar instalados

```shell
asdf plugin-list
# asdf plugin-list
# java
# nodejs
```

```shell
asdf plugin-list --urls
# asdf plugin-list
# java            https://github.com/skotchpine/asdf-java.git
# nodejs          https://github.com/asdf-vm/asdf-nodejs.git
```

## Atualizar

```shell
asdf plugin-update --all
```

Se você quiser atualizar um pacote específico, basta especificá-lo:

```shell
asdf plugin-update <nome>
# asdf plugin-update erlang
```

## Remover

```bash
asdf plugin-remove <nome>
# asdf plugin-remove erlang
```
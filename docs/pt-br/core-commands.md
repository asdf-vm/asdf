## Gerenciar Plugins

| Comando                              | Efeito                                                       |
| ------------------------------------ | ------------------------------------------------------------ |
| `asdf plugin-add <nome> [<git-url>]` | Adiciona um plugin a partir de seu repositório OU adiciona um repositório Git como plugin, especificando seu nome e sua URL                                                   |
| `asdf plugin-list`                   | Lista os plugins instalados                                  |
| `asdf plugin-list --urls`            | Lista os plugins instalados e as URLs de seus repositórios   |
| `asdf plugin-list-all`               | Lista os plugins registrados no repositório asdf-plguins com as URLs |
| `asdf plugin-remove <nome>`          | Remove um plugin e suas versões de pacote                    |
| `asdf plugin-update <nome>`          | Atualiza um plugin                                           |
| `asdf plugin-update --all`           | Atualiza todos os plugins                                    |

## Gerenciar Pacotes

| Comando                           | Efeito                                                                |
| --------------------------------- | --------------------------------------------------------------------- |
| `asdf install [<nome> <versão>]`  | Instala uma versão específica de um pacote, ou sem nenhum argumento, instala todas as versões do pacote listadas no arquivo .tool-versions |
| `asdf uninstall <nome> <versão>`  | Remove uma versão específica de um pacote                             |
| `asdf current`                    | Exibe a versão definida atualmente ou sendo usada para todos os pacotes |
| `asdf current <nome>`             | Exibe a versão definida atualmente ou sendo usada pelo pacote         |
| `asdf where <nome> [<versão>]`    | Exibe o caminho de instalação para a versão atual ou outra versão instalada |
| `asdf which <nome>`               | Exibe o caminho de instalação para a versão atual                     |
| `asdf local <nome> <versão>`      | Define a versão do pacote localmente                                  |
| `asdf global <nome> <versão>`     | Define a versão do pacote globalmente                                 |
| `asdf list <nome>`                | Lista as versões instaladas de um pacote                              |
| `asdf list-all <nome>`            | Lista todas as versões de um pacote                                   |

## Utilidades

| Comando                        | Efeito                                         |
| ------------------------------ | ---------------------------------------------- |
| `asdf reshim <nome> <versão>`  | Recria os shims para uma versão de um pacote   |
| `asdf update`                  | Atualiza o asdf para a última versão estável   |
| `asdf update --head`           | Atualiza o asdf para a última versão da branch master |
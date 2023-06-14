# Configuration

> Hi, we've recently migrated our docs and added some new pages. If you would like to help translate this page, see the "Edit this page" link at the bottom of the page.

A configuração do `asdf` abrange tanto os arquivos `.tool-versions` compartilháveis quanto as personalizações específicas do usuário com `.asdfrc` e variáveis de ambiente.

## .tool-versions

Sempre que o arquivo `.tool-versions` estiver presente em um diretório, as versões da ferramenta que ele declara serão usadas nesse diretório e em seus subdiretórios.

Configurações globais podem ser modificadas no arquivo `$HOME/.tool-versions`

O arquivo `.tool-versions` se parece assim:

```
ruby 2.5.3
nodejs 10.15.0
```

As versões podem estar no seguinte formato:

- `10.15.0` - uma versão real. Os plugins que suportam o download de binários farão o download de binários.
- `ref:v1.0.2-a` ou `ref:39cb398vb39` - _tag/commit/branch_ para download pelo github e compilação
  um path costumizado e compi
- `path:~/src/elixir` - um path para uma versão compilada e personalizada de uma ferramenta pronta para usar. Para uso por linguagens de desenvolvimento e outros.
- `system` - faz com que asdf passe para a versão da ferramenta no sistema que não é gerenciada por asdf .

Várias versões podem ser definidas, separando-as com um espaço. Por exemplo, para usar Python 3.7.2, e também Python 2.7.15, use a linha abaixo em seu arquivo `.tool-versions`.

```
python 3.7.2 2.7.15 system
```

Para instalar todas as ferramentas definidas em `.tool-versions`, execute o camando `asdf install` sem argumentos no mesmo diretório de `.tool-versions`.

Para isntalar somente uma ferramenta definida em `.tool-versions`, execute o camando `asdf install` sem argumentos no mesmo diretório de `.tool-versions`. A ferramenta será instalada na versão especificada no arquivo `.tool-versions`.

Edite o arquivo diretamente no diretório ou use `asdf local` (ou `asdf global`) para atualiza-lo.

## `$HOME/.asdfrc`

Adicione um arquivo `.asdfrc` ao seu diretório home e asdf usará as configurações especificadas no arquivo. O arquivo deve ser formatado assim:

```
legacy_version_file = yes
```

**Configurações**

- `legacy_version_file` - por padrão é `no`. Se definido como `yes`, fará com que os plug-ins que suportam esse recurso leiam os arquivos de versão usados por outros gerenciadores de versão (por exemplo, `.ruby-version` no caso do `rbenv` do Ruby).
- `use_release_candidates` - por padrão é `no`. Se definido como `yes`, fará com que o comando `asdf update` atualize para o mais recente em vez da versão semântica mais recente.

- `always_keep_download` - por padrão é `no`. Se definido como `yes`, fará com que o `asdf install` sempre mantenha o código-fonte ou binário baixado. Se definido como `no`, o código fonte ou binário baixado por `asdf install` será excluído após a instalação bem sucedida.

- `plugin_repository_last_check_duration` - por padrão é `60` min (1 hrs). Ele define a duração da última verificação do repositório de plugins asdf. Quando o comando `asdf plugin add <nome>`, `asdf plugin list all` for executado, ele verificará a duração da última atualização para atualizar o repositório. Se definido como `0`, ele atualizará o repositório de plugins asdf todas as vezes.

## Variáveis de ambiente

- `ASDF_CONFIG_FILE` - O padrão é `~ /.asdfrc` conforme descrito acima. Pode ser definido para qualquer local.
- `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME` - O nome do arquivo que armazena os nomes e versões das ferramentas. O padrão é `.tool-versions`. Pode ser qualquer nome de arquivo válido. Normalmente você não deve substituir o valor padrão, a menos que deseja que o asdf ignore os arquivos `.tool-versions`.
- `ASDF_DIR` - O padrão é `~/.asdf` - Localização dos arquivos `asdf`. Se você instalar `asdf` em algum outro diretório, defina-o para esse diretório. Por exemplo, se você estiver instalando através do AUR, você deve definir isso para `/opt/asdf-vm`.
- `ASDF_DATA_DIR` - O padrão é `~/.asdf` - Local onde `asdf` instala plugins, correções e instalações. Pode ser definido para qualquer local antes de fornecer `asdf.sh` ou `asdf.fish` mencionado na seção acima. Para Elvish, isso pode ser definido acima de `use asdf`.

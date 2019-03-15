## .tool-versions

Sempre que o arquivo `.tool-versions` está presente em um diretório, as versões de ferramenta declaradas por ele serão usadas naquele diretório e em quaisquer subdiretórios.

?> Padrões globais podem ser definidos no arquivo `$HOME/.tool-versions`

Um arquivo `.tool-versions` se parece com isso:

```
ruby 2.5.3
nodejs 10.15.0
```

As versões podem estar nos seguintes formatos:

- `10.15.0` - uma versão específica. Plugins que suportam o download de binários, terão os binários baixados.
- `ref:v1.0.2-a` ou `ref:39cb398vb39`- tag/commit/branch para efetuar o download do github e compilar
- `path:/src/elixir`- um caminho para uma versão compilada personalizada de uma ferramenta a ser utilizada. Para uso de desenvolvedores de linguagem e afins.
- `system` - essa palavra-chave faz com que o asdf passe para a versão da ferramenta no sistema, que não é gerenciada pelo asdf.

Para instalar todas as ferramentas definidas em um arquivo `.tool-versions`, execute `asdf install` sem nenhum outro argumento no diretório que contém o arquivo `.tool-versions`.

Edite o arquivo diretamente ou utilize `asdf local` (ou `asdf global`) para atualizá-lo.

## \$HOME/.asdfrc

Adicione um arquivo `.asdfrc` no diretório raíz do seu usuário e o asdf utilizará as configurações especificadas nesse arquivo. O arquivo deve ser formatado da seguinte maneira:

```
legacy_version_file = yes
```

**Configurações**

- `legacy_version_file` - o padrão é `no`. Se configurado como yes, fará com que os plugins que suportam esse recurso leiam os arquivos de versão usados por outros gerenciadores de versão (por exemplo, `.ruby-version` no cado do `rbenv` do Ruby).

## Variáveis de Ambiente

- `ASDF_CONFIG_FILE` - O padrão é` ~ / .asdfrc` conforme descrito acima. Pode ser definido para qualquer local.
- `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME` - O nome do arquivo que armazena os nomes e as versões das ferramentas. O padrão é `.tool-versions`. Pode ser qualquer nome de arquivo válido.
- `ASDF_DATA_DIR` - O padrão é` ~ / .asdf` - Local onde o `asdf` instala plugins, correções e instalações. Pode ser definido para qualquer local antes de procurar `asdf.sh` ou` asdf.fish` mencionado na seção acima.
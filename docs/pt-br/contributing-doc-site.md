## Melhorias

Aqui está uma lista de melhorias que estamos tentando fazer na documentação. Se você deseja contribuir, de uma olhadinha nisso:

- customise the docsify theme
- cover-page background image
- cover-page/readme gif of a terminal using asdf showing it's features (automatic version switching, .tool-versions with multiple runtime configs)
- custom doc site domain
- change the typography
- get a logo?
- improve "edit on GitHub" button/link
- add asdf to awesome-docsify showcase

## Configure seu ambiente

Estamos usando:

- [Node.js](https://github.com/asdf-vm/asdf-nodejs) `v10.15.0` para dar suporte as outras ferramentas necessárias
- [docsify](https://docsify.js.org/#/) para criar a documentação
- [prettier](https://prettier.io/) para formatar arquivos de _markdown_ (.md)

### Instalar dependências

Estamos tentando **evitar poluir** o repositório central com ferramentas para esta documentação. Sendo assim, seria ótimo se você pudesse instalar essas ferramentas de desenvolvimento **globalmente** para não comprometê-las com este projeto.

```shell
npm i docsify-cli prettier -g
```

## Subir servidor

Execute na raiz do projeto:

```shell
docsify serve docs
```

## Formatar arquivos

Execute na raiz do projeto:

```shell
prettier --write "docs/**/*.md"
```

## Traduções

Seria ótimo fornecer traduções para outros idiomas.

O Docsify torna a adição de novos idiomas bastante fácil. Veja em `docs/index.html` para exemplos de `zh-cn`.

### Adicionar uma nova tradução

 
1. Crie uma pasta dentro do `docs/` para adicionar sua nova tradução
   ```
   docs/
   docs/zh-cn/
   ```
2. copie o arquivo `docs/_404.md` para sua nova pasta `docs/zh-cn/_404.md`
   ```
   docs/_404.md
   docs/zh-cn/_404.md
   ```
3. troque o texto com a sua tradução.
4. repita o processo para todos os arquivos.
5. adicione o _link_ da sua tradução em `_navbar.md`.
6. execute o `prettier` antes de fazer o _commit_ das alterações.

Para mais informações veja em [configurações do docsify](https://docsify.js.org/#/configuration), para [barra lateral (navbar)](https://docsify.js.org/#/custom-navbar), verifique o `index.html` e [campo de pesquisa](https://github.com/docsifyjs/docsify/blob/6ac7bace213145cb655e9a5e9e209384db08e5f9/docs/index.html#L48).
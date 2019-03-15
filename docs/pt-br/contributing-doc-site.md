## Melhorias

Aqui está uma lista de melhorias que pretendemos realizar na documentação. Se você quiser contribuir, tente algo daqui:

- Customizar o tema do docsify
- Imagem de fundo para a cover-page
- Adicionar gif de um terminal usando o asdf e mostrando suas funcionalidades na cover-page/readme
- Domínio personalizado para o site de documentação
- Mudar a tipografia
- Conseguir um logotipo?
- Melhorar o botão/link "editar no GitHub"
- Adicionar o asdf-vm no showcase do awesome-docsify

## Configure seu ambiente

Nós estamos usando:

- [Node.js](https://github.com/asdf-vm/asdf-nodejs) `v10.15.0` para suportar as outras ferramentas necessárias
- [docsify](https://docsify.js.org/#/) para criar nosso site de documentação
- [prettier](https://prettier.io/) para formatar nossos arquivos markdown

## Instalar dependências

Nós estamos procurando **evitar poluir** o repositório base com ferramentas para esse site de documentação. Dessa forma, seria ótimo se você pudesse instalar essas ferramentas de desenvolvimento **globalmente**, para que não precisem ser commitadas nesse projeto.

```shell
npm i docsify-cli prettier -g
```

### Servindo o site

A partir da raíz desse repositório, execute:

```shell
docsify server docs
```

## Formate antes de commitar

A partir da raíz desse repositório, execute:

```shell
prettier --write "docs/**/*.md"
```

## Traduções

Seria ótimo fornecer traduções para outros idiomas.

É muito fácil adicionar novos idiomas com o Docsify. Procure em `docs/index.html` por exemplos `zh-cn` comentados.

## Adicionando uma nova Tradução

1. crie uma pasta em `docs/` para a nova tradução
  ```
  docs/
  docs/zh-cn/
  ````
2. copie o arquivo `docs/_404.md` do diretório raíz para a nova pasta `docs/zh-cn/_404.ms`
  ```
  docs/_404.md
  docs/zh-cn/_404.md
  ```
3. substitua o texto pelo texto traduzido.
4. repita para todos os arquivos.
5. adicione um link para a nova tradução em `_navbar.md`.
6. execute `prettier` antes de commitar.

Para mais informações, cheque a documentação do Docsify para [configuração](https://docsify.js.org/#/configuration), [navbar personalizada](https://docsify.js.org/#/custom-navbar), e o próprio arquivo `index.html` deles na [seção de busca](https://github.com/docsifyjs/docsify/blob/6ac7bace213145cb655e9a5e9e209384db08e5f9/docs/index.html#L48).

# Docs & Site

> Hi, we've recently migrated our docs and added some new pages. If you would like to help translate this page, see the "Edit this page" link at the bottom of the page.

Documentação e guia de contribuição do site.

## Configuração inicial

Fork `asdf` no GitHub e/ou Git clone o branch padrão:

```shell
# clone your fork
git clone https://github.com/<GITHUB_USER>/asdf.git
# or clone asdf
git clone https://github.com/asdf-vm/asdf.git
```

As ferramentas para desenvolvimento de sites Docs são gerenciadas com `asdf` em `docs/.tool-versions`. Adicione os plugins com:

```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs
```

Instale a(s) versão(ões) da ferramenta com:

```shell
asdf install
```

- [Node.js](https://nodejs.org): tempo de execução JavaScript criado no mecanismo JavaScript V8 do Chrome.
-
Instale as dependências do Node.js do `docs/package.json`:

```shell
npm install
```

## Desenvolvimento

[Vuepress (v2)](https://v2.vuepress.vuejs.org/) é o Static Site Generator (SSG) que usamos para construir o site de documentação do asdf. Foi escolhido para substituir [Docsify.js](https://docsify.js.org/), pois gostaríamos de oferecer suporte a um substituto somente HTML quando os usuários não tiverem JavaScript disponível ou ativado. Isso não era possível com o Docsify. Fora isso, o conjunto de recursos é basicamente o mesmo, com foco em escrever arquivos Markdown com configuração mínima.

`package.json` contém os scripts necessários para o desenvolvimento:

@[code json{3-5}](../package.json)

 Para iniciar o servidor de desenvolvimento local:

```shell
npm run dev
```

Formate o código antes de confirmar:

```shell
npm run format
```

## Pull Requests, Releases e Commits Convencionais

`asdf` está usando um pipeline de lançamento automatizado que depende de Commits Convencionais em títulos de PR. Documentação detalhada encontrada no [guia de contribuição principal](./core.md).

Ao criar um PR para alterações na documentação, por favor, faça o título do PR com o tipo de Commit Convencional `docs` no formato `docs: <description>`.

## Vuepress

A configuração do site está contida em alguns arquivos JavaScript com objetos JS usados para representar a configuração. Eles estão:

- `docs/.vuepress/config.js`: o arquivo de configuração raiz do site. Leia a [documentação do Vuepress](https://v2.vuepress.vuejs.org/guide/configuration.html#config-file) para obter as especificações.

Para simplificar a configuração raiz, os objetos JS maiores que representam a configuração _navbar_ e _sidebar_ foram extraídos e separados por sua localidade. Veja os dois em:

- `docs/.vuepress/navbar.js`
- `docs/.vuepress/sidebar.js`

Com a documentação oficial para essas configurações vivendo na [Referência de tema padrão](https://v2.vuepress.vuejs.org/reference/default-theme/config.html#locale-config).

## I18n

Vuepress tem suporte de primeira classe para internacionalização. O root config `docs/.vuepress/config.js` define os locais suportados com sua URL, título no menu suspenso de seleção e referências de configurações navbar/sidebar.

As configurações da barra de navegação/barra lateral são capturadas nos arquivos de configuração mencionados acima, separadas por localidade e exportadas individualmente.

O conteúdo de markdown para cada localidade deve estar em uma pasta com o mesmo nome das chaves para `locales` na configuração raiz.  Isso é:

```js
{
  ...
  themeConfig: {
    locales: {
      "/": {
        selectLanguageName: "English (US)",
        sidebar: sidebar.en,
        navbar: navbar.en
      },
      "/pt-BR/": {
        selectLanguageName: "Brazilian Portuguese",
        sidebar: sidebar.pt_br,
        navbar: navbar.pt_br
      }
    }
  }
}
```

`/pt-BR/` exigirá o mesmo conjunto de arquivos markdown localizados em `docs/pt-BR/`, assim:

```shell
docs
├─ README.md
├─ foo.md
├─ nested
│  └─ README.md
└─ pt-BR
   ├─ README.md
   ├─ foo.md
   └─ nested
      └─ README.md
```

A [documentação oficial do Vuepress i18n](https://v2.vuepress.vuejs.org/guide/i18n.html#site-i18n-config) entra em mais detalhes.

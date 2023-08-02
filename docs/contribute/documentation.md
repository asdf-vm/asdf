# Docs & Site

Documentation & site contribution guide.

## Initial Setup

Fork `asdf` on GitHub and/or Git clone the default branch:

```shell
# clone your fork
git clone https://github.com/<GITHUB_USER>/asdf.git
# or clone asdf
git clone https://github.com/asdf-vm/asdf.git
```

The tools for Docs site development are managed with `asdf` in the `docs/.tool-versions`. Add the plugins with:

```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs
```

Install the tool version(s) with:

```shell
asdf install
```

- [Node.js](https://nodejs.org): JavaScript runtime built on Chrome's V8 JavaScript engine.

Install Node.js dependencies from `docs/package.json`:

```shell
npm install
```

## Development

[VitePress (v2)](https://vitepress.dev/) is the Static Site Generator (SSG) we use to build the asdf documentation site. It was chosen to replace [Docsify.js](https://docsify.js.org/) and subsequently VuePress as we would like to support an HTML only fallback when users do not have JavaScript available or enabled. This was not possible with Docsify & VitePress quicly supplanted VuePress. Other than this, the feature-set is largely the same, with the focus on writing Markdown files with minimal configuration.

`package.json` contains the scripts required for development:

@[code json{3-5}](../package.json)

To start the local development server:

```shell
npm run dev
```

Format the code before committing:

```shell
npm run format
```

## Pull Requests, Releases & Conventional Commits

`asdf` is using an automated release pipeline which relies on Conventional Commits in PR titles. Detailed documentation found in the [core contribution guide](./core.md).

When creating a PR for documentation changes please make the PR title with the Conventional Commit type `docs` in the format `docs: <description>`.

## Vitepress

Configuration of the site is contained within a few TypeScript files with JS Objects used to represent the config. They are:

- `docs/.vitepress/config.js`: the root config file for the site. Read the [VitePress documentation](https://vitepress.dev/reference/site-config) for it's spec.

To simplify the root config, the larger JS Objects representing the _navbar_ and _sidebar_ configuration have been extracted and separated by their locale. See both in:

- `docs/.vitepress/navbars.js`
- `docs/.vitepress/sidebars.js`

With the official documentation for these configs living in the [Default Theme Reference](https://vitepress.dev/reference/default-theme-config).

## I18n

VitePress has first-class support for internationalization. The
root config `docs/.vitepress/config.js` defines the supported locales with their URL, title in the selection dropdown menu and navbar/sidebar configs references.

The navbar/sidebar configs are captured in the aforementioned config files, separated by locale and exported individually.

The markdown content for each locale must fall under a folder with the same name as the keys for `locales` in the root config. That is:

```js
// docs/.vitepress/config.js
export default defineConfig({
  ...
  locales: {
    root: {
      label: "English",
        lang: "en-US",
        themeConfig: {
        nav: navbars.en,
          sidebar: sidebars.en,
      },
    },
    "pt-br": {
      label: "Brazilian Portuguese",
        lang: "pr-br",
        themeConfig: {
        nav: navbars.pt_br,
          sidebar: sidebars.pt_br,
      },
    },
    "zh-hans": {
      label: "简体中文",
        lang: "zh-hans",
        themeConfig: {
        nav: navbars.zh_hans,
          sidebar: sidebars.zh_hans,
      },
    },
  },
})
```

`/pt-BR/` will require the same set of markdown files located under `docs/pt-BR/`, like so:

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

The [official VitePress i18n documentation](https://vitepress.dev/guide/i18n) goes into more detail.

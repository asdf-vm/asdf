# ドキュメント & サイト

これは、ドキュメントおよびサイトのコントリビューションガイドです。

## 初期セットアップ

GitHubで`asdf`をフォークするか、デフォルトのブランチをGitクローンしてください:

```shell
# clone your fork
git clone https://github.com/<GITHUB_USER>/asdf.git
# or clone asdf
git clone https://github.com/asdf-vm/asdf.git
```

ドキュメントサイト開発用のツールは、`asdf`によって`docs/.tool-versions`で管理されています。下記のようにプラグインを追加してください:

```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs
```

開発に必要なバージョンを、下記のようにインストールします:

```shell
asdf install
```

- [Node.js](https://nodejs.org): ChromeのV8 JavaScriptエンジンをベースに構築されたJavaScriptランタイムです。

`docs/package.json`をもとに、Node.jsの依存関係をインストールしてください:

```shell
npm install
```

## 開発

[VitePress (v2)](https://vitepress.dev/)は、asdfドキュメントサイトを構築するために使用している静的サイトジェネレータ(SSG)です。類似ツールである[Docsify.js](https://docsify.js.org/)やVuePressに代わってVitePressが採用されたのは、ユーザがJavaScriptを使用できない、または有効にしていない場合に、HTMLのみのフォールバックをサポートしたいからでした。これは、DocsifyとVitePressがVuePressに急速に取って代わっていた場合には不可能でした。これ以外の機能セットはほとんど同じで、最小限の構成でMarkdownファイルを書くことに重点を置いています。

`package.json`には、開発に必要なスクリプトが含まれています:

@[`package.json`のコード](https://github.com/asdf-vm/asdf/blob/master/docs/package.json#L3-L5)

ローカルの開発サーバを起動するには、次のように実行します:

```shell
npm run dev
```

コミットする前にコードをフォーマットするには、次のように実行します:

```shell
npm run format
```

## プルリクエスト、リリース、Conventional Commits

`asdf`は、プルリクエストタイトルのConventional Commitsに依存する自動リリースパイプラインを使用しています。詳しくは、[コアのコントリビューションガイド](./core.md)のドキュメントに記述されています。

ドキュメントの変更に関するプルリクエストを作成する場合、プルリクエストのタイトルは、Conventional Commit typeを`docs`として、`docs: <description>`というフォーマットで作成するようにしてください。

## Vitepress

サイトの構成設定は、構成を示すために使用されるJSオブジェクト含んだ、いくつかのTypeScriptファイルに記述されています。以下のとおりです:

- `docs/.vitepress/config.js`: サイトのルート構成ファイルです。仕様については、[VitePressのドキュメント](https://vitepress.dev/reference/site-config)をご覧ください。

ルート構成ファイルを簡素化するために、 _Navバー_ と _サイドバー_ の構成を示す大きなJSオブジェクトについては、別ファイルに切り出されており、かつ、ロケールごとに分類されています。次の両方のファイルを参照してください:

- `docs/.vitepress/navbars.js`
- `docs/.vitepress/sidebars.js`

これらの構成設定に関する公式ドキュメントは、[Default Theme Reference](https://vitepress.dev/reference/default-theme-config)をご覧ください。

## I18n

VitePressは、国際化対応に関して最高のサポートを備えています。
ルート構成ファイルである`docs/.vitepress/config.js`では、サポートされているロケールとそのURL、ドロップメニューのタイトル、Navバー/サイドバーの構成への参照を定義しています。

Navバー/サイドバーの構成設定は前述の構成ファイルにキャプチャされ、ロケールごとに分類され、個別にエクスポートされます。

各ロケールのMarkdownコンテンツは、ルート構成ファイル内の`locales`内のキーと同じ名前のディレクトリ配下に配置する必要があります。ルート構成が下記の場合:

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

`/pt-BR/`を有効にするには、下記のように、`docs/pt-BR/`配下に同じMarkdownファイルのセットを配置する必要があります:

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

[公式のVitePress i18nドキュメント](https://vitepress.dev/guide/i18n)には、より詳細な説明が記述されています。

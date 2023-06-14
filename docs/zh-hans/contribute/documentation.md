# 文档 & 网站

文档 & 网站贡献指南。

## 初始化设置

在 Github 上 fork `asdf` 并且/或者使用 Git 克隆默认分支：

```shell
# 克隆你 fork 的 asdf
git clone https://github.com/<GITHUB_USER>/asdf.git
# 或者直接克隆 asdf
git clone https://github.com/asdf-vm/asdf.git
```

文档网站开发所需的工具都在文件 `docs/.tool-versions` 中使用 `asdf` 进行管理。使用以下命令添加插件：

```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs
```

使用以下命令安装工具版本：

```shell
asdf install
```

- [Node.js](https://nodejs.org/zh-cn/)：基于 Chrome 的 V8 引擎的 JavaScript 运行环境。

根据 `docs/package.json` 文件安装 Node.js 依赖：

```shell
npm install
```

## 开发

[Vuepress (v2)](https://v2.vuepress.vuejs.org/zh/) 是我们用来构建 asdf 文档网站的静态站点生成器（SSG）。它被选中来取代 [Docsify.js](https://docsify.js.org/#/zh-cn/)，因为我们希望在用户没有可用或未启用 JavaScript 时支持仅依靠 HTML。Docsify 无法做到这一点。除此之外，两者特性集合大致相同，重点是 Vuepress 可以用最少的配置编写 Markdown 文件。

`package.json` 包含了开发所需的脚本：

@[code json{3-5}](../../package.json)

启动本地开发服务器：

```shell
npm run dev
```

在提交之前格式化代码：

```shell
npm run format
```

## 拉取请求、发布以及约定式提交

`asdf` 正在使用依赖 PR 标题中的约定式提交的自动化发布流水线。具体的文档可以查看 [核心贡献指南](./core.md).

当为文档更改创建 PR 请求时，请确保 PR 标题使用了约定式提交类型 `docs` 以及 `docs: <description>` 的格式。

## Vuepress

网站的配置包含在几个 JavaScript 文件中，其中 JS 对象用于表示配置。它们是：

- `docs/.vuepress/config.js`：网站的根配置文件。请查看 [Vuepress 文档](https://v2.vuepress.vuejs.org/zh/guide/configuration.html) 了解更多详情。

为了简化根配置文件，更大的 JS 对象表示 _导航栏和侧边栏_ 配置已经被提取并按照语言类型分隔开来。请参考以下文件：

- `docs/.vuepress/navbar.js`
- `docs/.vuepress/sidebar.js`

这些配置的官方文档位于 [默认主题参考](https://v2.vuepress.vuejs.org/zh/reference/default-theme/config.html)。

## I18n 国际化

Vuepress 有一流的国际化支持。根配置文件 `docs/.vuepress/config.js` 定义了支持的语言类型及其 URL、在选择下拉菜单中的标题以及导航栏/侧边栏配置引用。

导航栏/侧边栏配置在上述配置文件中捕获，按语言类型分隔开并单独导出。

每种语言的 markdown 内容必须位于与根配置文件中 `locale` 键同名的目录位置。也就是：

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

`/pt-BR/` 将要求 markdown 文件的同一集合位于 `docs/pt-BR/` 目录下，如下所示：

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

请查看 [Vuepress i18n 国际化官方文档](https://v2.vuepress.vuejs.org/zh/guide/i18n.html#%E7%AB%99%E7%82%B9%E5%A4%9A%E8%AF%AD%E8%A8%80%E9%85%8D%E7%BD%AE) 了解更多详情。

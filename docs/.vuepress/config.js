const navbar = require("./navbar");
const sidebar = require("./sidebar");

module.exports = {
  base: "/",
  head: [],
  locales: {
    "/": {
      lang: "en-US",
      title: "asdf",
      description: "Manage multiple runtime versions with a single CLI tool"
    },
    "/pt-br/": {
      lang: "pt-br",
      title: "asdf",
      description: "Gerencie múltiplas versões com um simples CLI"
    },
    "/zh-hans/": {
      lang: "zh-CN",
      title: "asdf",
      description: "管理多个运行环境版本的简单命令行工具"
    }
  },

  themeConfig: {
    // logo: "https://vuejs.org/images/logo.png",
    repo: "asdf-vm/asdf",
    docsBranch: "master",
    docsDir: "docs",
    locales: {
      "/": {
        selectLanguageName: "English",
        sidebar: sidebar.en,
        navbar: navbar.en,
        editLinkText: "Edit this page"
      },
      "/pt-br/": {
        selectLanguageName: "Brazilian Portuguese",
        sidebar: sidebar.pt_br,
        navbar: navbar.pt_br,
        editLinkText: "Edit this page",

        // 404 page
        notFound: ["Parece que estamos perdido!"],
        backToHome: "Voltar para a página inicial"
      },
      "/zh-hans/": {
        selectLanguageName: "简体中文",
        selectLanguageText: "选择语言",
        sidebar: sidebar.zh_hans,
        navbar: navbar.zh_hans,
        editLinkText: "在 Github 编辑此页面",

        // 404 page
        notFound: ["抱歉，您访问的页面不存在！"],
        backToHome: "返回首页"
      }
    }
  },

  plugins: [
    [
      "@vuepress/plugin-search",
      {
        locales: {
          "/": {
            placeholder: "Search"
          },
          "/pt-br/": {
            placeholder: "Search"
          },
          "/zh-hans/": {
            placeholder: "搜索"
          }
        }
      }
    ],
    ["@vuepress/plugin-shiki", { theme: "monokai" }]
  ]
};

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
          }
        }
      }
    ],
    ["@vuepress/plugin-shiki", { theme: "monokai" }]
  ]
};

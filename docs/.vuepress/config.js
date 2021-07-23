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
    }
    // "/pt-BR/": {
    //   lang: "pt-BR",
    //   title: "asdf",
    //   description: "TODO: translate"
    // }
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
        navbar: navbar.en
      }
      // "/pt-BR/": {
      //   selectLanguageName: "Brazilian Portuguese",
      //   sidebar: sidebar.pt_br,
      //   navbar: navbar.pt_br
      // }
    }
  },

  plugins: [
    [
      "@vuepress/plugin-search",
      {
        locales: {
          "/": {
            placeholder: "Search"
          }
          // "/pt-BR/": {
          //   placeholder: "Search"
          // }
        }
      }
    ],
    ["@vuepress/plugin-shiki", { theme: "monokai" }]
  ]
};

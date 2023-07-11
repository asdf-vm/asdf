import { defineConfig } from "vitepress";
import * as navbars from "./navbars";
import * as sidebars from "./sidebars";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "asdf",
  description: "Manage multiple runtime versions with a single CLI tool",
  lastUpdated: true,
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
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    search: {
      provider: "local",
    },
    socialLinks: [
      { icon: "github", link: "https://github.com/asdf-vm/asdf" },
      // { icon: "twitter", link: "https://twitter.com/asdf_vm" },
    ],
  },
});

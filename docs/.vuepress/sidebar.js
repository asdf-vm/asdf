const en = {
  "/guide/": ["/guide/introduction.md", "/guide/getting-started.md"],
  "/manage/": [
    {
      text: "Manage",
      children: [
        "/manage/core.md",
        "/manage/plugins.md",
        "/manage/versions.md",
        "/manage/configuration.md",
        "/manage/commands.md",
        {
          text: "Changelog",
          link: "https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md"
        }
      ]
    }
  ],
  "/plugins/": [
    {
      text: "Author",
      children: [
        "/plugins/create.md",
        {
          text: "GitHub Plugin Template",
          link: "https://github.com/asdf-vm/asdf-plugin-template"
        }
      ]
    },
    {
      text: "First Party Plugins",
      children: [
        {
          text: "Elixir",
          link: "https://github.com/asdf-vm/asdf-elixir"
        },
        {
          text: "Erlang",
          link: "https://github.com/asdf-vm/asdf-erlang"
        },
        {
          text: "Node.js",
          link: "https://github.com/asdf-vm/asdf-nodejs"
        },
        {
          text: "Ruby",
          link: "https://github.com/asdf-vm/asdf-ruby"
        }
      ]
    },
    {
      text: "Community Plugins",
      children: [
        {
          text: "asdf-community",
          link: "https://github.com/asdf-community/"
        }
      ]
    },
    {
      text: "Reference",
      children: [
        {
          text: "Plugin Shortname Index",
          link: "https://github.com/asdf-vm/asdf-plugins"
        }
      ]
    }
  ],
  "/contribute/": [
    {
      text: "Contribute",
      children: [
        "/contribute/core.md",
        "/contribute/documentation.md",
        "/contribute/first-party-plugins.md",
        "/contribute/github-actions.md"
      ]
    }
  ],
  "/learn-more/": [
    {
      text: "Questions",
      children: [
        "/learn-more/faq.md",

        {
          text: "GitHub Issues",
          link: "https://github.com/asdf-vm/asdf/issues"
        },
        {
          text: "GitHub Discussions",
          link: "https://github.com/asdf-vm/asdf/discussions"
        },
        {
          text: "StackOverflow Tag",
          link: "https://stackoverflow.com/questions/tagged/asdf-vm"
        }
      ]
    },
    {
      text: "Resources",
      children: ["/learn-more/thanks.md"]
    }
  ]
};

const pt_br = {
  "/pt-BR/guide/": [
    "/pt-BR/guide/introduction.md",
    "/pt-BR/guide/getting-started.md"
  ]
};

module.exports = { en, pt_br };

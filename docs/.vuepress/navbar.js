const en = [
  {
    text: "Getting Started",
    link: "/guide/getting-started.html",
    activeMatch: "/guide/"
  },
  {
    text: "Reference",
    children: [
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
    ]
  },
  {
    text: "Plugins",
    children: [
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
            link: "https://github.com/asdf-community"
          },
          {
            text: "GitHub Topics Search",
            link: "https://github.com/topics/asdf-plugin"
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
    ]
  },
  {
    text: "Contribute",
    children: [
      {
        text: "Core",
        children: ["/contribute/core.md", "/contribute/documentation.md"]
      },
      {
        text: "Plugins",
        children: ["/contribute/first-party-plugins.md"]
      },
      {
        text: "CICD",
        children: ["/contribute/github-actions.md"]
      }
    ]
  },
  {
    text: "Learn More",
    children: [
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
  }
];

const pt_br = [
  {
    text: "Getting Started",
    link: "/pt-br/guide/getting-started.html",
    activeMatch: "/pt-br/guide/"
  },
  {
    text: "Reference",
    children: [
      {
        text: "Manage",
        children: [
          "/pt-br/manage/core.md",
          "/pt-br/manage/plugins.md",
          "/pt-br/manage/versions.md",
          "/pt-br/manage/configuration.md",
          "/pt-br/manage/commands.md",
          {
            text: "Alterações",
            link: "https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md"
          }
        ]
      }
    ]
  },
  {
    text: "Plugins",
    children: [
      {
        text: "Author",
        children: [
          "/pt-br/plugins/create.md",
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
            link: "https://github.com/asdf-community"
          },
          {
            text: "GitHub Topics Search",
            link: "https://github.com/topics/asdf-plugin"
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
    ]
  },
  {
    text: "Contribute",
    children: [
      {
        text: "Core",
        children: [
          "/pt-br/contribute/core.md",
          "/pt-br/contribute/documentation.md"
        ]
      },
      {
        text: "Plugins",
        children: ["/pt-br/contribute/first-party-plugins.md"]
      },
      {
        text: "CICD",
        children: ["/pt-br/contribute/github-actions.md"]
      }
    ]
  },
  {
    text: "Learn More",
    children: [
      {
        text: "Questions",
        children: [
          "/pt-br/learn-more/faq.md",
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
        children: ["/pt-br/learn-more/thanks.md"]
      }
    ]
  }
];

module.exports = { en, pt_br };

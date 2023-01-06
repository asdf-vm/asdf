const en = [
  {
    text: "Introduction",
    link: "/guide/introduction.html",
    activeMatch: "/guide/introduction",
  },
  {
    text: "Getting Started",
    link: "/guide/getting-started.html",
    activeMatch: "/guide/getting-started",
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
            link: "https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md",
          },
        ],
      },
    ],
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
            link: "https://github.com/asdf-vm/asdf-plugin-template",
          },
        ],
      },
      {
        text: "First Party Plugins",
        children: [
          {
            text: "Elixir",
            link: "https://github.com/asdf-vm/asdf-elixir",
          },
          {
            text: "Erlang",
            link: "https://github.com/asdf-vm/asdf-erlang",
          },
          {
            text: "Node.js",
            link: "https://github.com/asdf-vm/asdf-nodejs",
          },
          {
            text: "Ruby",
            link: "https://github.com/asdf-vm/asdf-ruby",
          },
        ],
      },
      {
        text: "Community Plugins",
        children: [
          {
            text: "asdf-community",
            link: "https://github.com/asdf-community",
          },
          {
            text: "GitHub Topics Search",
            link: "https://github.com/topics/asdf-plugin",
          },
        ],
      },
      {
        text: "Reference",
        children: [
          {
            text: "Plugin Shortname Index",
            link: "https://github.com/asdf-vm/asdf-plugins",
          },
        ],
      },
    ],
  },
  {
    text: "Contribute",
    children: [
      {
        text: "Core",
        children: ["/contribute/core.md", "/contribute/documentation.md"],
      },
      {
        text: "Plugins",
        children: ["/contribute/first-party-plugins.md"],
      },
      {
        text: "CICD",
        children: ["/contribute/github-actions.md"],
      },
    ],
  },
  {
    text: "More",
    children: [
      {
        text: "Questions",
        children: [
          "/more/faq.md",
          {
            text: "GitHub Issues",
            link: "https://github.com/asdf-vm/asdf/issues",
          },
          {
            text: "StackOverflow Tag",
            link: "https://stackoverflow.com/questions/tagged/asdf-vm",
          },
        ],
      },
      {
        text: "Community",
        children: [
          {
            text: "asdf-community",
            link: "https://github.com/asdf-community",
          },
          "/more/community-projects.md",
        ],
      },
      {
        text: "Resources",
        children: ["/more/thanks.md"],
      },
    ],
  },
];

const pt_br = [
  {
    text: "Getting Started",
    link: "/pt-br/guide/getting-started.html",
    activeMatch: "/pt-br/guide/",
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
            link: "https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md",
          },
        ],
      },
    ],
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
            link: "https://github.com/asdf-vm/asdf-plugin-template",
          },
        ],
      },
      {
        text: "First Party Plugins",
        children: [
          {
            text: "Elixir",
            link: "https://github.com/asdf-vm/asdf-elixir",
          },
          {
            text: "Erlang",
            link: "https://github.com/asdf-vm/asdf-erlang",
          },
          {
            text: "Node.js",
            link: "https://github.com/asdf-vm/asdf-nodejs",
          },
          {
            text: "Ruby",
            link: "https://github.com/asdf-vm/asdf-ruby",
          },
        ],
      },
      {
        text: "Community Plugins",
        children: [
          {
            text: "asdf-community",
            link: "https://github.com/asdf-community",
          },
          {
            text: "GitHub Topics Search",
            link: "https://github.com/topics/asdf-plugin",
          },
        ],
      },
      {
        text: "Reference",
        children: [
          {
            text: "Plugin Shortname Index",
            link: "https://github.com/asdf-vm/asdf-plugins",
          },
        ],
      },
    ],
  },
  {
    text: "Contribute",
    children: [
      {
        text: "Core",
        children: [
          "/pt-br/contribute/core.md",
          "/pt-br/contribute/documentation.md",
        ],
      },
      {
        text: "Plugins",
        children: ["/pt-br/contribute/first-party-plugins.md"],
      },
      {
        text: "CICD",
        children: ["/pt-br/contribute/github-actions.md"],
      },
    ],
  },
  {
    text: "More",
    children: [
      {
        text: "Questions",
        children: [
          "/pt-br/more/faq.md",
          {
            text: "GitHub Issues",
            link: "https://github.com/asdf-vm/asdf/issues",
          },
          {
            text: "StackOverflow Tag",
            link: "https://stackoverflow.com/questions/tagged/asdf-vm",
          },
        ],
      },
      {
        text: "Community",
        children: [
          {
            text: "asdf-community",
            link: "https://github.com/asdf-community",
          },
          "/pt-br/more/community-projects.md",
        ],
      },
      {
        text: "Resources",
        children: ["/pt-br/more/thanks.md"],
      },
    ],
  },
];

const zh_hans = [
  {
    text: "快速上手",
    link: "/zh-hans/guide/getting-started.html",
    activeMatch: "/zh-hans/guide/",
  },
  {
    text: "参考",
    children: [
      {
        text: "管理",
        children: [
          "/zh-hans/manage/core.md",
          "/zh-hans/manage/plugins.md",
          "/zh-hans/manage/versions.md",
          "/zh-hans/manage/configuration.md",
          "/zh-hans/manage/commands.md",
          {
            text: "更新日志",
            link: "https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md",
          },
        ],
      },
    ],
  },
  {
    text: "插件",
    children: [
      {
        text: "成为作者",
        children: [
          "/zh-hans/plugins/create.md",
          {
            text: "插件模板",
            link: "https://github.com/asdf-vm/asdf-plugin-template",
          },
        ],
      },
      {
        text: "官方插件",
        children: [
          {
            text: "Elixir",
            link: "https://github.com/asdf-vm/asdf-elixir",
          },
          {
            text: "Erlang",
            link: "https://github.com/asdf-vm/asdf-erlang",
          },
          {
            text: "Node.js",
            link: "https://github.com/asdf-vm/asdf-nodejs",
          },
          {
            text: "Ruby",
            link: "https://github.com/asdf-vm/asdf-ruby",
          },
        ],
      },
      {
        text: "社区插件",
        children: [
          {
            text: "asdf-community",
            link: "https://github.com/asdf-community",
          },
          {
            text: "GitHub 主题搜索",
            link: "https://github.com/topics/asdf-plugin",
          },
        ],
      },
      {
        text: "参考",
        children: [
          {
            text: "插件缩写索引",
            link: "https://github.com/asdf-vm/asdf-plugins",
          },
        ],
      },
    ],
  },
  {
    text: "如何贡献",
    children: [
      {
        text: "核心",
        children: [
          "/zh-hans/contribute/core.md",
          "/zh-hans/contribute/documentation.md",
        ],
      },
      {
        text: "插件",
        children: ["/zh-hans/contribute/first-party-plugins.md"],
      },
      {
        text: "持续集成/持续部署",
        children: ["/zh-hans/contribute/github-actions.md"],
      },
    ],
  },
  {
    text: "更多的",
    children: [
      {
        text: "提问",
        children: [
          "/zh-hans/more/faq.md",
          {
            text: "GitHub Issues",
            link: "https://github.com/asdf-vm/asdf/issues",
          },
          {
            text: "StackOverflow Tag",
            link: "https://stackoverflow.com/questions/tagged/asdf-vm",
          },
        ],
      },
      {
        text: "Community",
        children: [
          {
            text: "asdf-community",
            link: "https://github.com/asdf-community",
          },
          "/zh-hans/more/community-projects.md",
        ],
      },
      {
        text: "Resources",
        children: ["/zh-hans/more/thanks.md"],
      },
    ],
  },
];

export default { en, pt_br, zh_hans };

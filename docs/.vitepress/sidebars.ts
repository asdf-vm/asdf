const en = [
  {
    text: "Guide",
    collapsed: false,
    items: [
      { text: "What is asdf?", link: "/guide/introduction" },
      { text: "Getting Started", link: "/guide/getting-started" },
      { text: "Getting Started (pre-0.16.0)", link: "/guide/getting-started-legacy" },
      { text: "Upgrading to 0.16.0", link: "/guide/upgrading-to-v0-16" },

    ],
  },
  {
    text: "Usage",
    collapsed: false,
    items: [
      { text: "Core", link: "/manage/core" },
      { text: "Plugins", link: "/manage/plugins" },
      { text: "Versions", link: "/manage/versions" },
    ],
  },
  {
    text: "Reference",
    collapsed: false,
    items: [
      { text: "Configuration", link: "/manage/configuration" },
      { text: "All Commands", link: "/manage/commands" },
      { text: "Dependencies", link: "/manage/dependencies" },
      {
        text: "Plugin Shortname Index",
        link: "https://github.com/asdf-vm/asdf-plugins",
      },
    ],
  },
  {
    text: "Plugins",
    collapsed: true,
    items: [
      {
        text: "Authors",
        items: [
          { text: "Create a Plugin", link: "/plugins/create" },
          {
            text: "GitHub Plugin Template",
            link: "https://github.com/asdf-vm/asdf-plugin-template",
          },
        ],
      },
      {
        text: "First Party Plugins",
        items: [
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
        items: [
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
    ],
  },
  {
    text: "Questions",
    collapsed: true,
    items: [
      { text: "FAQ", link: "/more/faq" },
      {
        text: "GitHub Issues",
        link: "https://github.com/asdf-vm/asdf/issues",
      },
      {
        text: "Stack Overflow Tag",
        link: "https://stackoverflow.com/questions/tagged/asdf-vm",
      },
    ],
  },
  {
    text: "Contribute",
    collapsed: true,
    items: [
      { text: "Core asdf", link: "/contribute/core" },
      { text: "Documentation", link: "/contribute/documentation" },
      {
        text: "First-Party Plugins",
        link: "/contribute/first-party-plugins",
      },
      { text: "GitHub Actions", link: "/contribute/github-actions" },
    ],
  },
  { text: "Community Projects", link: "/more/community-projects" },
  { text: "Thanks", link: "/more/thanks" },
];

const ko_kr = [
  {
    text: "가이드",
    collapsed: false,
    items: [
      { text: "asdf이란?", link: "/ko-kr/guide/introduction" },
      { text: "시작하기", link: "/ko-kr/guide/getting-started" },
    ],
  },
  {
    text: "사용방법",
    collapsed: false,
    items: [
      { text: "코어", link: "/ko-kr/manage/core" },
      { text: "플러그인", link: "/ko-kr/manage/plugins" },
      { text: "버전", link: "/ko-kr/manage/versions" },
    ],
  },
  {
    text: "참고자료",
    collapsed: false,
    items: [
      { text: "설정", link: "/ko-kr/manage/configuration" },
      { text: "모든 명령어", link: "/ko-kr/manage/commands" },
      {
        text: "플러그인 Shortname 인덱스",
        link: "https://github.com/asdf-vm/asdf-plugins",
      },
    ],
  },
  {
    text: "플러그인",
    collapsed: true,
    items: [
      {
        text: "저자",
        items: [
          { text: "플러그인 만들기", link: "/ko-kr/plugins/create" },
          {
            text: "GitHub 플러그인 템플릿",
            link: "https://github.com/asdf-vm/asdf-plugin-template",
          },
        ],
      },
      {
        text: "공식 플러그인",
        items: [
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
        text: "커뮤니티 플러그인",
        items: [
          {
            text: "asdf-community",
            link: "https://github.com/asdf-community",
          },
          {
            text: "GitHub 토픽 검색",
            link: "https://github.com/topics/asdf-plugin",
          },
        ],
      },
    ],
  },
  {
    text: "질문",
    collapsed: true,
    items: [
      { text: "자주 묻는 질문", link: "/ko-kr/more/faq" },
      {
        text: "GitHub 이슈",
        link: "https://github.com/asdf-vm/asdf/issues",
      },
      {
        text: "Stack Overflow 태그",
        link: "https://stackoverflow.com/questions/tagged/asdf-vm",
      },
    ],
  },
  {
    text: "기여하기",
    collapsed: true,
    items: [
      { text: "코어 asdf", link: "/ko-kr/contribute/core" },
      { text: "문서", link: "/ko-kr/contribute/documentation" },
      {
        text: "공식 플러그인",
        link: "/ko-kr/contribute/first-party-plugins",
      },
      { text: "GitHub Actions", link: "/ko-kr/contribute/github-actions" },
    ],
  },
  { text: "커뮤니티 프로젝트", link: "/ko-kr/more/community-projects" },
  { text: "감사인사", link: "/ko-kr/more/thanks" },
];

const ja_jp = [
  {
    text: "ガイド",
    collapsed: false,
    items: [
      { text: "asdfってなに?", link: "/ja-jp/guide/introduction" },
      { text: "はじめよう", link: "/ja-jp/guide/getting-started" },
      { text: "はじめよう (0.16.0以前)", link: "/ja-jp/guide/getting-started-legacy" },
      { text: "0.16.0にアップグレードする", link: "/ja-jp/guide/upgrading-to-v0-16" },
    ],
  },
  {
    text: "使い方",
    collapsed: false,
    items: [
      { text: "コア", link: "/ja-jp/manage/core" },
      { text: "プラグイン", link: "/ja-jp/manage/plugins" },
      { text: "バージョン", link: "/ja-jp/manage/versions" },
    ],
  },
  {
    text: "リファレンス",
    collapsed: false,
    items: [
      { text: "構成設定", link: "/ja-jp/manage/configuration" },
      { text: "すべてのコマンド", link: "/ja-jp/manage/commands" },
      {
        text: "プラグインショートネームの一覧",
        link: "https://github.com/asdf-vm/asdf-plugins",
      },
    ],
  },
  {
    text: "プラグイン",
    collapsed: true,
    items: [
      {
        text: "開発者向け",
        items: [
          { text: "プラグインの作成", link: "/ja-jp/plugins/create" },
          {
            text: "GitHubプラグインテンプレート",
            link: "https://github.com/asdf-vm/asdf-plugin-template",
          },
        ],
      },
      {
        text: "公式プラグイン",
        items: [
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
        text: "コミュニティプラグイン",
        items: [
          {
            text: "asdf-community",
            link: "https://github.com/asdf-community",
          },
          {
            text: "GitHubトピック検索",
            link: "https://github.com/topics/asdf-plugin",
          },
        ],
      },
    ],
  },
  {
    text: "困ったときは",
    collapsed: true,
    items: [
      { text: "FAQ", link: "/ja-jp/more/faq" },
      {
        text: "GitHub イシュー",
        link: "https://github.com/asdf-vm/asdf/issues",
      },
      {
        text: "Stack Overflow タグ",
        link: "https://stackoverflow.com/questions/tagged/asdf-vm",
      },
    ],
  },
  {
    text: "コントリビューション",
    collapsed: true,
    items: [
      { text: "asdf コア", link: "/ja-jp/contribute/core" },
      { text: "ドキュメント", link: "/ja-jp/contribute/documentation" },
      {
        text: "公式プラグイン",
        link: "/ja-jp/contribute/first-party-plugins",
      },
      { text: "GitHub Actions", link: "/ja-jp/contribute/github-actions" },
    ],
  },
  { text: "コミュニティプロジェクト", link: "/ja-jp/more/community-projects" },
  { text: "謝辞", link: "/ja-jp/more/thanks" },
];

const pt_br = [
  {
    text: "Guia",
    collapsed: false,
    items: [
      { text: "O que é asdf?", link: "/pt-br/guide/introduction" },
      { text: "Começar", link: "/pt-br/guide/getting-started" },
    ],
  },
  {
    text: "Uso",
    collapsed: false,
    items: [
      { text: "Essencial", link: "/pt-br/manage/core" },
      { text: "Plugins", link: "/pt-br/manage/plugins" },
      { text: "Versões", link: "/pt-br/manage/versions" },
    ],
  },
  {
    text: "Referência",
    collapsed: false,
    items: [
      { text: "Configuração", link: "/pt-br/manage/configuration" },
      { text: "Todos os comandos", link: "/pt-br/manage/commands" },
      {
        text: "Plugin Shortname Index",
        link: "https://github.com/asdf-vm/asdf-plugins",
      },
    ],
  },
  {
    text: "Plugins",
    collapsed: true,
    items: [
      {
        text: "Autoria",
        items: [
          { text: "Criar um plug-in", link: "/pt-br/plugins/create" },
          {
            text: "GitHub Plugin Template",
            link: "https://github.com/asdf-vm/asdf-plugin-template",
          },
        ],
      },
      {
        text: "Plug-ins Próprios",
        items: [
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
        text: "Plug-ins da Comunidade",
        items: [
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
    ],
  },
  {
    text: "Questões",
    collapsed: true,
    items: [
      { text: "Perguntas Frequentes", link: "/pt-br/more/faq" },
      {
        text: "GitHub Issues",
        link: "https://github.com/asdf-vm/asdf/issues",
      },
      {
        text: "Stack Overflow Tag",
        link: "https://stackoverflow.com/questions/tagged/asdf-vm",
      },
    ],
  },
  {
    text: "Contribute",
    collapsed: true,
    items: [
      { text: "Essencial asdf", link: "/pt-br/contribute/core" },
      { text: "Documentação", link: "/pt-br/contribute/documentation" },
      {
        text: "Plug-ins Próprios",
        link: "/pt-br/contribute/first-party-plugins",
      },
      { text: "GitHub Actions", link: "/pt-br/contribute/github-actions" },
    ],
  },
  { text: "Projetos Comunitários", link: "/pt-br/more/community-projects" },
  { text: "Créditos", link: "/pt-br/more/thanks" },
];

const zh_hans = [
  {
    text: "指导",
    collapsed: false,
    items: [
      { text: "什么是asdf？", link: "/zh-hans/guide/introduction" },
      { text: "快速入门", link: "/zh-hans/guide/getting-started" },
    ],
  },
  {
    text: "用法",
    collapsed: false,
    items: [
      { text: "核心", link: "/zh-hans/manage/core" },
      { text: "插件", link: "/zh-hans/manage/plugins" },
      { text: "版本", link: "/zh-hans/manage/versions" },
    ],
  },
  {
    text: "参考",
    collapsed: false,
    items: [
      { text: "配置", link: "/zh-hans/manage/configuration" },
      { text: "所有命令", link: "/zh-hans/manage/commands" },
      {
        text: "插件缩写索引",
        link: "https://github.com/asdf-vm/asdf-plugins",
      },
    ],
  },
  {
    text: "插件",
    collapsed: true,
    items: [
      {
        text: "成为作者",
        items: [
          { text: "创建插件", link: "/zh-hans/plugins/create" },
          {
            text: "GitHub 插件模板",
            link: "https://github.com/asdf-vm/asdf-plugin-template",
          },
        ],
      },
      {
        text: "官方插件",
        items: [
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
        items: [
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
    ],
  },
  {
    text: "问题",
    collapsed: true,
    items: [
      { text: "经常问的问题", link: "/zh-hans/more/faq" },
      {
        text: "GitHub Issues",
        link: "https://github.com/asdf-vm/asdf/issues",
      },
      {
        text: "Stack Overflow Tag",
        link: "https://stackoverflow.com/questions/tagged/asdf-vm",
      },
    ],
  },
  {
    text: "如何贡献",
    collapsed: true,
    items: [
      { text: "核心", link: "/zh-hans/contribute/core" },
      { text: "文档", link: "/zh-hans/contribute/documentation" },
      {
        text: "官方插件",
        link: "/zh-hans/contribute/first-party-plugins",
      },
      { text: "GitHub Actions", link: "/zh-hans/contribute/github-actions" },
    ],
  },
  { text: "社区项目", link: "/zh-hans/more/community-projects" },
  { text: "致谢", link: "/zh-hans/more/thanks" },
];

export { en, ko_kr, ja_jp, pt_br, zh_hans };

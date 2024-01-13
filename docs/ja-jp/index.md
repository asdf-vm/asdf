---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: asdf
  text: マルチランタイム<br/>バージョンマネージャ
  tagline: 1つのツールですべてのランタイムのバージョンを管理しましょう!
  actions:
    - theme: brand
      text: はじめよう
      link: /ja-jp/guide/getting-started
    - theme: alt
      text: asdfってなに?
      link: /ja-jp/guide/introduction
    - theme: alt
      text: GitHubをみる
      link: https://github.com/asdf-vm/asdf

features:
  - title: 単一ツール
    details: "単体のCLIツールとコマンドインターフェースで、各プロジェクトのランタイムを管理できます。"
    icon: 🎉
  - title: プラグイン
    details: "既存ランタイム・ツールを使用した大規模なエコシステムです。必要に応じて新しいツールをサポートできるシンプルなAPIを用意しています!"
    icon: 🔌
  - title: 後方互換性
    details: ".nvmrc、.node-version、.ruby-versionといった既存構成ファイルから、スムーズに移行できます!"
    icon: ⏮
  - title: "単一の構成ファイル"
    details: ".tool-versionsを使用すると、すべてのツール、ランタイム、およびそれらのバージョンを、共有された単一の場所で管理できます。"
    icon: 📄
  - title: "シェル"
    details: "Bash、ZSH、Fish、およびElvishをサポートし、コマンド補完にも対応しています。"
    icon: 🐚
  - title: "GitHub Actions"
    details: "CI/CDワークフローで、.tool-versionsをインストールし利用するためのGitHub Actionを提供しています。"
    icon: 🤖
---

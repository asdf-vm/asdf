---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: asdf
  text: 多运行时版本管理器
  tagline: 使用一个工具管理所有运行时版本！
  actions:
    - theme: brand
      text: 快速上手
      link: /zh-hans/guide/getting-started
    - theme: alt
      text: 什么是asdf？
      link: /zh-hans/guide/introduction
    - theme: alt
      text: 在 Github 上查看
      link: https://github.com/asdf-vm/asdf

features:
  - title: 一个工具
    details: "使用单个命令行工具和命令界面管理你的每个项目运行环境。"
    icon: 🎉
  - title: 插件
    details: "现有运行环境和工具的大型生态系统。简单 API 用于根据需要添加对新工具的支持！"
    icon: 🔌
  - title: 向后兼容
    details: "支持从现有配置文件 .nvmrc、.node-version、.ruby-version 平滑迁移！"
    icon: ⏮
  - title: "一个配置文件"
    details: "一个可共享的 .tool-versions 配置文件管理所有工具、运行环境及其版本。"
    icon: 📄
  - title: "Shells"
    details: "支持 Bash、ZSH、Fish 和 Elvish，并提供补全功能。"
    icon: 🐚
  - title: "GitHub Actions"
    details: "提供 Github Action 在 CI/CD 工作流中安装和使用 .tool-versions。"
    icon: 🤖
---

---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: asdf
  text: The Multiple Runtime Version Manager
  tagline: Manage all your runtime versions with one tool!
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
    - theme: alt
      text: What is asdf?
      link: /guide/introduction
    - theme: alt
      text: View on GitHub
      link: https://github.com/asdf-vm/asdf

features:
  - title: One Tool
    details: "Manage each of your project runtimes with a single CLI tool and command interface."
    icon: 🎉
  - title: Plugins
    details: "Large ecosystem of existing runtimes & tools. Simple API to add support for new tools as you need!"
    icon: 🔌
  - title: Backwards Compatible
    details: "Support for existing config files .nvmrc, .node-version, .ruby-version for smooth migration!"
    icon: ⏮
  - title: "One Config File"
    details: ".tool-versions to manage all your tools, runtimes and their versions in a single, sharable place."
    icon: 📄
  - title: "Shells"
    details: "Supports Bash, ZSH, Fish & Elvish with completions available."
    icon: 🐚
  - title: "GitHub Actions"
    details: "Provides a GitHub Action to install and utilize your .tool-versions in your CI/CD workflows."
    icon: 🤖

---

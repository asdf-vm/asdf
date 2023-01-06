# 项目简介

`asdf` 是一个工具版本管理器。所有的工具版本定义都包含在一个文件（`.tool-versions`）中，你可以将配置文件放在项目的 Git 存储库中以便于和团队其他成员共享，从而确保每个人都使用**完全**相同的工具版本。

传统工作方式需要多个命令行版本管理器，而且每个管理器都有其不同的 API、配置文件和实现方式（比如，`$PATH` 操作、垫片、环境变量等等）。`asdf` 提供单个交互方式和配置文件来简化开发工作流程，并可通过简单的插件接口扩展到所有工具和运行环境。

## 它是如何工作的

一旦 `asdf` 核心在 Shell 配置中设置好之后，你可以安装插件来管理特定的工具。当通过插件安装工具时，安装的可执行程序会为每个可执行程序创建 [垫片](<https://zh.wikipedia.org/wiki/%E5%9E%AB%E7%89%87_(%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1)>)。当你尝试运行其中一个可执行程序时，将运行垫片，从而允许 `asdf` 识别 `.tool-versions` 文件中设置的工具版本并执行该版本。

## 相关项目

### nvm / n / rbenv 等

[nvm](https://github.com/nvm-sh/nvm), [n](https://github.com/tj/n) 和 [rbenv](https://github.com/rbenv/rbenv) 等工具都是用 Shell 脚本写的，这些脚本能为工具安装的可执行程序创建垫片。

`asdf` 非常相似，目的是在工具/运行环境版本管理领域竞争。`asdf` 的区别之处在于它的插件系统，它消除了每个工具/运行环境对管理工具的需求、每个管理工具的不同命令以及存储库中不同的`*-版本`文件。

<!-- ### pyenv

TODO: someone with Python background expand on this

`asdf` has some similarities to `pyenv` but is missing some key features. The `asdf` team is looking at introducing some of these `pyenv` specific features, though no roadmap or timeline is available. -->

### direnv

> 使用可以根据当前目录加载和卸载环境变量的新功能增强现有 shell。

`asdf` 不管理环境变量，但是有一个插件 [`asdf-direnv`](https://github.com/asdf-community/asdf-direnv) 可以用来集成 direnv 的特性到 `asdf` 中。

请查看 [direnv 文档](https://direnv.net/) 了解更多。

### Homebrew

> macOS（或者 Linux）上缺失包的管理器

Homebrew 管理你的软件包及其上游依赖。`asdf` 不管理上游依赖，它不是包管理器。这个责任取决于用户，尽管我们试图保持依赖关系列表很小。

请查看 [Homebrew 文档](https://brew.sh/) 了解更多。

### NixOS

> Nix 是一种采用独特方法进行软件包管理和系统配置的工具

NixOS 旨在通过管理每个工具的整个依赖关系树中软件包的确切版本来构建真正可重复的环境，有些是 `asdf` 无法做到的。NixOS 使用自己的编程语言、许多命令行工具和超过 60,000 个包的包集合来实现这一点。

同样，`asdf` 不管理上游依赖，并且它不是一个包管理器。

请查看 [NixOS 文档](https://nixos.org/guides/how-nix-works.html) 了解更多。

## 为什么使用 asdf？

`asdf` 确保团队可以使用**完全**相同的工具版本，通过插件系统支持**很多**工具，以及作为 Shell 配置中包含的单个 **Shell** 脚本的 _简单性和熟悉性_ 。

::: tip 注意
`asdf` 并不打算成为一个系统包管理器。它是一个工具版本管理器。仅仅因为你可以为任何工具创建插件并使用 `asdf` 管理其版本，并不意味着这是这个特定工具的最佳实践方案。
:::

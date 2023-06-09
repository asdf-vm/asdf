# 快速入门

`asdf` 安装过程包括：

1. 安装依赖
2. 下载 `asdf` 核心
3. 安装 `asdf`
4. 为每一个你想要管理的工具/运行环境安装插件
5. 安装工具/运行环境的一个版本
6. 通过 `.tool-versions` 配置文件设置全局和项目版本

## 1. 安装依赖

asdf primarily requires `git` & `curl`. Here is a _non-exhaustive_ list of commands to run for _your_ package manager (some might automatically install these tools in later steps).

| OS    | Package Manager | Command                            |
| ----- | --------------- | ---------------------------------- |
| linux | Aptitude        | `apt install curl git`             |
| linux | DNF             | `dnf install curl git`             |
| linux | Pacman          | `pacman -S curl git`               |
| linux | Zypper          | `zypper install curl git`          |
| macOS | Homebrew        | `brew install coreutils curl git`  |
| macOS | Spack           | `spack install coreutils curl git` |

::: tip Note

`sudo` may be required depending on your system configuration.

:::

## 2. 下载 asdf

### Official Download

<!-- x-release-please-start-version -->

```shell:no-line-numbers
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0
```

<!-- x-release-please-end -->

### Community Supported Download Methods

We highly recommend using the official `git` method.

| Method   | Command                                                                                                                                                             |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Homebrew | `brew install asdf`                                                                                                                                                 |
| Pacman   | `git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si` or use your preferred [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) |

## 3. 安装 asdf

根据 Shell 脚本、操作系统和安装方法的组合不同，相应的配置也会不同。展开以下与你的系统最匹配的选项：

::: details Bash & Git

在 `~/.bashrc` 文件中加入以下内容：

```shell
. "$HOME/.asdf/asdf.sh"
```

补全功能必须在 `.bashrc` 文件中加入以下内容来配置完成：

```shell
. "$HOME/.asdf/completions/asdf.bash"
```

:::

::: details Bash & Git (macOS)

如果你正在使用 **macOS Catalina 或者更新的版本**, 默认的 shell 已经被修改为 **ZSH**。除非修改回 Bash, 否则请遵循 ZSH 的说明。

在 `~/.bash_profile` 文件中加入以下内容：

```shell
. "$HOME/.asdf/asdf.sh"
```

补全功能必须在 `.bash_profile` 文件中使用以下内容手动配置完成：

```shell
. "$HOME/.asdf/completions/asdf.bash"
```

:::

::: details Bash & Homebrew

使用以下命令将 `asdf.sh` 加入到 `~/.bashrc` 文件中：

```shell:no-line-numbers
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.bashrc
```

补全功能将需要 [按照 Homebrew 的说明完成配置](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) 或者执行以下命令：

```shell:no-line-numbers
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bashrc
```

:::

::: details Bash & Homebrew (macOS)

如果你正在使用 **macOS Catalina 或者更新的版本**, 默认的 shell 已经被修改为 **ZSH**。除非修改回 Bash, 否则请遵循 ZSH 的说明。

使用以下命令将 `asdf.sh` 加入到 `~/.bash_profile` 文件中：

```shell:no-line-numbers
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.bash_profile
```

补全功能将需要 [按照 Homebrew 的说明完成配置](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) 或者执行以下命令：

```shell:no-line-numbers
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bash_profile
```

:::

::: details Bash & Pacman

在 `~/.bashrc` 文件中加入以下内容：

```shell
. /opt/asdf-vm/asdf.sh
```

为了让补全功能正常工作需要安装 [`bash-completion`](https://wiki.archlinux.org/title/bash#Common_programs_and_options) 。
:::

::: details Fish & Git

在 `~/.config/fish/config.fish` 文件中加入以下内容：

```shell
source ~/.asdf/asdf.fish
```

补全功能必须按照以下命令手动配置完成：

```shell:no-line-numbers
mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

:::

::: details Fish & Homebrew

使用以下命令将 `asdf.fish` 加入到 `~/.config/fish/config.fish` 文件中：

```shell:no-line-numbers
echo -e "\nsource "(brew --prefix asdf)"/libexec/asdf.fish" >> ~/.config/fish/config.fish
```

Fish shell 的补全功能可以交给 [Homebrew 处理](https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish). 很友好！
:::

::: details Fish & Pacman

在 `~/.config/fish/config.fish` 文件中加入以下内容：

```shell
source /opt/asdf-vm/asdf.fish
```

补全功能将会在安装过程中由 AUR 包管理器自动配置完成。
:::

::: details Elvish & Git

使用以下命令将 `asdf.elv` 加入到 `~/.config/elvish/rc.elv` 文件中：

```shell:no-line-numbers
mkdir -p ~/.config/elvish/lib; ln -s ~/.asdf/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

补全功能将会自动配置。

:::

::: details Elvish & Homebrew

使用以下命令将 `asdf.elv` 加入到 `~/.config/elvish/rc.elv` 文件中：

```shell:no-line-numbers
mkdir -p ~/.config/elvish/lib; ln -s (brew --prefix asdf)/libexec/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

补全功能将会自动配置。

:::

::: details Elvish & Pacman

使用以下命令将 `asdf.elv` 加入到 `~/.config/elvish/rc.elv` 文件中：

```shell:no-line-numbers
mkdir -p ~/.config/elvish/lib; ln -s /opt/asdf-vm/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

补全功能将会自动配置。

:::

::: details ZSH & Git

在 `~/.zshrc` 文件中加入以下内容：

```shell
. "$HOME/.asdf/asdf.sh"
```

**或者** 使用 ZSH 框架插件，比如 [asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) 将会使脚本生效并安装补全功能。

补全功能会被 ZSH 框架 `asdf` 插件或者通过在 `.zshrc` 文件中加入以下内容自动配置：

```shell
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
```

- 如果你正在使用自定义的 `compinit` 配置，请确保 `compinit` 在 `asdf.sh` 生效位置的下方
- 如果你正在使用自定义的 `compinit` 配置和 ZSH 框架，请确保 `compinit` 在框架生效位置的下方

**警告**

如果你正在使用 ZSH 框架，有关的 `asdf` 插件或许需要更新才能通过 `fpath` 正确地使用最新的 ZSH 补全功能。Oh-My-ZSH asdf 插件还在更新中，请查看 [ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837) 了解更多。
:::

::: details ZSH & Homebrew

使用以下命令将 `asdf.sh` 加入到 `~/.zshrc` 文件中：

```shell
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
```

**或者** 使用 ZSH 框架插件，比如 [asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) 将会使脚本生效并安装补全功能。

补全功能可以被 ZSH 框架 `asdf` 或者 [按照 Homebrew 的指引](https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh) 完成配置。如果你正在使用 ZSH 框架，有关的 `asdf` 插件或许需要更新才能通过 `fpath` 正确地使用最新的 ZSH 补全功能。Oh-My-ZSH asdf 插件还在更新中，请查看 [ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837) 了解更多。
:::

::: details ZSH & Pacman

在 `~/.zshrc` 文件中加入以下内容：

```shell
. /opt/asdf-vm/asdf.sh
```

补全功能会被放在一个对 ZSH 很友好的位置，但是 [ZSH 必须使用自动补全完成配置](https://wiki.archlinux.org/index.php/zsh#Command_completion)。
:::

::: details PowerShell Core & Git

在 `~/.config/powershell/profile.ps1` 文件中加入以下内容：

```shell
. "$HOME/.asdf/asdf.ps1"
```

:::

::: details PowerShell Core & Homebrew

使用以下命令将 `asdf.ps1` 加入到 `~/.config/powershell/profile.ps1` 文件中：

```shell:no-line-numbers
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.ps1\"" >> ~/.config/powershell/profile.ps1
```

:::

::: details PowerShell Core & Pacman

在 `~/.config/powershell/profile.ps1` 文件中加入以下内容：

```shell
. /opt/asdf-vm/asdf.ps1
```

:::

::: details Nushell & Git

使用以下命令将 `asdf.nu` 加入到 `~/.config/nushell/config.nu` 文件中：

```shell
"\nlet-env ASDF_NU_DIR = ($env.HOME | path join '.asdf')\n source " + ($env.HOME | path join '.asdf/asdf.nu') | save --append $nu.config-path
```

补全功能将会自动配置。
:::

::: details Nushell & Homebrew

使用以下命令将 `asdf.nu` 加入到 `~/.config/nushell/config.nu` 文件中:

```shell:no-line-numbers
"\nlet-env ASDF_NU_DIR = (brew --prefix asdf | str trim | into string | path join 'libexec')\n source " +  (brew --prefix asdf | into string | path join 'libexec/asdf.nu') | save --append $nu.config-path
```

补全功能将会自动配置。
:::

::: details Nushell & Pacman

使用以下命令将 `asdf.nu` 加入到 `~/.config/nushell/config.nu` 文件中:

```shell
"\nlet-env ASDF_NU_DIR = '/opt/asdf-vm/'\n source /opt/asdf-vm/asdf.nu" | save --append $nu.config-path
```

补全功能将会自动配置。
:::

::: details POSIX Shell & Git

在 `~/.profile` 文件中加入以下内容：

```shell
export ASDF_DIR="$HOME/.asdf"
. "$HOME/.asdf/asdf.sh"
```

:::

::: details POSIX Shell & Homebrew

使用以下命令将 `asdf.sh` 加入到 `~/.profile` 文件中：

```shell:no-line-numbers
echo -e "\nexport ASDF_DIR=\"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.profile
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.profile
```

:::

::: details POSIX Shell & Pacman

在 `~/.profile` 文件中加入以下内容：

```shell
export ASDF_DIR="/opt/asdf-vm"
. /opt/asdf-vm/asdf.sh
```

:::

`asdf` 脚本需要在设置好的 `$PATH` **之后**和已经生效的框架（比如 oh-my-zsh 等等）**之后**的位置生效。

通常打开一个新的终端标签页来重启你的 shell 让 `PATH` 更改即时生效。

## 核心安装完成！

这样就完成了 `asdf` 核心的安装 🎉

`asdf` 仅在你安装**插件**、**工具**和管理它们的**版本**时才开始真正发挥作用。请继续阅读下面的指南来了解这些是如何做到的。

## 4. 安装插件

出于演示目的，我们将通过 [`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/) 插件来安装和设置 [Node.js](https://nodejs.org/)。

### 插件依赖

每个插件都有依赖，所以我们需要确认应该列举了这些依赖的插件源码。对于 `asdf-nodejs` 来说，它们是：

| 操作系统       | 安装依赖                                |
| -------------- | --------------------------------------- |
| Linux (Debian) | `apt-get install dirmngr gpg curl gawk` |
| macOS          | `brew install gpg gawk`                 |

我们应该提前安装这些依赖，因为有些插件有 post-install 钩子。

### 安装插件

```shell:no-line-numbers
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## 5. 安装指定版本

现在我们已经有了 Node.js 插件，所以我们可以开始安装某个版本了。

我们通过 `asdf list all nodejs` 可以看到所有可用的版本或者通过 `asdf list all nodejs 14` 查看版本子集。

我们将只安装最新可用的 `latest` 版本：

```shell:no-line-numbers
asdf install nodejs latest
```

::: tip 注意
`asdf` 强制使用准确的版本。`latest` 是一个通过 `asdf` 来解析到执行时刻的实际版本号的辅助工具。
:::

## 6. 设置默认版本

`asdf` 在从当前工作目录一直到 `$HOME` 目录的所有 `.tool-versions` 文件中进行工具的版本查找。查找在执行 `asdf` 管理的工具时实时发生。

::: warning 警告
如果没有为工具找到指定的版本，则会出现**错误**。`asdf current` 将显示当前目录中的工具和版本解析结果，或者不存在，以便你可以观察哪些工具将无法执行。
:::

### 全局

全局默认配置在 `$HOME/.tool-versions` 文件中进行管理。使用以下命令可以设置一个全局版本：

```shell:no-line-numbers
asdf global nodejs latest
```

`$HOME/.tool-versions` 文件内容将会如下所示：

```
nodejs 16.5.0
```

某些操作系统已经有一些由系统而非 `asdf` 安装和管理的工具了，`python` 就是一个常见的例子。你需要告诉 `asdf` 将管理权还给系统。[版本参考部分](/zh-hans/manage/versions.md) 将会引导你。

### 本地

本地版本被定义在 `$PWD/.tool-versions` 文件中（当前工作目录）。通常，这将会是一个项目的 Git 存储库。当在你想要的目录执行：

```shell:no-line-numbers
asdf local nodejs latest
```

`$PWD/.tool-versions` 文件内容将会如下所示：

```
nodejs 16.5.0
```

### 使用现有工具版本文件

`asdf` 支持从其他版本管理器的现有版本文件中迁移过来，比如 `rbenv` 的 `.ruby-version` 文件。这在每个插件中都原生支持。

[`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/) 支持从 `.nvmrc` 和 `.node-version` 文件进行迁移。为了启用此功能，请在 `asdf` 配置文件 `$HOME/.asdfrc` 中加入以下内容：

```
legacy_version_file = yes
```

请查看 [配置](/zh-hans/manage/configuration.md) 参考页面可以了解更多配置选项。

## 完成指南！

恭喜你完成了 `asdf` 的快速上手 🎉 你现在可以管理你的项目的 `nodejs` 版本了。对于项目中的其他工具类型可以执行类似步骤即可！

`asdf` 还有更多命令需要熟悉，你可以通过运行 `asdf --help` 或者 `asdf` 来查看它们。命令主要分为三类：

- [`asdf` 核心](/zh-hans/manage/core.md)
- [插件](/zh-hans/manage/plugins.md)
- [（工具的）版本](/zh-hans/manage/versions.md)

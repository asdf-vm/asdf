# 快速入门

## 1. 安装 asdf

asdf 的安装方式有以下几种：

::: details 使用包管理器 - **推荐**

| 包管理器 | 命令 |
| -------- | ----- |
| Homebrew | `brew install asdf` |
| Zypper | `zypper install asdf` |
| Pacman | `git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si` 或者你希望使用 [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) |

:::

:::: details 下载预编译二进制 - **简单**

<!--@include: @/zh-hans/parts/install-dependencies.md-->

##### 安装 asdf

1. 访问 https://github.com/asdf-vm/asdf/releases 并下载与操作系统和架构匹配的压缩包。
2. 从压缩包中解压 `asdf` 二进制文件到 `$PATH` 路径的某个文件夹.
3. 运行 `type -a asdf` 来验证 `asdf` 是否已经在 `$PATH` 路径中。放置 `asdf` 二进制文件的目录应该包含在 `type` 命令的输出中。如果不在，那么意味着第 2 步不是完全正确。

::::

:::: details 使用 `go install`

<!--@include: @/zh-hans/parts/install-dependencies.md-->

##### 安装 asdf

<!-- x-release-please-start-version -->
1. [安装 Go](https://go.dev/doc/install)
2. 运行 `go install github.com/asdf-vm/asdf/cmd/asdf@v0.18.1`
<!-- x-release-please-end -->

::::

:::: details 从源码构建

<!--@include: @/zh-hans/parts/install-dependencies.md-->

##### 安装 asdf

<!-- x-release-please-start-version -->
1. 克隆 asdf 仓库:
  ```shell
  git clone https://github.com/asdf-vm/asdf.git --branch v0.18.1
  ```
<!-- x-release-please-end -->
2. 运行 `make`
3. 复制 `asdf` 二进制文件到 `$PATH` 路径的某个文件夹.
4. 运行 `type -a asdf` 来验证 `asdf` 是否已经在 `$PATH` 路径中。放置 `asdf` 二进制文件的目录应该包含在 `type` 命令的输出中。如果不在，那么意味着第 3 步不是完全正确。

::::

## 2. 配置 asdf

::: tip 注意
大部分用户 **不** 需要自定义 asdf 插件、安装包、垫片数据的位置。但是，如果 `$HOME/.asdf` 不是你想要 asdf 写入的目录，你可以修改它。请通过在 Shell 的 RC 文件中定义 `ASDF_DATA_DIR` 变量来指定你想要的目录。
:::

根据 Shell 脚本、操作系统和安装方法的组合不同，相应的配置方式也会有所不同。展开以下与你的系统最匹配的选项。

**macOS 用户，请务必阅读本节最后关于 `path_helper` 的警告。**

::: details Bash

**macOS Catalina 或者更新的版本**： 默认的 shell 已经被修改为 **ZSH**。除非修改回 Bash, 否则请遵循 ZSH 的说明。

**Pacman**： 补全功能需要安装 [`bash-completion`](https://wiki.archlinux.org/title/bash#Common_programs_and_options)。

##### 将垫片目录添加到路径（必须）

在 `~/.bash_profile` 文件中添加以下内容：

```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### 自定义数据目录（可选）

在 `~/.bash_profile` 文件中上面一行声明之前添加以下变量声明：

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
```

##### 设置 shell 补全（可选）

在 `.bashrc` 文件中添加下面内容来配置补全功能：

```shell
. <(asdf completion bash)
```

:::

::: details Fish

##### 将垫片目录添加到路径（必须）

在 `~/.config/fish/config.fish` 文件中添加以下内容：

```shell
# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims
```

###### 自定义数据目录（可选）

**Pacman**: 补全功能会在 AUR 包安装时自动配置。

在 `~/.config/fish/config.fish` 文件中上面一行声明之前添加下面内容：

```shell
set -gx --prepend ASDF_DATA_DIR "/your/custom/data/dir"
```

##### 设置 shell 补全（可选）

必须通过以下命令手动配置补全功能：

```shell
$ asdf completion fish > ~/.config/fish/completions/asdf.fish
```

:::

::: details Elvish

##### 将垫片目录添加到路径（必须）

在 `~/.config/elvish/rc.elv` 文件中添加以下内容：

```shell
var asdf_data_dir = ~'/.asdf'
if (and (has-env ASDF_DATA_DIR) (!=s $E:ASDF_DATA_DIR '')) {
  set asdf_data_dir = $E:ASDF_DATA_DIR
}

if (not (has-value $paths $asdf_data_dir'/shims')) {
  set paths = [$path $@paths]
}
```

###### 自定义数据目录（可选）

修改在上面片段之前的如下一行内容为自定义数据目录：

```diff
-var asdf_data_dir = ~'/.asdf'
+var asdf_data_dir = '/your/custom/data/dir'
```

##### 设置 shell 补全（可选）

```shell
$ asdf completion elvish >> ~/.config/elvish/rc.elv
$ echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

:::

::: details ZSH

**Pacman**： 补全功能被放置在对 ZSH 友好的位置，但是 [ZSH 必须配置使用自动补全](https://wiki.archlinux.org/index.php/zsh#Command_completion)。

##### 将垫片目录添加到路径（必须）

在 `~/.zshrc` 文件中添加以下内容：
```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### 自定义数据目录（可选）

在 `~/.zshrc` 文件中上面一行声明之前添加以下内容：

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
```

##### 设置 shell 补全（可选）

补全功能可以通过 ZSH 框架的 `asdf` 插件 (类似 [asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf)) 或如下操作启用：

```shell
$ mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
$ asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
```

然后在 `.zshrc` 文件中添加以下内容：

```shell
# 添加补全功能到 fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
# 使用 ZSH 的 compinit 初始化补全功能
autoload -Uz compinit && compinit
```

**注意**

如果你正在 ZSH 框架中使用自定义的 `compinit` 设置 ，请确保 `compinit` 在框架加载之后加载。

补全功能可以通过 ZSH 框架 `asdf` 或者将需要 [按照 Homebrew 的说明进行配置](https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh). 如果你正在使用 ZSH 框架，与 asdf 关联的插件或许需要更新以便通过 `fpath` 正确使用新 ZSH。 Oh-My-ZSH asdf 插件尚未更新，请查看 [ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837) 了解更多。
:::

::: details PowerShell Core

##### 将垫片目录添加到路径（必须）

在 `~/.config/powershell/profile.ps1` 文件中添加以下内容：
```shell
# 确定垫片目录的位置
if ($null -eq $ASDF_DATA_DIR -or $ASDF_DATA_DIR -eq '') {
  $_asdf_shims = "${env:HOME}/.asdf/shims"
}
else {
  $_asdf_shims = "$ASDF_DATA_DIR/shims"
}

# 然后添加到 path 路径
$env:PATH = "${_asdf_shims}:${env:PATH}"
```

###### 自定义数据目录（可选）

在 `~/.config/powershell/profile.ps1` 文件中上面片段之前添加以下内容：

```shell
$env:ASDF_DATA_DIR = "/your/custom/data/dir"
```

Shell 补全功能不支持 PowerShell。

:::

::: details Nushell

##### 将垫片目录添加到路径（必须）

在 `~/.config/nushell/config.nu` 文件中添加以下内容：

```shell
let shims_dir = (
  if ( $env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  } | path join 'shims'
)
$env.PATH = ( $env.PATH | split row (char esep) | where { |p| $p != $shims_dir } | prepend $shims_dir )
```

###### 自定义数据目录（可选）

在 `~/.config/nushell/config.nu` 文件中上面内容之前添加下面变量声明：

```shell
$env.ASDF_DATA_DIR = "/your/custom/data/dir"
```

##### 设置 shell 补全（可选）

```shell
# If you've not customized the asdf data directory:
$ mkdir $"($env.HOME)/.asdf/completions"
$ asdf completion nushell | save $"($env.HOME)/.asdf/completions/nushell.nu"

# If you have customized the data directory by setting ASDF_DATA_DIR:
$ mkdir $"($env.ASDF_DATA_DIR)/completions"
$ asdf completion nushell | save $"($env.ASDF_DATA_DIR)/completions/nushell.nu"
```

然后在 `~/.config/nushell/config.nu` 文件中添加以下内容：

```shell
let asdf_data_dir = (
  if ( $env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  }
)
. "$asdf_data_dir/completions/nushell.nu"
```

:::

::: details POSIX Shell

##### 将垫片目录添加到路径（必须）

在 `~/.profile` 文件中添加以下内容：
```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### 自定义数据目录（可选）

在 `~/.profile` 文件中上面一行内容之前添加以下内容：

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
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

| 操作系统                         | 安装依赖                                |
| ------------------------------ | --------------------------------------- |
| Debian                         | `apt-get install dirmngr gpg curl gawk` |
| CentOS/ Rocky Linux/ AlmaLinux | `yum install gnupg2 curl gawk`          |
| macOS                          | `brew install gpg gawk`                 |

我们应该提前安装这些依赖，因为有些插件有 post-install 钩子。

### 安装插件

```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## 5. 安装指定版本

现在我们已经有了 Node.js 插件，所以我们可以开始安装某个版本了。

我们通过 `asdf list all nodejs` 可以看到所有可用的版本或者通过 `asdf list all nodejs 14` 查看版本子集。

我们将只安装最新可用的 `latest` 版本：

```shell
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

因为 asdf 会在当前目录寻找 `.tool-versions` 文件，如果没有找到将会继续逐层向上在父目录寻找 `.tool-versions` 文件直到找到。如果在父目录也没有找到 `.tool-versions` 文件，版本解析进程将会失败并且打印错误。

如果你想要设置一个默认版本用来应用在你工作的所有目录，你可以在 `$HOME/.tool-versions` 文件中定义版本。任何在家目录下的子目录都会被解析为同样的版本，除非子目录中设置了另外一个版本。

```shell
asdf set -u nodejs 16.5.0
```

`$HOME/.tool-versions` 文件内容将会变成：

```
nodejs 16.5.0
```

某些操作系统已经有一些由系统而非 `asdf` 安装和管理的工具了，`python` 就是一个常见的例子。你需要告诉 `asdf` 将管理权还给系统。[版本](/zh-hans/manage/versions.md) 参考页面将会引导你。

asdf 首先从当前工作目录的 `$PWD/.tool-versions` 文件中寻找版本。这可能是一个包含源代码或某个项目 Git 存储库的目录。当在你想要的目录执行时，你可以用 `asdf set` 来设置版本：

```shell
asdf set nodejs 16.5.0
```

`$PWD/.tool-versions` 文件内容将会变成：

```
nodejs 16.5.0
```

### 使用现有工具版本文件

`asdf` 支持从其他版本管理器的现有版本文件中迁移过来，比如 `rbenv` 的 `.ruby-version` 文件。这在每个插件中都原生支持。

[`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/) 支持从 `.nvmrc` 和 `.node-version` 文件进行迁移。为了启用此功能，请在 `asdf` 配置文件 `$HOME/.asdfrc` 中添加以下内容：

```
legacy_version_file = yes
```

查看 [配置](/zh-hans/manage/configuration.md) 参考页面可以了解更多配置选项。

## 完成指南！

恭喜你完成了 `asdf` 的快速上手 🎉 你现在可以管理你的项目的 `nodejs` 版本了。对于项目中的其他工具类型可以执行类似步骤即可！

`asdf` 还有更多命令需要熟悉，你可以通过运行 `asdf --help` 或者 `asdf` 来查看它们。命令主要分为三类：

- [`asdf` 核心](/zh-hans/manage/core.md)
- [插件](/zh-hans/manage/plugins.md)
- [（工具的）版本](/zh-hans/manage/versions.md)

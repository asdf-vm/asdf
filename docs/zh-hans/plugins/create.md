# 创建插件

插件是一个包含一些可执行脚本的 Git 存储库，用于支持对某种语言/工具进行版本控制。这些脚本由 asdf 通过命令运行，以支持诸如 `asdf list-all <name>`、`asdf install <name> <version>` 等功能。

## 快速入门

创建自己的插件有两种方式：

1. 使用 [asdf-vm/asdf-plugin-template](https://github.com/asdf-vm/asdf-plugin-template) 仓库来 [生成](https://github.com/asdf-vm/asdf-plugin-template/generate) 一个插件仓库（命名为 `asdf-<tool_name>`），其中已实现默认脚本。生成后，克隆该仓库并运行 `setup.bash` 脚本以交互式更新模版。
2. 创建名为 `asdf-<tool_name>` 的仓库，并实现文档中列出的所需脚本。

### 插件脚本的黄金规则

- 脚本**不应**调用其他 `asdf` 命令
- 保持 Shell 工具/命令的依赖列表简短
- 避免使用非便携式工具或命令标志。例如，`sort -V`。请参考 asdf 核心 [禁止命令列表](https://github.com/asdf-vm/asdf/blob/master/test/banned_commands.bats)。

## 脚本概述

可从 asdf 调用的所有脚本的完整列表。

| 脚本                                                                                                   | 描述                                   |
| :---------------------------------------------------------------------------------------------------- |:---------------------------------------|
| [bin/list-all](#bin-list-all) <Badge type="tip" text="必要" vertical="middle" />                       | 列出所有可安装的版本                      |
| [bin/download](#bin-download) <Badge type="warning" text="推荐" vertical="middle" />                   | 下载指定版本的源代码或二进制文件            |
| [bin/install](#bin-install) <Badge type="tip" text="必要" vertical="middle" />                         | 安装指定版本                             |
| [bin/latest-stable](#bin-latest-stable) <Badge type="warning" text="推荐" vertical="middle" />         | 列出指定工具的最新稳定版本                 |
| [bin/help.overview](#bin-help.overview)                                                               | 输出插件及工具的通用描述                   |
| [bin/help.deps](#bin-help.deps)                                                                       | 输出按操作系统分类的依赖项列表              |
| [bin/help.config](#bin-help.config)                                                                   | 输出插件或工具的配置信息                   |
| [bin/help.links](#bin-help.links)                                                                     | 输出插件或工具的链接列表                   |
| [bin/list-bin-paths](#bin-list-bin-paths)                                                             | 列出包含二进制文件的目录的相对路径以创建垫片  |
| [bin/exec-env](#bin-exec-env)                                                                         | 为运行二进制文件准备环境                   |
| [bin/exec-path](#bin-exec-path)                                                                       | 输出工具某个版本的可执行路径                |
| [bin/uninstall](#bin-uninstall)                                                                       | 卸载工具的特定版本Uninstall               |
| [bin/list-legacy-filenames](#bin-list-legacy-filenames)                                               | 输出旧版本文件的文件名：`.ruby-version`    |
| [bin/parse-legacy-file](#bin-parse-legacy-file)                                                       | 用于解析旧版本文件的自定义解析器            |
| [bin/post-plugin-add](#bin-post-plugin-add)                                                           | 在插件添加后执行的钩子                    |
| [bin/post-plugin-update](#bin-post-plugin-update)                                                     | 插件更新后执行的钩子                      |
| [bin/pre-plugin-remove](#bin-pre-plugin-remove)                                                       | 插件删除前执行的钩子                      |

要查看哪些命令调用了哪些脚本，请参考每个脚本的详细文档。

## 环境变量概述

所有脚本中使用的环境变量完整列表。

| 环境变量                  | 描述                                            |
| :----------------------- |:-----------------------------------------------|
| `ASDF_INSTALL_TYPE`      | `version` 或 `ref`                             |
| `ASDF_INSTALL_VERSION`   | 完整版本号或 Git 引用，取决于 `ASDF_INSTALL_TYPE`  |
| `ASDF_INSTALL_PATH`      | 工具 _应_ 安装或 _已_ 安装的路径                   |
| `ASDF_CONCURRENCY`       | 编译源代码时使用的核心数。用于设置 `make -j`        |
| `ASDF_DOWNLOAD_PATH`     | `bin/download` 下载源代码或二进制文件的路径        |
| `ASDF_PLUGIN_PATH`       | 插件的安装路径                                   |
| `ASDF_PLUGIN_SOURCE_URL` | 插件的来源 URL                                  |
| `ASDF_PLUGIN_PREV_REF`   | 插件仓库的上一版本 `git-ref`                     |
| `ASDF_PLUGIN_POST_REF`   | 插件仓库的更新版本 `git-ref`                     |
| `ASDF_CMD_FILE`          | 解析为被引用的文件的完整路径                       |

::: tip 注意

**并非所有环境变量在所有脚本中都可以用。** 请查看下方每个脚本的文档，以了解其可用的环境变量。

:::

## 必要的脚本

### `bin/list-all` <Badge type="tip" text="必要" vertical="middle" />

**描述**

列出所有可安装的版本。

**输出格式**

必须打印一个以**空格分隔**的版本列表字符串。例如：

```txt
1.0.1 1.0.2 1.3.0 1.4
```

最新版本应放在最后。

asdf core 会将每个版本单独打印在单独的行上，可能导致部分版本超出屏幕范围。

**排序**

如果版本是从网站的发布页面获取的，建议保持提供的顺序，因为它们通常已经按正确顺序排列。如果版本顺序相反，通过 `tac` 管道处理应
能解决问题。

如果排序不可避免，`sort -V` 不可移植，因此我们建议：

- [使用 Git 的排序功能](https://github.com/asdf-vm/asdf-plugin-template/blob/main/template/lib/utils.bash)
  （需要 Git >= `v2.18.0`）
- [编写自定义排序方法](https://github.com/vic/asdf-idris/blob/master/bin/list-all#L6)
  （需要 `sed`、`sort` 和 `awk`）

**脚本可用的环境变量**

此脚本未提供任何环境变量。

**调用此脚本的命令**

- `asdf list all <name> [version]`
- `asdf list all nodejs`：列出此脚本返回的所有版本，每个版本占一行。
- `asdf list all nodejs 18`：列出此脚本返回的所有版本，每个版本占一行，并应用过滤器匹配以 `18` 开头的任何版本。

**asdf 核心调用签名**

未提供参数。

```bash
“${plugin_path}/bin/list-all”
```

---

### `bin/download` <Badge type="tip" text="必要" vertical="middle" />

**描述**

将特定版本的工具的源代码或二进制文件下载到指定位置。

**实现细节**

- 脚本必须将源代码或二进制文件下载到由 `ASDF_DOWNLOAD_PATH` 指定的目录中。
- 仅应将解压后的源代码或二进制文件放置在 `ASDF_DOWNLOAD_PATH` 目录中。
- 失败时，不应将任何文件放置在 `ASDF_DOWNLOAD_PATH` 中。
- 成功时应以 `0` 退出。
- 失败时应以非零状态退出。

**旧插件**

尽管此脚本被标记为所有插件的 _必需_，但对于在引入此脚本之前存在的“旧”插件，它是 _可选_ 的。

如果此脚本缺失，asdf 将假设 `bin/install` 脚本存在，并会下载**并**安装该版本。

所有插件必须包含此脚本，因为对旧插件的支持最终将被移除。

**脚本可用的环境变量**

- `ASDF_INSTALL_TYPE`：`version` 或 `ref`
- `ASDF_INSTALL_VERSION`：
  - 如果 `ASDF_INSTALL_TYPE=version`，则为完整版本号。
  - 如果 `ASDF_INSTALL_TYPE=ref`，则为 Git 引用（标签/提交/分支）。
- `ASDF_INSTALL_PATH`：工具 _已_ 安装或 _应_ 安装的路径。
- `ASDF_DOWNLOAD_PATH`：源代码或二进制文件的下载路径。

**调用此脚本的命令**

- `asdf install <tool> [version]]`
- `asdf install <tool> latest[:version]`
- `asdf install nodejs 18.0.0`：下载 Node.js 版本 `18.0.0` 的源代码或二进制文件，
  并将它们放置在 `ASDF_DOWNLOAD_PATH` 目录中。然后运行 `bin/install` 脚本。

**asdf 核心的调用签名**

未提供参数。

```bash
"${plugin_path}"/bin/download
```

---

### `bin/install` <Badge type="tip" text="必要" vertical="middle" />

**描述**

将特定版本的工具安装到指定位置。

**实现细节**

- 脚本应将指定版本安装到路径 `ASDF_INSTALL_PATH` 中。
- 默认情况下，`$ASDF_INSTALL_PATH/bin` 目录下的文件将自动垫片（shims）。此行为可通过可选的
[bin/list-bin-paths](#bin-list-bin-paths) 脚本进行自定义。
- 成功应以 `0` 退出。
- 失败应以非零状态退出。
- 为避免 TOCTOU（Time-of-Check-to-Time-of-Use）问题，确保脚本仅在工具的构建和安装被视为成功后，才将文件放置在 `ASDF_INSTALL_PATH` 中。

**旧插件**

如果 `bin/download` 脚本不存在，该脚本应下载并安装指定版本。

为了与 `0.7._` 之前和 `0.8._` 之后的 asdf 核心版本兼容，检查 `ASDF_DOWNLOAD_PATH` 环境变量的存在。如果设置了该变量，则假设 `bin/download` 脚本已下载该版本，否则在 `bin/install` 脚本中下载源代码。

**脚本可用的环境变量**

- `ASDF_INSTALL_TYPE`：`version` 或 `ref`
- `ASDF_INSTALL_VERSION`：
- 如果 `ASDF_INSTALL_TYPE=version`，则为完整版本号。
  - 如果 `ASDF_INSTALL_TYPE=ref`，则为 Git 引用（标签/提交/分支）。
- `ASDF_INSTALL_PATH`：工具 _已_ 安装或 _应_ 安装的路径。
- `ASDF_CONCURRENCY`：编译源代码时使用的核心数。可用于设置如 `make -j` 之类的标志。
- `ASDF_DOWNLOAD_PATH`：源代码或二进制文件的下载路径。

**调用此脚本的命令**

- `asdf install`
- `asdf install <tool>`
- `asdf install <tool> [version]]`
- `asdf install <tool> latest[:version]`
- `asdf install nodejs 18.0.0`：在
`ASDF_INSTALL_PATH` 目录中安装 Node.js 版本 `18.0.0`。

**asdf 核心的调用签名**

未提供参数。

```bash
"${plugin_path}"/bin/install
```

## 可选脚本

### `bin/latest-stable` <Badge type="warning" text="推荐" vertical="middle" />

**描述**

确定工具的最新稳定版本。如果不存在，asdf 核心将 `tail` `bin/list-all` 的输出，这可能是不希望看到的。

**实现细节**

- 脚本应将工具的最新稳定版本打印到标准输出。
- 不稳定版本或发布候选版本应被省略。
- 脚本的第一个参数提供了一个过滤查询。这应用于按版本号或工具提供商过滤输出。
  - 例如，来自 [ruby 插件](https://github.com/asdf-vm/asdf-ruby) 的 `asdf list all ruby` 输出列出了来自多个提供商的 Ruby 版本：`jruby`、`rbx` 和 `truffleruby` 等。用户提供的过滤器可由插件用于过滤语义化版本和/或提供商。
    ```
    > asdf latest ruby
    3.2.2
    > asdf latest ruby 2
    2.7.8
    > asdf latest ruby truffleruby
    truffleruby+graalvm-22.3.1
    ```
- 成功应以 `0` 退出。
- 失败应以非零状态退出。

**脚本可用的环境变量**

- `ASDF_INSTALL_TYPE`：`version` 或 `ref`
- `ASDF_INSTALL_VERSION`：
  - 若 `ASDF_INSTALL_TYPE=version`，则为完整版本号。
  - 若 `ASDF_INSTALL_TYPE=ref`，则为 Git 引用（标签/提交/分支）。
- `ASDF_INSTALL_PATH`：工具 _已_ 安装或 _应_ 安装的路径。

**调用此脚本的命令**

- `asdf set <tool> latest`：将工具的版本设置为该工具的最新稳定版本。
- `asdf install <tool> latest`：安装工具的最新版本。
- `asdf latest <tool> [<version>]`：根据可选过滤器输出工具的最新版本。
- `asdf latest --all`：输出由 asdf 管理的所有工具的最新版本及其安装状态。

**asdf 核心的调用签名**

该脚本应接受一个参数，即过滤查询。

```bash
"${plugin_path}"/bin/latest-stable "$query"
```

---

### `bin/help.overview`

**描述**

输出关于插件和所管理工具的通用描述。

**实现细节**

- 该脚本是显示插件帮助输出所必需的。
- 不得打印任何标题，因为 asdf 核心会打印标题。
- 输出可以是自由格式文本，但理想情况下应仅包含一个简短段落。
- 不得输出已在 asdf-vm 核心文档中涵盖的任何信息。
- 应根据所安装工具的操作系统和版本进行定制（可选设置环境变量 `ASDF_INSTALL_VERSION` 和 `ASDF_INSTALL_TYPE`）。
- 成功应以 `0` 退出。
- 失败应以非零状态退出。

**脚本可用的环境变量**

- `ASDF_INSTALL_TYPE`：`version` 或 `ref`
- `ASDF_INSTALL_VERSION`：
  - 若 `ASDF_INSTALL_TYPE=version`，则为完整版本号。
  - 若 `ASDF_INSTALL_TYPE=ref`，则为 Git 引用（标签/提交/分支）。
- `ASDF_INSTALL_PATH`：工具 _已_ 安装或 _应_ 安装的路径。

**调用此脚本的命令**

- `asdf help <name> [<version>]`：输出插件和工具的文档

**asdf 核心的调用签名**

```bash
"${plugin_path}"/bin/help.overview
```

---

### `bin/help.deps`

**描述**

输出针对操作系统定制的依赖项列表。每个依赖项占一行。

```bash
git
curl
sed
```

**实现细节**

- 该脚本需要 `bin/help.overview` 才能被视为有效输出。
- 应根据操作系统和要安装的工具版本进行定制（可选设置环境变量 `ASDF_INSTALL_VERSION` 和 `ASDF_INSTALL_TYPE`）。
- 成功应以 `0` 退出。
- 失败应以非零状态退出。

**脚本可用的环境变量**

- `ASDF_INSTALL_TYPE`：`version` 或 `ref`
- `ASDF_INSTALL_VERSION`：
  - 若 `ASDF_INSTALL_TYPE=version`，则为完整版本号。
  - 若 `ASDF_INSTALL_TYPE=ref`，则为 Git 引用（标签/提交/分支）。
- `ASDF_INSTALL_PATH`：工具 _已_ 安装或 _应_ 安装的路径。

**调用此脚本的命令**

- `asdf help <name> [<version>]`：输出插件和工具的文档

**asdf 核心的调用签名**

```bash
"${plugin_path}"/bin/help.deps
```

---

### `bin/help.config`

**描述**

输出插件和工具所需的任何必要或可选配置。例如，描述安装或编译工具所需的任何环境变量或其他标志。

**实现细节**

- 该脚本需要 `bin/help.overview` 才能被视为有效输出。
- 输出可以是自由格式文本。
- 应根据所安装工具的操作系统和版本进行定制（可选设置环境变量 `ASDF_INSTALL_VERSION` 和 `ASDF_INSTALL_TYPE`）。
- 成功应以 `0` 退出。
- 失败应以非零状态退出。

**脚本可用的环境变量**

- `ASDF_INSTALL_TYPE`：`version` 或 `ref`
- `ASDF_INSTALL_VERSION`：
  - 若 `ASDF_INSTALL_TYPE=version`，则为完整版本号。
  - 若 `ASDF_INSTALL_TYPE=ref`，则为 Git 引用（标签/提交/分支）。
- `ASDF_INSTALL_PATH`：工具 _已_ 安装或 _应_ 安装的路径。

**调用此脚本的命令**

- `asdf help <name> [<version>]`：输出插件和工具的文档

**asdf 核心的调用签名**

```bash
"${plugin_path}"/bin/help.config
```

---

### `bin/help.links`

**描述**

输出与插件和工具相关的链接列表。每个链接占一行。

```bash
Git Repository:	https://github.com/vlang/v
Documentation:	https://vlang.io
```

**实现细节**

- 该脚本需要 `bin/help.overview` 才能被视为有效输出。
- 每行一个链接。
- 格式必须为以下之一：
  - `<标题>: <链接>`
  - 或仅 `<链接>`
- 应根据所安装工具的操作系统和版本进行调整（可选设置环境变量 `ASDF_INSTALL_VERSION` 和 `ASDF_INSTALL_TYPE`）。
- 成功应以 `0` 退出。
- 失败应以非零状态退出。

**脚本可用的环境变量**

- `ASDF_INSTALL_TYPE`：`version` 或 `ref`
- `ASDF_INSTALL_VERSION`：
  - 若 `ASDF_INSTALL_TYPE=version`，则为完整版本号。
  - 若 `ASDF_INSTALL_TYPE=ref`，则为 Git 引用（标签/提交/分支）。
- `ASDF_INSTALL_PATH`：工具 _已_ 安装或 _应_ 安装的路径。

**调用此脚本的命令**

- `asdf help <name> [<version>]`：输出插件和工具的文档

**asdf 核心的调用签名**

```bash
"${plugin_path}"/bin/help.links
```

---

### `bin/list-bin-paths`

**描述**

列出包含指定版本工具可执行文件的目录。

**实现细节**

- 如果该脚本不存在，asdf 将搜索 `“${ASDF_INSTALL_PATH}”/bin` 目录中的二进制文件并为其创建垫片。
- 输出包含可执行文件的路径列表，路径以空格分隔。
- 路径必须相对于 `ASDF_INSTALL_PATH`。示例输出如下：

```bash
bin tools veggies
```

这将指示 asdf 为以下目录中的文件创建垫片：
- `“${ASDF_INSTALL_PATH}”/bin`
- `“${ASDF_INSTALL_PATH}”/tools`
- `“${ASDF_INSTALL_PATH}”/veggies`

**脚本可用的环境变量**

- `ASDF_INSTALL_TYPE`：`version` 或 `ref`
- `ASDF_INSTALL_VERSION`：
- 若 `ASDF_INSTALL_TYPE=version`，则为完整版本号。
  - 如果 `ASDF_INSTALL_TYPE=ref`，则为 Git 引用（标签/提交/分支）。
- `ASDF_INSTALL_PATH`：工具 _已_ 安装或 _应_ 安装的路径。

**调用此脚本的命令**

- `asdf install <tool> [version]`：初始创建二进制文件的垫片。
- `asdf reshim <tool> <version>`：重新创建二进制文件的垫片。

**asdf 核心的调用签名**

```bash
"${plugin_path}/bin/list-bin-paths"
```

---

### `bin/exec-env`

**描述**

在执行工具二进制文件的垫片之前，请先准备好环境。

**脚本可用的环境变量**

- `ASDF_INSTALL_TYPE`: `version` 或 `ref`
- `ASDF_INSTALL_VERSION`:
- 如果 `ASDF_INSTALL_TYPE=version`，则为完整版本号。
  - 如果 `ASDF_INSTALL_TYPE=ref`，则为 Git 引用（标签/提交/分支）。
- `ASDF_INSTALL_PATH`：工具 _已_ 安装或 _应_ 安装的路径。

**调用此脚本的命令**

- `asdf which <command>`：显示可执行文件的路径
- `asdf exec <command> [args...]`：执行当前版本的命令垫片
- `asdf env <command> [util]`：在命令垫片执行所用的环境中运行工具（默认：`env`）。

**asdf 核心的调用签名**

```bash
"${plugin_path}/bin/exec-env"
```

---

### `bin/exec-path`

获取指定版本工具的可执行文件路径。必须输出一个
包含相对可执行文件路径的字符串。这允许插件
在满足条件时覆盖 Shim 指定的可执行文件路径，否则返回
Shim 指定的默认路径。

**描述**

获取指定版本工具的可执行文件路径。

**实现细节**

- 必须输出包含相对可执行文件路径的字符串。
- 条件性地覆盖shim指定的可执行文件路径，否则返回shim指定的默认路径。

```shell
Usage:
  plugin/bin/exec-path <install-path> <command> <executable-path>

Example Call:
  ~/.asdf/plugins/foo/bin/exec-path "~/.asdf/installs/foo/1.0" "foo" "bin/foo"

Output:
  bin/foox
```

**脚本可用的环境变量**

- `ASDF_INSTALL_TYPE`: `version` 或 `ref`
- `ASDF_INSTALL_VERSION`:
- 若 `ASDF_INSTALL_TYPE=version`，则为完整版本号。
  - 如果 `ASDF_INSTALL_TYPE=ref`，则为 Git 引用（标签/提交/分支）。
- `ASDF_INSTALL_PATH`：工具 _已_ 安装或 _应_ 安装的路径。

**调用此脚本的命令**

- `asdf which <command>`：显示可执行文件的路径
- `asdf exec <command> [args...]`：执行当前版本的命令垫片
- `asdf env <command> [util]`：在命令垫片执行所用的环境中运行工具（默认：`env`）。

**asdf 核心的调用签名**

```bash
"${plugin_path}/bin/exec-path" "$install_path" "$cmd" "$relative_path"
```

---

### `bin/uninstall`

**描述**

卸载提供的工具版本。

**输出格式**

输出应根据用户情况发送到 `stdout` 或 `stderr`。后续核心执行不会读取任何输出。

**脚本可用的环境变量**

此脚本未提供任何环境变量。

**调用此脚本的命令**

- `asdf list all <name> <version>`
- `asdf uninstall nodejs 18.15.0`：卸载 nodejs 的版本`18.15.0`，并移除所有垫片，包括通过`npm i -g`全局安装的垫片

**asdf 核心的调用签名**

不提供参数。

```bash
"${plugin_path}/bin/uninstall"
```

---

### `bin/list-legacy-filenames`

**描述**

列出用于确定指定工具版本的旧配置文件名。

**实现细节**

- 输出以空格分隔的文件名列表。
```bash
  .ruby-version .rvmrc
  ```
- 仅适用于在 `“${HOME}”/.asdfrc` 中启用了 `legacy_version_file` 选项的用户。

**脚本可用的环境变量**

- `ASDF_INSTALL_TYPE`：`version` 或 `ref`
- `ASDF_INSTALL_VERSION`：
  - 若 `ASDF_INSTALL_TYPE=version`，则为完整版本号。
  - 若 `ASDF_INSTALL_TYPE=ref`，则为 Git 引用（标签/提交/分支）。
- `ASDF_INSTALL_PATH`：工具 _已_ 安装或 _应_ 安装的路径。

**调用此脚本的命令**

任何读取工具版本的命令。

**asdf 核心的调用签名**

未提供参数。

```bash
"${plugin_path}/bin/list-legacy-filenames"
```

---

### `bin/parse-legacy-file`

**描述**

解析由 asdf 找到的旧文件以确定工具的版本。适用于从 JavaScript 的 `package.json` 或 Go 的 `go.mod` 等文件中提取版本号。

**实现细节**

- 如果不存在，asdf 将简单地使用 `cat` 命令读取旧文件以确定版本。
- 该过程应具有 **确定性**，并始终返回完全相同的版本：
  - 当解析同一旧文件时。
  - 无论机器上安装了什么，或旧版本是否有效或完整。某些旧文件格式可能不适用。
- 输出包含版本号的单行内容：
  ```bash
  1.2.3
  ```

**脚本可用的环境变量**

在调用此脚本之前，没有专门设置的环境变量。

**调用此脚本的命令**

任何读取工具版本的命令。

**asdf 核心的调用签名**

该脚本应接受一个参数，即读取其内容的旧版文件的路径。

```bash
"${plugin_path}/bin/parse-legacy-file" "$file_path"
```

---

### `bin/post-plugin-add`

**描述**

在使用 `asdf plugin add <tool>` 命令将插件添加到 asdf 之后，执行此回调脚本。

参见相关命令钩子：

- `pre_asdf_plugin_add`
- `pre_asdf_plugin_add_${plugin_name}`
- `post_asdf_plugin_add`
- `post_asdf_plugin_add_${plugin_name}`

**脚本可用的环境变量**

- `ASDF_PLUGIN_PATH`：插件的安装路径。
- `ASDF_PLUGIN_SOURCE_URL`：插件来源 URL。可以是本地目录路径。

**asdf 核心的调用签名**

未提供参数。

```bash
"${plugin_path}/bin/post-plugin-add"
```

---

### `bin/post-plugin-update`

**描述**

在 asdf 使用 `asdf plugin update <tool> [<git-ref>]` 命令下载 _update_ 插件**之后**，执行此回调脚本。

参见相关命令钩子：

- `pre_asdf_plugin_update`
- `pre_asdf_plugin_update_${plugin_name}`
- `post_asdf_plugin_update`
- `post_asdf_plugin_update_${plugin_name}`

**脚本可用的环境变量**

- `ASDF_PLUGIN_PATH`：插件的安装路径。
- `ASDF_PLUGIN_PREV_REF`：插件的上一版本 Git 引用。
- `ASDF_PLUGIN_POST_REF`：插件的更新后 Git 引用。

**asdf 核心的调用签名**

未提供参数。

```bash
"${plugin_path}/bin/post-plugin-update"
```

---

### `bin/pre-plugin-remove`

**描述**

在使用 `asdf plugin remove <工具>` 命令移除插件**之前**，执行此回调脚本。

参见相关命令钩子：

- `pre_asdf_plugin_remove`
- `pre_asdf_plugin_remove_${plugin_name}`
- `post_asdf_plugin_remove`
- `post_asdf_plugin_remove_${plugin_name}`

**脚本可用的环境变量**

- `ASDF_PLUGIN_PATH`：插件的安装路径。

**asdf 核心的调用签名**

未提供参数。

```bash
"${plugin_path}/bin/pre-plugin-remove"
```

<!-- TODO: document command hooks -->
<!-- ## Command Hooks -->

## asdf 命令行的扩展命令 <Badge type="danger" text="进阶" vertical="middle" />

插件可以通过提供 `lib/commands/command*.bash` 脚本或者可执行程序来定义新的 asdf 命令，这些脚本或可执行程序将使用插件名称作为 asdf 命令的子命令进行调用。

例如，假设一个 `foo` 插件有以下文件：

```shell
foo/
  lib/commands/
    command.bash
    command-bat.bash
    command-bat-man.bash
    command-help.bash
```

用户现在可以执行：

```shell
$ asdf foo         # 等同于运行 `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash`
$ asdf foo bar     # 等同于运行 `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash bar`
$ asdf foo help    # 等同于运行 `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-help.bash`
$ asdf foo bat man # 等同于运行 `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat-man.bash`
$ asdf foo bat baz # 等同于运行 `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat.bash baz`
```

插件作者可以使用此功能来提供与其工具相关的实用命令，或者可以创建 asdf 本身的新命令扩展的插件。

如果可执行位被设置，脚本将被执行，替换 asdf 的执行。

如果可执行位未被设置，asdf 将把脚本作为 Bash 脚本加载。

`$ASDF_CMD_FILE` 解析为正在加载的文件的完整路径。

这个功能的一个很好的例子是像 [`haxe`](https://github.com/asdf-community/asdf-haxe) 这样的插件。
它提供了 `asdf haxe neko-dylibs-link` 来修复 haxe 可执行文件期望找到相对于可执行目录的动态链接库的问题。

如果你的插件提供了 asdf 扩展命令，请务必在插件的 README 文件中提及。

## 自定义垫片模板 <Badge type="danger" text="进阶" vertical="middle" />

::: warning 警告

请仅在**真的需要**时才使用此功能

:::

asdf 允许自定义垫片模板。对于名为 `foo` 的可执行程序，如果有一个 `shims/foo` 的文件在插件中，那么 asdf 将复制这个文件替代使用标准垫片模板。

**这必须谨慎使用。**

据 asdf 核心团队所知，此功能仅在官方 [Elixir 插件](https://github.com/asdf-vm/asdf-elixir) 中使用。这是
因为可执行文件不仅被视为可执行文件，还被视为 Elixir 文件。这使得无法使用标准的 Bash 垫片。

## 测试

`asdf` 包含 `plugin-test` 命令用于测试插件：

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]
```

- `<plugin_name>` 和 `<plugin_url>` 是必需的
- 如果指定了可选参数 `[--asdf-tool-version <version>]`，工具将以该特定版本进行安装。默认值为 `asdf latest <plugin_name>`
- 如果指定了可选参数 `[--asdf-plugin-gitref <git_ref>]`，插件本身将从指定的提交/分支/标签检出。这在测试插件的 CI 中的拉取请求时非常有用。默认使用插件仓库的默认分支。
- 可选参数 `[test_command...]` 是用于验证已安装工具是否正常工作的命令。通常为 `<tool> --version` 或
  `<tool> --help`。例如，要测试 NodeJS 插件，我们可以运行
  ```shell
  # asdf plugin test <plugin_name>  <plugin_url>                               [test_command]
    asdf plugin test nodejs         https://github.com/asdf-vm/asdf-nodejs.git node --version
  ```

::: tip 注意

我们强烈建议你在 CI 环境中测试你的插件，并确保它可以在 Linux 和 OSX 上运行。

:::

### GitHub Action

[asdf-vm/actions](https://github.com/asdf-vm/actions) 仓库提供了一个 GitHub Action，用于测试托管在 GitHub 上的插件。一个示例 `.github/workflows/test.yaml` Actions 工作流如下：

```yaml
name: Test
on:
  push:
    branches:
      - main
  pull_request:

jobs:
  plugin_test:
    name: asdf plugin test
    strategy:
      matrix:
        os:
          - ubuntu-latest
          - macos-latest
    runs-on: ${{ matrix.os }}
    steps:
      - name: asdf_plugin_test
        uses: asdf-vm/actions/plugin-test@v2
        with:
          command: "<MY_TOOL> --version"
```

#### TravisCI 配置示例

这是一个 `.travis.yml` 示例文件，请根据你的需要进行自定义：

```yaml
language: c
script: asdf plugin test <MY_TOOL> $TRAVIS_BUILD_DIR '<MY_TOOL> --version'
before_script:
  - git clone https://github.com/asdf-vm/asdf.git asdf
  - . asdf/asdf.sh
os:
  - linux
  - osx
```

::: tip 注意

当使用其他 CI 时，可能需要传递插件位置的相对路径：

```shell
asdf plugin test <tool_name> <path> '<tool_command> --version'
```

:::

## API 频率限制

如果某个命令依赖于访问外部 API，例如 `bin/list-all` 或 `bin/latest-stable`，那么在自动化测试过程中可能会遇到频率限制问题。为了解决这个问题，请确保存在一条代码路径，通过环境变量提供认证令牌。例如：

```shell
cmd="curl -s"
if [ -n "$GITHUB_API_TOKEN" ]; then
 cmd="$cmd -H 'Authorization: token $GITHUB_API_TOKEN'"
fi

cmd="$cmd $releases_path"
```

### `GITHUB_API_TOKEN`

要使用 `GITHUB_API_TOKEN`，请创建一个 [新个人令牌](https://github.com/settings/tokens/new)，仅授予 `public_repo` 访问权限。

然后将此令牌添加到 CI 管道的环境变量中。

::: tip 注意

**切勿**将认证令牌发布到代码仓库中

:::

## 插件缩写索引

::: tip 注意

插件的推荐安装方法是通过直接 URL 安装：

```shell
# asdf plugin add <name> <git_url>
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs
```

:::

如果未提供 `git_url`，asdf 将使用 [缩写索引仓库](https://github.com/asdf-vm/asdf-plugins) 来确定要使用的确切 `git_url`。

您可以通过遵循该仓库中的 [缩写索引](https://github.com/asdf-vm/asdf-plugins) 中的说明，将你的插件添加到缩写索引中。

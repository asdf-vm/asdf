# 配置

`asdf` 配置既包括可共享的 `.tool-versions` 文件，也包括用户特定的自定义 `.asdfrc` 和环境变量。

## `.tool-versions`

无论何时 `.tool-versions` 出现在目录中，它所声明的工具版本将会被用于该目录和任意子目录。

`.tool-versions` 文件示例如下所示：

```
ruby 2.5.3
nodejs 10.15.0
```

你也可以包含注释在里面：

```
ruby 2.5.3 # 这是一个注释
# 这是另一个注释
nodejs 10.15.0
```

版本号可以有如下格式：

- `10.15.0` - 实际的版本号。支持下载二进制文件的插件将会下载二进制文件。
- `ref:v1.0.2-a` 或者 `ref:39cb398vb39` - 指定标签/提交/分支从 github 下载并编译。
- `path:~/src/elixir` - 要使用的工具的自定义编译版本的路径。这种方式供语言开发者等使用。
- `system` - 此关键字会导致 asdf 传递系统上未由 asdf 管理的工具版本。

::: tip 提示

多版本可以通过空格将它们分隔开来。比如，使用 Python `3.7.2` 回退到 Python `2.7.15` 最后回退到 `system` Python，可以将以下行的内容添加到 `.tool-versions` 文件中。

```
python 3.7.2 2.7.15 system
```

:::

为了安装 `.tool-versions` 文件中定义的所有工具，在包含 `.tool-versions` 文件的目录中不带其他参数执行 `asdf install` 命令。

为了安装 `.tool-versions` 文件中定义的某个工具，在包含 `.tool-versions` 文件的目录中运行 `asdf install <name>` 命令。这个工具将会安装 `.tool-versions` 文件所指定的版本。

可以直接编辑这个文件或者使用 `asdf local` （或者 `asdf global`）来更新工具版本。

## `.asdfrc`

`.asdfrc` 文件定义了用户机器的特定配置。

`$HOME/.asdfrc` 是 asdf 使用的默认位置。这可以通过 [环境变量 `ASDF_CONFIG_FILE`](#asdf-config-file) 进行配置。

以下文件展示了所需的格式及其默认值：

```txt
legacy_version_file = no
use_release_candidates = no
always_keep_download = no
plugin_repository_last_check_duration = 60
disable_plugin_short_name_repository = no
concurrency = auto
```

### `legacy_version_file`

插件 **支持** 读取其他版本管理器使用的版本文件，比如，Ruby 的 `rbenv` 的 `.ruby-version` 文件。

| 选项                                                    | 描述                                                     |
| :------------------------------------------------------ | :------------------------------------------------------- |
| `no` <Badge type="tip" text="默认" vertical="middle" /> | 从 `.tool-versions` 文件读取版本                         |
| `yes`                                                   | 如果可行的话，从传统版本文件读取版本（`.ruby-versions`） |

### `always_keep_download`

配置 `asdf install` 命令以保留或删除下载的源代码或二进制文件。

| 选项                                                    | 描述                               |
| :------------------------------------------------------ | :--------------------------------- |
| `no` <Badge type="tip" text="默认" vertical="middle" /> | 在成功安装后删除源代码或二进制文件 |
| `yes`                                                   | 在安装后保留源代码或二进制文件 |

### `plugin_repository_last_check_duration`

配置自上次 asdf 插件存储库同步到下一次存储库同步的持续时间。命令 `asdf plugin add <name>` 或者 `asdf plugin list all` 将会触发持续时间的检查，如果持续时间已过，则进行同步。

| 选项                                                                                          | 描述                                               |
| :-------------------------------------------------------------------------------------------- | :------------------------------------------------- |
| 从 `1` 到 `999999999` 的数字 <br/> <Badge type="tip" text="默认" vertical="middle" /> 为 `60` | 如果已过自上次同步的持续时间，触发器事件发生时同步 |
| `0`                                                                                           | 每个触发器事件发生时同步                           |
| `never`                                                                                       | 从不同步                                           |

同步事件在执行以下命令时发生：

- `asdf plugin add <name>`
- `asdf plugin list all`

`asdf plugin add <name> <git-url>` 不会触发插件同步。

::: warning 注意

将值设置为 `never` 并不会阻止插件仓库的初始同步，如需实现此行为，请查看 `disable_plugin_short_name_repository` 了解更多。

:::

### `disable_plugin_short_name_repository`

禁用 asdf 插件的缩写仓库同步功能。如果缩写仓库被禁用，同步事件将提前退出。

| 选项                                                        | 描述                                |
| :--------------------------------------------------------- | :--------------------------------- |
| `no` <Badge type="tip" text="default" vertical="middle" /> | 在同步事件发生时克隆或更新 asdf 插件仓库 |
| `yes`                                                      | 禁用插件缩写仓库                      |

同步事件在执行以下命令时发生：

- `asdf plugin add <name>`
- `asdf plugin list all`

`asdf plugin add <name> <git-url>` 不会触发插件同步。

::: warning 注意

禁用插件缩写仓库不会删除该仓库，如果它已经同步过。使用 `rm --recursive --trash $ASDF_DATA_DIR/repository` 才可以删除插件仓库。

禁用插件缩写仓库不会删除从该源之前安装的插件。可使用 `asdf plugin remove <name>` 命令删除插件。删除插件将移除该管理工具所有已安装版本。

:::

### `concurrency`

编译时使用的默认核心数。

| 选项 | 描述                                                                                        |
| :------ | :--------------------------------------------------------------------------------------------------- |
| integer | 编译源代码时使用的核心数 code                                                |
| `auto`  | 使用 `nproc` 命令计算核心数量，然后使用 `sysctl hw.ncpu` 命令，接着查看 `/proc/cpuinfo` 文件，如果无法获取则默认使用 `1`。 |

注意：如果设置了环境变量 `ASDF_CONCURRENCY`，则该变量具有优先级。

### 插件钩子

可以执行自定义代码：

- 在插件安装、重新加载、更新或卸载之前或之后
- 在执行插件命令之前或之后

比如，如果安装了一个名为 `foo` 的插件并提供了 `bar` 可执行文件，则可以使用以下钩子在执行插件命令之前先执行自定义代码：

```text
pre_foo_bar = echo Executing with args: $@
```

支持以下模式：

- `pre_<plugin_name>_<command>`
- `pre_asdf_download_<plugin_name>`
- `{pre,post}_asdf_{install,reshim,uninstall}_<plugin_name>`
  - `$1`: 完整版本
- `{pre,post}_asdf_plugin_{add,update,remove,reshim}`
  - `$1`: 插件名称
- `{pre,post}_asdf_plugin_{add,update,remove}_<plugin_name>`

请查看 [创建插件](../plugins/create.md) 了解在哪些命令执行之前或之后会运行哪些命令钩子。

## 环境变量

设置环境变量会因系统和 Shell 的不同而有所差异。默认位置取决于安装位置和方法（Git 克隆、Homebrew、AUR）。

环境变量通常应在加载 `asdf.sh`/`asdf.fish` 等文件之前设置。对于 Elvish，应在 `use asdf` 之前设置。

以下内容描述了在 Bash Shell 中的使用方法。

### `ASDF_CONFIG_FILE`

`.asdfrc` 配置文件的路径。可以设置为任何位置。必须是绝对路径。

- 如果未设置：将使用 `$HOME/.asdfrc`。
- 使用方法：`export ASDF_CONFIG_FILE=/home/john_doe/.config/asdf/.asdfrc`

### `ASDF_TOOL_VERSIONS_FILENAME`

用于存储工具名称和版本的文件名。可以是任何合法的文件名。通常不建议设置这个值，除非你希望忽略 `.tool-versions` 文件。

- 如果未设置：将使用 `.tool-versions`。
- 使用方法：`export ASDF_TOOL_VERSIONS_FILENAME=tool_versions`

### `ASDF_DIR`

`asdf` 核心脚本的位置。可以设置为任何位置，必须是绝对路径。

- 如果未设置，将使用 `bin/asdf` 可执行文件的父目录。
- 使用方法：`export ASDF_DIR=/home/john_doe/.config/asdf`

### `ASDF_DATA_DIR`

`asdf` 安装插件、垫片和工具版本的位置，可以设置为任何位置，必须是绝对路径。

- 如果未设置：将使用 `$HOME/.asdf` 如果存在，或者 `ASDF_DIR` 的值。
- 使用方法：`export ASDF_DATA_DIR=/home/john_doe/.asdf`

### `ASDF_CONCURRENCY`

编译源代码时使用的 CPU 核心数。如果设置了这个值，它将优先于 asdf 配置中的 `concurrency` 值。

- 如果未设置：将使用 asdf 配置中的 `concurrency` 值。
- 使用方法：`export ASDF_CONCURRENCY=32`

## 全配置样例

按照以下简单的 asdf 配置：

- 使用 Bash Shell
- 安装位置为 `$HOME/.asdf`
- 通过 Git 安装
- **未**设置任何环境变量
- **没有**自定义的 `.asdfrc` 文件

将会产生以下结果：

| 配置                                   | 值               | 如何计算                                                                                                               |
| :------------------------------------ | :--------------- | :-------------------------------------------------------------------------------------------------------------------- |
| 配置文件位置                            | `$HOME/.asdfrc`  | `ASDF_CONFIG_FILE` 是空的，所以请使用 `$HOME/.asdfrc`                                                                    |
| 默认工具版本声明文件名                    | `.tool-versions` | `ASDF_TOOL_VERSIONS_FILENAME` 是空的，所以请使用 `.tool-versions`                                                       |
| asdf 目录                              | `$HOME/.asdf`    | `ASDF_DIR` 是空的，所以请使用 `bin/asdf` 的父目录                                                                         |
| asdf 数据目录                          | `$HOME/.asdf`     | `ASDF_DATA_DIR` 是空的，所以请使用 `$HOME/.asdf` 因为 `$HOME` 存在                                                        |
| concurrency                           | `auto`           | `ASDF_CONCURRENCY` 是空的，所以依赖于 [默认配置](https://github.com/asdf-vm/asdf/blob/master/defaults) 的 `concurrency` 值 |
| legacy_version_file                   | `no`             | 没有自定义 `.asdfrc`，所以请使用 [默认配置](https://github.com/asdf-vm/asdf/blob/master/defaults)                          |
| use_release_candidates                | `no`             | 没有自定义 `.asdfrc`，所以请使用 [默认配置](https://github.com/asdf-vm/asdf/blob/master/defaults)                          |
| always_keep_download                  | `no`             | 没有自定义 `.asdfrc`，所以请使用 [默认配置](https://github.com/asdf-vm/asdf/blob/master/defaults)                          |
| plugin_repository_last_check_duration | `60`             | 没有自定义 `.asdfrc`，所以请使用 [默认配置](https://github.com/asdf-vm/asdf/blob/master/defaults)                          |
| disable_plugin_short_name_repository  | `no`             | 没有自定义 `.asdfrc`，所以请使用 [默认配置](https://github.com/asdf-vm/asdf/blob/master/defaults)                          |

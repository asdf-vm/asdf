# 配置

`asdf` 配置既包括可共享的 `.tool-versions` 文件，也包括用户特定的自定义 `.asdfrc` 和环境变量。

## `.tool-versions`

无论何时 `.tool-versions` 出现在目录中，它所声明的工具版本将会被用于该目录和任意子目录。

::: warning 注意
全局默认配置将设置在文件`$HOME/.tool-versions` 中
:::

一个 `.tool-versions` 文件示例如下所示：

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

## `$HOME/.asdfrc`

给你的家目录添加一个 `.asdfrc` 文件然后 asdf 将会使用这个文件所指定的配置。下面的文件展示了所需的格式，其中包含用于演示的默认值：

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

### `use_release_candidates`

配置 `asdf update` 命令以升级到最新的候选版本，而不是最新的语义版本。

| 选项                                                    | 描述           |
| :------------------------------------------------------ | :------------- |
| `no` <Badge type="tip" text="默认" vertical="middle" /> | 语义版本被使用 |
| `yes`                                                   | 候选版本被使用 |

### `always_keep_download`

配置 `asdf install` 命令以保留或删除下载的源代码或二进制文件。

| 选项                                                    | 描述                               |
| :------------------------------------------------------ | :--------------------------------- |
| `no` <Badge type="tip" text="默认" vertical="middle" /> | 在成功安装后删除源代码或二进制文件 |
| `yes`                                                   | 在成功安装后保留源代码或二进制文件 |

### `plugin_repository_last_check_duration`

配置自上次 asdf 插件存储库同步到下一次存储库同步的持续时间。命令 `asdf plugin add <name>` 或者 `asdf plugin list all` 将会触发持续时间的检查，如果持续时间已过，则进行同步。

| 选项                                                                                          | 描述                                               |
| :-------------------------------------------------------------------------------------------- | :------------------------------------------------- |
| 从 `1` 到 `999999999` 的数字 <br/> <Badge type="tip" text="默认" vertical="middle" /> 为 `60` | 如果已过自上次同步的持续时间，触发器事件发生时同步 |
| `0`                                                                                           | 每个触发器事件发生时同步                           |
| `never`                                                                                       | 从不同步                                           |

## 环境变量

- `ASDF_CONFIG_FILE` - 如上所述默认为 `~/.asdfrc` 文件。可以被设置在任何位置。
- `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME` - 存储工具名称和版本的文件名。默认为 `.tool-versions`。可以是任何有效的文件名。通常，除非你知道你希望 asdf 忽略 `.tool-versions` 文件，否则不应该覆盖默认值。
- `ASDF_DIR` - 默认为 `~/.asdf` - `asdf` 脚本的位置。如果你把 `asdf` 安装到了其他目录，请设置该变量到那个目录。比如，如果通过 AUR 进行安装，则应设置该变量为 `/opt/asdf-vm`。
- `ASDF_DATA_DIR` - 默认为 `~/.asdf` - `asdf` 安装插件、垫片和安装器的位置。可以被设置在上一节提到的生效 `asdf.sh` 或者 `asdf.fish` 之间的任何位置。对于 Elvish，这可以设置在 `use asdf` 上面。

## 内部配置

用户不必担心本节，因为它描述了对包管理器和集成者有用的 `asdf` 的内部配置。

- `$ASDF_DIR/asdf_updates_disabled`：当此文件存在时（内容无关），通过 `asdf update` 命令进行的更新 将会被禁用。像 Pacman 或者 Homebrew 等包管理器使用它来确保个性化安装的正确的更新方法。

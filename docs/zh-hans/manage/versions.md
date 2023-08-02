# 版本

## 安装版本

```shell
asdf install <name> <version>
# asdf install erlang 17.3
```

如果一个插件支持从源代码下载和编译，你可以指定 `ref:foo`，其中 `foo` 是特定的分支、标签或者提交。卸载该版本时，你也需要使用相同的名称和引用。

## 安装最新稳定版本

```shell
asdf install <name> latest
# asdf install erlang latest
```

安装给定字符串开头的最新稳定版本。

```shell
asdf install <name> latest:<version>
# asdf install erlang latest:17
```

## 列举已安装版本

```shell
asdf list <name>
# asdf list erlang
```

筛选出以给定字符串开头的版本。

```shell
asdf list <name> <version>
# asdf list erlang 17
```

## 列举所有可用版本

```shell
asdf list all <name>
# asdf list all erlang
```

筛选出以给定字符串开头的版本。

```shell
asdf list all <name> <version>
# asdf list all erlang 17
```

## 显示最新稳定版本

```shell
asdf latest <name>
# asdf latest erlang
```

显示以给定字符串开头的最新稳定版本。

```shell
asdf latest <name> <version>
# asdf latest erlang 17
```

## 设置当前版本

```shell
asdf global <name> <version> [<version>...]
asdf shell <name> <version> [<version>...]
asdf local <name> <version> [<version>...]
# asdf global elixir 1.2.4

asdf global <name> latest[:<version>]
asdf local <name> latest[:<version>]
# asdf global elixir latest
```

`global` 将版本写到 `$HOME/.tool-versions` 文件中。

`shell` 仅为当前 shell 会话将版本设置为一个名为 `ASDF_${LANG}_VERSION` 的环境变量。

`local` 将版本写到 `$PWD/.tool-versions` 文件中，如果有需要也会创建此文件。

请查看 [配置部分](/zh-hans/manage/configuration.md) 的 `.tool-versions` 文件了解更多详情。

:::warning 可选
如果你只是想为当前 shell 会话或者在特定工具版本下执行一条命令，你可以设置一个类似 `ASDF_${TOOL}_VERSION` 的环境变量。
:::

下面的示例在版本为 `1.4.0` 的 Elixir 项目上运行测试。
版本格式与 `.tool-versions` 文件支持的版本格式相同。

```shell
ASDF_ELIXIR_VERSION=1.4.0 mix test
```

## 回退到系统版本

要使用工具 `<name>` 的系统版本而非 asdf 管理版本，你可以将工具的版本设置为 `system`。

使用 `global`、`local` 或者 `shell` 设置系统，如上面的 [设置当前版本](#设置当前版本) 部分所述。

```shell
asdf local <name> system
# asdf local python system
```

## 显示当前版本

```shell
asdf current
# asdf current
# erlang 17.3 (set by /Users/kim/.tool-versions)
# nodejs 6.11.5 (set by /Users/kim/cool-node-project/.tool-versions)

asdf current <name>
# asdf current erlang
# 17.3 (set by /Users/kim/.tool-versions)
```

## 卸载版本

```shell
asdf uninstall <name> <version>
# asdf uninstall erlang 17.3
```

## 垫片（Shims）

当 asdf 安装一个包时，它会在 `$ASDF_DATA_DIR/shims` 目录（默认为 `~/.asdf/shims`）中为该包中的每个可执行程序创建垫片。这个位于 `$PATH` 中（通过 `asdf.sh`、 `asdf.fish` 等等实现）的目录是已安装程序在环境中可用的方式。

垫片本身是非常简单的包装器，它 `exec` （执行）一个辅助程序 `asdf exec`，向其传递插件的名称和垫片正在包装的已安装包中的可执行程序的路径。

`asdf exec` 辅助程序确定要使用的软件包版本（比如在 `.tool-versions` 文件中指定，通过 `asdf local ...` 或者 `asdf global ...` 命令选择）、软件包安装目录中的可执行程序的最终路径（这可以在插件中通过 `exec-path` 回调来操作）以及要在其中执行的环境（也由插件 - `exec-env` 脚本提供），最后完成执行。

::: warning 注意
因为此系统使用 `exec` 调用，所以软件包中的任何脚本如果要由 shell 生效而不是执行的脚本都需要直接访问，而不是通过垫片包装器进行访问。两个 `asdf` 命令：`which` 和 `where` 可以通过返回已安装软件包的路径来帮助解决这个问题。
:::

```shell
# 返回当前版本中主要可执行程序的路径
source $(asdf which ${PLUGIN})/../script.sh

# 返回软件包安装目录的路径
source $(asdf where ${PLUGIN} $(asdf current ${PLUGIN}))/bin/script.sh
```

### 绕过 asdf 垫片

如果由于某种原因，你希望绕过 asdf 垫片，或者希望在进入项目目录时自动设置环境变量，则 [asdf-direnv](https://github.com/asdf-community/asdf-direnv) 插件可能会有所帮助。请务必查看其 README 文件了解更多详情。

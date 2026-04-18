# 升级到 0.16.0

asdf 0.15.0 版本以及更早版本是用 Bash 编写的，并以一系列 Bash 脚本的形式分发，其中 `asdf` 函数加载到 shell 中。从 0.16.0 版本开始 asdf 用 Go 语言完全重写了。由于是完全重写，存在一些 [重大变更](#重大变更)，现在它是一个二进制文件，而不是一系列脚本。

## 安装

0.16.0 版本及更高版本的安装比之前的 asdf 版本要简单多了。只需要三个步骤：

* 通过 [任意可能的安装方式](/zh-hans/guide/getting-started.html#_1-安装-asdf) 下载与操作系统和架构匹配的 `asdf` 二进制文件。如果使用包管理器，请验证安装的是 0.16.0 版本及更高版本。
* 添加 `$ASDF_DATA_DIR/shims` 变量到 `$PATH` 路径的最前面。
* 可选的是，如果你之前自定义了 asdf 数据目录，请将 `ASDF_DATA_DIR` 变量设置为包含插件、版本和垫片的旧版本安装目录。

如果操作系统包管理器已经提供 asdf 0.16.0，那么使用它来安装 asdf 可能是最佳方法。现在，升级 asdf 只能通过操作系统包管理器或手动安装来完成，不再支持自动升级功能。

### 不丢失数据的升级

你可以升级到 asdf  的最新版本，而不会丢失现有的安装数据。操作步骤同上。

#### 1. 下载匹配操作系统和架构的 `asdf` 二进制文件

从 [GitHub 发布页面](https://github.com/asdf-vm/asdf/releases) 下载二进制文件，并将其放置在系统路径中的某个目录下。我选择将 asdf 二进制文件放置在 `$HOME/bin` 目录中，然后将 `$HOME/bin` 添加在 `$PATH` 路径最前面：

```
# 在 .zshrc, .bashrc, 等...
export PATH="$HOME/bin:$PATH"
```

#### 2. 设置 `ASDF_DATA_DIR`

运行 `asdf info` 并复制包含 `ASDF_DATA_DIR` 变量的行： 

```
...
ASDF_DATA_DIR="/home/myuser/.asdf"
...
```

在 shell RC 配置文件中（比如 Zsh 的 `.zshrc`，Bash 的 `.bashrc` 等）末尾添加一行设置 `ASDF_DATA_DIR` 为相同的值：

```bash
export ASDF_DATA_DIR="/home/myuser/.asdf"
```

#### 3. 将 `$ASDF_DATA_DIR/shims` 加在 `$PATH` 最前面

在 shell RC 配置文件（与第 2 步相同的文件）中，将 `$ASDF_DATA_DIR/shims` 添加到路劲的开头：

```bash
export ASDF_DATA_DIR="/home/myuser/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"
```

#### 4. 移除旧的配置文件

在 shell RC 配置中，你会有旧代码在启动时运行 asdf shell 脚本。它可能看起来像这样：

```
. "$HOME/.asdf/asdf.sh"
```

或者这样：

```
. /opt/homebrew/opt/asdf/libexec/asdf.sh
```

注释掉这些行或者完全删除它们。

如果你未使用 Zsh 或者 Bash，请查阅旧版的
[快速入门](https://asdf-vm.com/zh-hans/guide/getting-started-legacy.html#_3-安装-asdf)
获悉需要删除的代码片段。

#### 5. 重新生成垫片

请通过运行 `asdf --help` 命令，确认当前 shell 会话中 `asdf` 命令的版本为 0.16.0 或更高版本。如果仍显示旧版本，你需要启动一个新的 shell 会话。

一旦确认 `asdf` 命令为新版本后，运行 `asdf reshim` 来重新生成所有的垫片。这是必要的，因为旧的垫片可能仍使用旧的 Bash 版本。

### 测试

如果你不确定升级到 0.16.0 是否会导致问题，那么可以按照上述“不丢失数据的升级”的描述，在现有版本的基础上安装 0.16.0 进行测试。如果升级到 0.16.0 或更高版本导致问题，你可以回退到旧版本。删除添加在 shell RC 配置文件中的行，并重新添加删除或注释掉的行即可。

### 移除旧文件

**仅在完成上述所有步骤并确认新的 asdf 安装正常运行后再执行此操作！** 升级后，你可以从旧版基于 Bash 脚本的 asdf 版本中移除旧文件。数据目录（通常为 `~/.asdf/`）中的大多数文件均可删除。需要注意的是，此操作并非强制要求。保留旧版本 asdf 的文件不会造成任何问题。必须**保留**的目录仅有：

* `downloads/`
* `installs/`
* `plugins/`
* `shims/`

其余文件可以删除。这可以通过 `find` 命令一次性完成：

```
find ${ASDF_DATA_DIR:-$HOME/.asdf}/ -maxdepth 1 -mindepth 1 -not -name downloads -not -name plugins -not -name installs -not -name shims -exec rm -r {} \;
```

## 重大变更

### 连字符连接的命令已被移除

asdf 版本 0.15.0 及更早版本对某些命令支持带连字符和不带连字符。从版本 0.16.0 开始，仅支持不带连字符的版本。受影响的命令有： 

* `asdf list-all` -> `asdf list all`
* `asdf plugin-add` -> `asdf plugin add`
* `asdf plugin-list` -> `asdf plugin list`
* `asdf plugin-list-all` -> `asdf plugin list all`
* `asdf plugin-update` -> `asdf plugin update`
* `asdf plugin-remove` -> `asdf plugin remove`
* `asdf plugin-test` -> `asdf plugin test`
* `asdf shim-versions` -> `asdf shimversions`

### `asdf global` 和 `asdf local` 命令已被 `asdf set` 取代

`asdf global` 和 `asdf local` 已被移除。"global" 和 "local" 这一术语存在错误且容易引起误解。asdf 实际上并不支持适用于所有位置的 "global" 版本。任何通过 `asdf global` 指定的版本都可能被当前目录中的 `.tool-versions` 文件中指定的不同版本覆盖。这会让用户感到困惑。新的 `asdf set` 默认行为与 `asdf local` 相同，但还提供了用于在用户主目录（`--home`）和父目录中的现有 `.tool-versions` 文件（`--parent`）中设置版本的标志。这个新接口有望更好地传达 asdf 如何解析版本，并提供等效的功能。

### `asdf update` 命令已被移除

更新不再支持此方式。请使用操作系统包管理器或手动下载最新二进制文件。此外，版本 0.15.0 及更早版本中存在的 `asdf update` 命令无法升级到 0.16.0 版本，因为安装流程已经发生了改变。**无法通过 `asdf update` 命令升级到最新 Go 实现版本。**

### `asdf shell` 命令已被移除

该命令实际上在用户的当前 shell 会话中设置了一个环境变量。它能够做到这一点是因为 `asdf` 实际上是一个 shell 函数，而不是可执行文件。新的重写版本移除了 asdf 中的所有 shell 代码，现在它是一个二进制文件而非 shell 函数，因此直接在 shell 中设置环境变量已不再可能。

### `asdf current` 已发生改变

输出中不再显示三列，最后一列不再显示版本设置的位置或建议用于设置或安装的命令。第三列已拆分成两列。现在的第三列仅指示版本的来源（如果已设置，通常为版本文件或环境变量），而第四列是布尔值，表示指定的版本是否实际已安装。如果未安装，将显示建议的安装命令。

### 插件扩展命令现在必须以 `cmd` 为前缀

之前的插件扩展命令可以像这样运行：

```
asdf nodejs nodebuild --version
```

现在它们必须以 `cmd` 为前缀，以避免与内置命令混淆：

```
asdf cmd nodejs nodebuild --version
```

### 扩展命令已重新设计

插件扩展命令有一系列的重大变更：

* 它们必须可以通过 `exec` 系统调用运行。若扩展命令是 shell 脚本，为了能通过 `exec` 运行，它们必须以正确的 shebang（ `#!`）行开头。
* 它们现在可以是任何语言的二进制文件或脚本。不再要求使用 `.bash` 扩展名，因为这会引起误解。
* 它们必须具有可执行权限。
* 当缺少可执行权限时，它们不再被 asdf 作为 Bash 脚本加载。

此外，仅使用插件名称后的第一个参数来确定要运行的扩展命令。这意味着实际上存在一个默认的 `command` 扩展命令，当未找到与插件名称后第一个参数匹配的命令时，asdf 会默认使用该命令。例如：

```
foo/
  lib/commands/
    command
    command-bar
    command-bat-man
```

先前这些脚本的工作方式是这样的：

```
$ asdf cmd foo         # 等同于运行 `$ASDF_DATA_DIR/plugins/foo/lib/commands/command`
$ asdf cmd foo bar     # 等同于运行 `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bar`
$ asdf cmd foo bat man # 等同于运行 `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat-man`
```

现在：

```
$ asdf cmd foo         # 等同于运行 `$ASDF_DATA_DIR/plugins/foo/lib/commands/command`
$ asdf cmd foo bar     # 等同于运行 `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bar`
$ asdf cmd foo bat man # 等同于运行 `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat man`
```

### 可执行文件的兼容性问题由 `syscall.Exec` 解决

最明显的例子是缺少正确 shebang 行的脚本。asdf 0.15.0 及更早版本使用 Bash 实现，因此只要该可执行文件可通过 Bash 执行，即可运行。这意味着缺少 shebang 行的脚本仍可通过 `asdf exec` 运行。随着 asdf 0.16.x 改用 Go 语言实现，我们现在通过 Go 的 `syscall.Exec` 函数调用可执行文件，而该函数无法处理缺少 shebang 行的脚本。

实际上这并不是什么大问题。大多数 shell 脚本确实包含 shebang 行。如果由 asdf 管理且缺少 shebang 行，则需要手动添加。

### 不再支持自定义垫片模版

这是一个鲜少使用的功能。核心团队维护的唯一使用该功能的插件是 Elixir 插件，而该插件现已不再需要此功能。该功能最初添加的目的是，使由程序评估而非执行的垫片包含适合特定程序评估的代码（在 Elixir 的情况下，这是 `iex` shell。）经过进一步调查，似乎该功能仅存在于 `PATH` 环境变量中可执行文件路径有时被错误地设置为包含**垫片**文件而非其他**可执行文件**的情况，且该设置针对选定的版本。

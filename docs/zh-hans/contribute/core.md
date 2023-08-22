# asdf

`asdf` 核心贡献指南.

## 初始化安装

在 Github 上 fork `asdf` 并且/或者使用 Git 克隆默认分支：

```shell
# 克隆你 fork 的 asdf
git clone https://github.com/<GITHUB_USER>/asdf.git
# 或者直接克隆 asdf
git clone https://github.com/asdf-vm/asdf.git
```

核心开发所需的工具都列举在这个存储库的 `.tool-versions` 文件中。如果你想要使用 `asdf` 自身来管理它，请使用以下命令添加这些插件：

```shell
asdf plugin add bats https://github.com/timgluz/asdf-bats.git
asdf plugin add shellcheck https://github.com/luizm/asdf-shellcheck.git
asdf plugin add shfmt https://github.com/luizm/asdf-shfmt.git
```

使用以下命令安装这些版本来开发 `asdf`：

```shell
asdf install
```

在本地机器的开发过程中不使用 `asdf` 来管理工具 _或许_ 对你有帮助，因为你可能需要打破某些可能会影响到你的开发工具链的功能。以下是所需工具的原始列表：

- [bats-core](https://github.com/bats-core/bats-core)：Bash 自动化测试系统，用于单元测试 Bash 或 POSIX 兼容脚本。
- [shellcheck](https://github.com/koalaman/shellcheck)：Shell 脚本的静态分析工具。
- [shfmt](https://github.com/mvdan/sh)：支持 Bash 的 Shell 解析器、格式化器和解释器；包含 shfmt。

## 开发

如果你想要在不更改已安装的 `asdf` 的情况下尝试应用你的更改，可以将 `$ASDF_DIR` 变量设置为克隆存储库的路径，并临时将目录的 `bin` 和 `shims` 目录添加到你的路径中。

最好在提交或推送到远程之前，在本地做好格式化、lint 检查和测试你的代码。可以使用以下脚本/命令：

```shell
# 脚本检查
./scripts/shellcheck.bash

# 格式化
./scripts/shfmt.bash

# 测试：所有案例
bats test/
# 测试：特定命令
bats test/list_commands.bash
```

::: tip 提示

**增加测试！** - 新特性需要进行测试，并加快错误修复的审查速度。请在创建拉取请求之前覆盖新的代码路径。查看 [bats-core 文档](https://bats-core.readthedocs.io/en/stable/index.html) 了解更多。

:::

## Bats 测试

**强烈建议**在编写测试之前检查现有的测试套件和 [bats-core 文档](https://bats-core.readthedocs.io/en/stable/index.html)。

Bats 调试有时可能很困难。使用带有 `-t` 标识的 TAP 输出将使你能够在测试执行期间打印带有特殊文件描述符 `>&3` 的输出，从而简化调试。例如：

```shell
# test/some_tests.bats

printf "%s\n" "Will not be printed during bats test/some_tests.bats"
printf "%s\n" "Will be printed during bats -t test/some_tests.bats" >&3
```

进一步相关文档请查看 bats-core 的 [Printing to the Terminal](https://bats-core.readthedocs.io/en/stable/writing-tests.html#printing-to-the-terminal) 部分.

## 拉取请求、发布以及约定式提交

`asdf` 正在使用一个名为 [Release Please](https://github.com/googleapis/release-please) 的自动发布工具来自动碰撞 [SemVer](https://semver.org/) 版本并生成 [变更日志](https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md)。这个信息是通过读取自上次发布以来的提交历史记录来确定的。

[约定式提交](https://www.conventionalcommits.org/zh-hans/) 定义了拉取请求标题的格式，该标题成为默认分支上的提交消息格式。这是通过 Github Action [`amannn/action-semantic-pull-request`](https://github.com/amannn/action-semantic-pull-request) 强制执行的。

约定式提交遵循以下格式：

```
<type>[optional scope][optional !]: <description>

<!-- 例子 -->
fix: some fix
feat: a new feature
docs: some documentation update
docs(website): some change for the website
feat!: feature with breaking change
```

`<types>` 的所有类型包含： `feat`、`fix`、`docs`、`style`、`refactor`、`perf`、`test`、`build`、`ci`、`chore`、`revert`。

- `!`：表示重大更改
- `fix`：将会创建一个新的 SemVer `patch` 补丁
- `feat`：将会创建一个新的 SemVer `minor` 小版本
- `<type>!`：将会创建一个新的 SemVer `major` 大版本

拉取请求标题必须遵循这种格式。

::: tip 提示

请使用约定式提交信息格式作为拉取请求标题。

:::

## Docker 镜像

[asdf-alpine](https://github.com/vic/asdf-alpine) 和 [asdf-ubuntu](https://github.com/vic/asdf-ubuntu) 项目正在努力提供一些 asdf 工具的容器化镜像。你可以使用这些容器镜像作为开发服务器的基础镜像，或者运行生产应用。

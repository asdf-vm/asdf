# 创建插件

## 插件里有什么

插件是一个包含几个可执行脚本的 git 存储库，用于支持对某种语言或工具进行版本控制。这些脚本在执行 `list-all`、`install` 或者 `uninstall` 命令时被执行。你可以设定或取消设定环境变量，并执行设置工具环境所需的任何操作。

## 必要的脚本

- `bin/list-all` - 列举所有可安装的版本
- `bin/download` - 下载指定版本的源代码或二进制文件
- `bin/install` - 安装指定版本

## 环境变量

所有脚本除了 `bin/list-all` 之外对以下环境变量有权限进行操作：

- `ASDF_INSTALL_TYPE` - `version` 或者 `ref`
- `ASDF_INSTALL_VERSION` - 如果 `ASDF_INSTALL_TYPE` 是 `version`，那么这将是版本号。否则它将传递为 git 的 ref。可能指向存储库的一个标签/提交/分支。
- `ASDF_INSTALL_PATH` - _已经_ 安装到的目录（或 `bin/install` 脚本执行情况下 _应该_ 安装到的目录）

这些附加的环境变量将可用于 `bin/install` 脚本：

- `ASDF_CONCURRENCY` - 编译源代码时使用的内核数。对于配置 `make -j` 非常有用。
- `ASDF_DOWNLOAD_PATH` - `bin/download` 脚本下载源代码或二进制文件的路径。

这些附加的环境变量将可用于 `bin/download` 脚本：

- `ASDF_DOWNLOAD_PATH` - 源代码或二进制文件应该下载到的路径。

#### bin/list-all

必须打印一个带有空格分隔的版本列表的字符串，示例输出如下所示：

```shell
1.0.1 1.0.2 1.3.0 1.4
```

请注意，最新版本应列在最后，以便它看起来更接近用户的提示。这很有帮助，因为 `list-all` 命令会在自己的行打印每个版本。如果有很多版本，那么早期版本可能会不在屏幕上。

如果从网站上的发布页面拉取版本，建议尽可能不对版本进行排序。通常，版本已经按照正确的顺序排列，或者以相反的顺序排列，在这种情况下，像 `tac` 这样的东西就足够了。如果必须手动对版本进行排序，则不能依赖 `sort -V`，因为 OSX 操作系统不支持。一种可以替代的排序功能是 [更好的选择](https://github.com/vic/asdf-idris/blob/master/bin/list-all#L6)。

#### bin/download

此脚本必须下载源代码或者二进制文件到 `ASDF_DOWNLOAD_PATH` 环境变量包含的路径。如果下载的源代码或者二进制文件是压缩的，则只有未压缩的源代码或二进制文件会放置在 `ASDF_DOWNLOAD_PATH` 目录中。

下载成功后脚本必须以 `0` 状态退出。如果下载失败，脚本必须以任何非零退出状态退出。

如果可能，脚本应该仅将文件放在 `ASDF_DOWNLOAD_PATH` 中。如果下载失败，则不应将任何文件放在目录中。

如果此脚本不存在，asdf 将假设存在 `bin/install` 脚本，将下载并安装该版本。asdf 仅在没有此脚本的情况下才能支持传统插件。所有插件都必须包含此脚本，最终将删除对传统插件的支持。

#### bin/install

本脚本应在 `ASDF_INSTALL_PATH` 中安装版本。默认情况下，asdf 将为 `$ASDF_INSTALL_PATH/bin` （可以通过可选的 [bin/list-bin-paths](#binlist-bin-paths) 脚本自定义）目录中的任意文件创建垫片。

安装成功时，安装脚本应以 `0` 状态退出。如果安装失败，脚本应以任何非零退出状态退出。

如果可能，脚本应仅在安装脚本认为工具的生成和安装成功后，才将文件放在 `ASDF_INSTALL_PATH` 目录中。asdf 检查 `ASDF_INSTALL_PATH` 目录的 [扩展](https://github.com/asdf-vm/asdf/blob/242d132afbf710fe3c7ec23c68cec7bdd2c78ab5/lib/utils.sh#L44) 以确认是否安装了该工具版本。如果在安装过程开始时填充了 `ASDF_INSTALL_PATH` 目录，则在安装过程中在其他终端中运行的其他 asdf 命令可能会认为该工具版本已经安装，即使它还未完全安装。

如果你希望你的插件使用 asdf 0.7._ 及更早版本和 0.8._ 及更高版本，请检查是否存在 `ASDF_DOWNLOAD_PATH` 环境变量。如果未设置，请在 `bin/install` 脚本回调时下载源代码。如果设置，则假设 `bin/downlaod` 脚本已经下载源代码。

## 可选脚本

#### bin/help 脚本

这不是一个回调脚本，而是一组回调脚本，每个脚本将打印不同的文档到 STDOUT。下面列出了可能的回调脚本。请注意，`bin/help.overview` 是一种特殊情况，因为必须存在才能为脚本显示任何帮助输出。

- `bin/help.overview` - 此脚本应该输出有关插件和所管理工具的一般描述。不应该打印任何标题，因为 asdf 将打印标题。输出可以是自由格式的文本，但理想情况下只有一个短段落。如果你希望 asdf 为你的插件提供帮助信息，则必须存在此脚本。所有其他的帮助回调脚本都是可选的。
- `bin/help.deps` - 此脚本应该输出为操作系统量身定制的依赖项列表。每行一个依赖项。
- `bin/help.config` - 此脚本应该打印对插件和工具可能有用的任何必需或可选配置。安装或编译该工具所需的任何环境变量或其他标志（尽可能针对用户的操作系统）。输出可以是自由格式的文本。
- `bin/help.links` - 这应该是与插件和工具相关的链接列表（同样，尽可能针对当前操作系统量身定制）。每行一个链接。行的格式可以是 `<title>: <link>` 或只是 `<link>`。

这些脚本的每一个都应根据当前操作系统调整其输出。例如，在 Ubuntu 上，依赖脚本可以将依赖项输出为必须安装的 apt-get 包。设置变量时，脚本还应该根据设置变量 `ASDF_INSTALL_VERSION` 和 `ASDF_INSTALL_TYPE` 的值。它们是可选的，并不总是被设置。

帮助回调脚本**不得**输出核心 asdf-vm 文档中已涵盖的任何信息。不得出现一般的 asdf 使用信息。

#### bin/latest-stable

如果实现了此回调，asdf 将使用它来确定工具的最新稳定版本，而不是尝试自行判断。`asdf latest` 通过查看由 `list-all` 回调打印的最新版本，在从输出中排除了几种类型的版本（如发布候选版本）之后推断出最新版本。当你的插件的 `list-all` 回调打印同一工具的不同变体并且最新版本不是你希望默认使用的变体的最新稳定版本时，这种默认行为是不可取的。例如，对于 Ruby，最新的稳定版本应该是 Ruby（MRI）的常规实现，但最后 `list-all` 回调打印的是 truffleruby 版本。

此回调使用单个 “过滤器” 字符串调用，因为它是唯一的参数。这应该用于过滤所有最新稳定版本。例如对于 Ruby，用户可以选择传入 `jruby` 以选择 `jruby` 的最新稳定版本。

#### bin/list-bin-paths

列举指定工具版本的可执行程序。必须打印一个带有空格分隔的包含可执行文件的目录路径列表的字符串。路径必须相对于传递的安装路径。示例输出如下所示：

```shell
bin tools veggies
```

这将指示 asdf 为 `<install-path>/bin`、`<install-path>/tools` 和 `<install-path>/veggies` 中的文件创建垫片。

如果未指定此脚本，asdf 将在安装中查找 `bin` 目录并为这些脚本创建垫片。

#### bin/exec-env

设置环境变量以运行包中的二进制文件。

#### bin/exec-path

获取工具的指定版本的可执行程序路径。必须打印具有相对可执行程序路径的字符串。这允许插件有条件地覆盖垫片指定的可执行程序路径，否则返回垫片指定的默认路径。

```shell
用法：
  plugin/bin/exec-path <install-path> <command> <executable-path>

例子调用：
  ~/.asdf/plugins/foo/bin/exec-path "~/.asdf/installs/foo/1.0" "foo" "bin/foo"

输出：
  bin/foox
```

#### bin/uninstall

卸载某个工具的指定版本。

#### bin/list-legacy-filenames

为此插件注册其他设置器文件。必须打印一个带有空格分隔的文件名列表的字符串。

```shell
.ruby-version .rvmrc
```

注意：这仅适用于在 `~/.asdfrc` 配置文件中启用了 `legacy_version_file` 选项的用户。

#### bin/parse-legacy-file

这可用于进一步解析 asdf 找到的传统文件。如果 `parse-legacy-file` 未实现，asdf 将会简单读取文件来确定版本。脚本将传递文件路径作为其第一个参数。

#### bin/post-plugin-add

这可用于在插件添加到 asdf 后运行任何安装后操作。

该脚本可以访问插件的安装路径（`${ASDF_PLUGIN_PATH}`）和源 URL（`${ASDF_PLUGIN_SOURCE_URL}`），如果有的话。

其他请参考相关钩子：

- `pre_asdf_plugin_add`
- `pre_asdf_plugin_add_${plugin_name}`
- `post_asdf_plugin_add`
- `post_asdf_plugin_add_${plugin_name}`

#### bin/post-plugin-update

这可用于在 asdf 下载更新的插件后运行任何插件更新后操作。

该脚本可以访问插件的安装路径（`${ASDF_PLUGIN_PATH}`）、更新前的 git-ref（`${ASDF_PLUGIN_PREV_REF}`）和更新后的 git-ref（`${ASDF_PLUGIN_POST_REF}`）。

其他请参考相关钩子：

- `pre_asdf_plugin_update`
- `pre_asdf_plugin_update_${plugin_name}`
- `post_asdf_plugin_update`
- `post_asdf_plugin_update_${plugin_name}`

#### bin/pre-plugin-remove

这可用于在从 asdf 中删除插件之前运行任何预删除操作。

该脚本可以访问安装插件的路径（`${ASDF_PLUGIN_PATH}`）。

其他请参考相关钩子：

- `pre_asdf_plugin_remove`
- `pre_asdf_plugin_remove_${plugin_name}`
- `post_asdf_plugin_remove`
- `post_asdf_plugin_remove_${plugin_name}`

## asdf 命令行的扩展命令

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

调用时，如果扩展命令未设置其可执行位，则它们将作为 bash 脚本获取，且具有来自 `$ASDF_DIR/lib/utils.bash` 的所有可用功能。
此外，`$ASDF_CMD_FILE` 解析所获取文件的完整路径。
如果设置了可执行位，则只是执行它们并替换 asdf 执行。

这个功能的一个很好的例子是像 [`haxe`](https://github.com/asdf-community/asdf-haxe) 这样的插件。
它提供了 `asdf haxe neko-dylibs-link` 来修复 haxe 可执行文件期望找到相对于可执行目录的动态链接库的问题。

如果你的插件提供了 asdf 扩展命令，请务必在插件的 README 文件中提及。

## 自定义垫片模板

**请仅在真的需要时才使用此功能**

asdf 允许自定义垫片模板。对于名为 `foo` 的可执行程序，如果有一个 `shims/foo` 的文件在插件中，那么 asdf 将复制这个文件替代使用标准垫片模板。

必须明智地使用这一点。对于目前的 AFAIK，它仅仅被使用在了 Elixir 插件中，因为一个可执行程序除了是可执行程序文件之外，还被读作为 Elixir 文件，这使得无法使用标准的 bash 垫片。

## 测试插件

`asdf` 包含 `plugin-test` 命令用于测试插件。你可以像下面这样使用它：

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]
```

只有前两个参数是必须的。
如果指定了 \__version_，则该工具将随指定版本一起安装。默认返回为 `asdf latest <plugin-name>`。
如果指定了 _git-ref_，则插件将检查提交/分支/标签。这对于在该插件的 CI 上测试拉取请求非常有用。默认值是插件仓库的默认分支。

剩下的参数被视为要执行的命令，以确保安装的工具正常工作。通常情况下，它需要带 `--version` 或者 `--help`。例如，要测试 NodeJS 插件，我们可以运行：

```shell
asdf plugin test nodejs https://github.com/asdf-vm/asdf-nodejs.git node --version
```

我们强烈建议你在 CI 环境中测试你的插件，并确保它可以在 Linux 和 OSX 上运行。

#### GitHub Action 示例

[asdf-vm/actions](https://github.com/asdf-vm/actions) 存储库为托管在 github 的项目提供了使用 Github Action 来测试插件的可能。

```yaml
steps:
  - name: asdf_plugin_test
    uses: asdf-vm/actions/plugin-test@v1
    with:
      command: "my_tool --version"
    env:
      GITHUB_API_TOKEN: ${{ secrets.GITHUB_TOKEN }} # 自动提供
```

#### TravisCI 配置示例

这是一个 `.travis.yml` 示例文件，请根据你的需要进行自定义：

```yaml
language: c
script: asdf plugin test nodejs $TRAVIS_BUILD_DIR 'node --version'
before_script:
  - git clone https://github.com/asdf-vm/asdf.git asdf
  - . asdf/asdf.sh
os:
  - linux
  - osx
```

注意：
当使用其他 CI 时，你将需要确认哪些变量映射到存储库路径。

你还可以选择将相对路径传递给 `plugin-test`。

例如，如果在存储库目录中运行测试脚本：`asdf plugin test nodejs . 'node --version'`。

## GitHub API 频率限制

如果你的插件的 `list-all` 依赖于访问 GitHub API，请确保在访问时提供授权令牌，否则你的测试可能会因频率限制而失败。

为此，创建一个仅具有 `public_repo` 权限的 [新个人令牌](https://github.com/settings/tokens/new)。

然后，在 travis.ci 构建设置中添加一个名为 `GITHUB_API_TOKEN` 的 _安全_ 环境变量。并且 _绝对不要_ 在你的代码中公布你的 token。

最后，添加如下内容到 `bin/list-all`：

```shell
cmd="curl -s"
if [ -n "$GITHUB_API_TOKEN" ]; then
 cmd="$cmd -H 'Authorization: token $GITHUB_API_TOKEN'"
fi

cmd="$cmd $releases_path"
```

## 向官方插件存储库提交插件

`asdf` 可以通过指定插件存储库 url 轻松安装插件，比如 `plugin add my-plugin https://github.com/user/asdf-my-plugin.git`。

为了使你的用户更轻松，你可以将插件添加到官方插件存储库中，以列出你的插件并使用较短的命令轻松安装，比如 `asdf plugin add my-plugin`。

请查看插件存储库 [asdf-vm/asdf-plugins](https://github.com/asdf-vm/asdf-plugins) 中的说明了解更多。

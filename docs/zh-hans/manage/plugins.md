# 插件

插件告诉 `asdf` 如何处理不同的工具，如 Node.js、 Ruby、 Elixir 等。

请参考 [创建插件](/zh-hans/plugins/create.md) 了解用于支持更多工具的插件 API。

## 添加

通过 Git URL 地址添加插件：

```shell
asdf plugin add <name> <git-url>
# asdf plugin add elm https://github.com/vic/asdf-elm
```

或者通过插件存储库中的缩写添加插件：

```shell
asdf plugin add <name>
# asdf plugin add erlang
```

::: tip 建议
推荐独立于缩写存储库的、更长的 `git-url` 方法。
:::

## 列举已安装

```shell
asdf plugin list
# asdf plugin list
# java
# nodejs
```

```shell
asdf plugin list --urls
# asdf plugin list
# java            https://github.com/halcyon/asdf-java.git
# nodejs          https://github.com/asdf-vm/asdf-nodejs.git
```

## 列举缩写存储库中的所有插件

```shell
asdf plugin list all
```

请参考 [插件缩写索引](https://github.com/asdf-vm/asdf-plugins) 了解插件的完整缩写列表。

## 更新

```shell
asdf plugin update --all
```

如果你想要更新特定的包，如下所示。

```shell
asdf plugin update <name>
# asdf plugin update erlang
```

这种更新方式将会获取插件存储库的 _源代码_ 的 _默认分支_ 的 _最新提交_。版本化的插件和更新正在开发中 ([#916](https://github.com/asdf-vm/asdf/pull/916))。

## 移除

```bash
asdf plugin remove <name>
# asdf plugin remove erlang
```

移除一个插件将会移除该插件安装的所有工具。这可以当作是清理/修剪工具的许多未使用版本的简单方法。

## 同步缩写存储库

缩写存储库将同步到你的本地计算机并定期刷新。这个周期由以下方法确定：

- 命令 `asdf plugin add <name>` 或者 `asdf plugin list all` 将会触发同步
- 如果在过去的 `X` 分钟内没有同步，则进行同步
- `X` 默认是 `60`，但可以通过在 `.asdfrc` 文件中配置 `plugin_repository_last_check_duration` 选项来进行配置。请查看 [asdf 配置文档](/zh-hans/manage/configuration.md) 了解更多。

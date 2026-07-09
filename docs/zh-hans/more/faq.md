# FAQ

以下是 `asdf` 相关的一些常见问题。

## 支持 WSL1 吗？

WSL1 ([Windows Subsystem for Linux 1](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux#WSL_1)) 不受官方支持。`asdf` 的某些方面可能无法正常工作。我们不打算添加对 WSL1 的官方支持。

## 支持 WSL2 吗？

WSL2 ([Windows Subsystem for Linux 2](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux#WSL_2)) 应该作为你选择的 WSL 发行版来使用本设置和依赖说明。

重要的是，只有当前工作目录是 Unix 驱动器而不是绑定的 Windows 驱动器时，WSL2 _才能_ 正常工作。

当 Github Actions 上提供主机运行器支持时，我们打算在 WSL2 上运行测试套件。（Github Actions 目前还未提供 WSL2 支持）

## 新安装的可执行程序无法运行？

> 我执行了 `npm install -g yarn` 命令，但是之后不能运行 `yarn` 命令。这是为什么？

`asdf` 使用 [垫片](<https://zh.wikipedia.org/wiki/垫片_(程序设计)>) 来管理可执行程序。插件所安装的那些命令会自动创建垫片，而通过 `asdf` 管理工具安装过的可执行程序则需要通知 `asdf` 创建垫片的需要。在这个例子中，为 [Yarn](https://yarnpkg.com/) 创建一个垫片即可。请查看 [`asdf reshim` 命令文档](/zh-hans/manage/core.md#reshim) 了解更多。

## Shell 没有检测到新安装的垫片？

如果 `asdf reshim` 没有解决你的问题，那么很有可能是在 `asdf.sh` 或者 `asdf.fish` 的生效不在你的 Shell 配置文件（`.bash_profile`、`.zshrc`、`config.fish` 等等）的**下方**。这需要你在设置你的 `$PATH` **之后**和生效你的框架（oh-my-zsh 等等）（如果有的话）**之后**再生效。

## 为什么不能在 `.tool-versions` 文件中使用 `latest` 版本？

asdf 必须始终使用当前目录的每个工具的精确版本，不允许使用版本范围或特殊值（如 `latest`）。这确保 asdf 在不同时间和不同机器上以确定性和一致性方式运行。像 `latest` 这样的特殊版本会随时间变化，并且如果在不同时间运行 `asdf install`，不同机器上的版本可能会有所不同。因此，它可以在 asdf 命令如 `asdf set <tool> latest` 中使用，但在 `.tool-versions` 文件中是被禁止的。

可将 `.tool-versions` 文件看成 `Gemfile.lock` 或者 `package-lock.json`。该文件包含项目依赖的每个工具的精确版本。

需要注意的是，`system` 版本在 `.tool-versions` 文件中是允许的，且在使用时可能解析为不同版本。这是一个特殊值，可有效禁用指定目录下特定工具的 asdf 功能。

请查看 https://github.com/asdf-vm/asdf/issues/1012 了解更多。

## 为什么不能在 `.tool-versions` 文件中使用版本范围？

与上述关于使用 `latest` 的问题类似。如果指定了版本范围，asdf 将可以自由选择该范围内的任何已安装版本。这可能导致不同机器上出现不同行为，因为它们可能安装了不同版本。asdf 的设计意图是完全确定性的，即相同的 `.tool-versions` 文件在不同时间和不同计算机上应生成完全相同的环境。

请查看 https://github.com/asdf-vm/asdf-nodejs/issues/235#issuecomment-885809776 了解更多。

## 为什么与我使用的插件完全无关的命令会被 asdf 生成垫片？

**asdf 只会为其管理的可执行文件生成垫片**。例如，如果你使用 Ruby 插件，那么你可能会看到 `ruby` 和 `irb` 等命令被垫片替换，以及你安装的 Ruby 包中包含的其他可执行文件。

如果你看到一个意料之外的垫片，很可能是因为你通过 asdf 管理工具安装了一个包，而该包提供了该可执行文件。

当可执行文件与系统中已存在的可执行文件名称相同，这种情况会令人意外。[部分用户报告称](https://github.com/asdf-vm/asdf/issues/584) 某个 Node.JS 包提供了自己的 `which` 命令版本。这导致 asdf 为其创建了垫片，并替换了操作系统中已存在的 `which` 命令版本。在这种情况下，最好定位引入可执行文件的包并将其移除。`asdf which <command>` 命令可帮助你确定问题可执行文件的位置，从而判断是哪一个包添加了可执行文件。

请查看 https://github.com/asdf-vm/asdf/issues/584 https://github.com/asdf-vm/asdf/issues/1653 了解更多。

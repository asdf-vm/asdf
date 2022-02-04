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

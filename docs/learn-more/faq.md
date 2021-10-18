# FAQ

Here are some common questions regarding `asdf`.

## WSL1 support?

WSL1 ([Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) 1) is not officially supported. Some aspects of `asdf` may not work properly. We do not intend to add official support for WSL1.

## WSL2 support?

WSL2 ([Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux#WSL_2) 2) should work using the setup & dependency instructions for you chosen WSL distro.

Importantly, WSL2 is _only_ expected to work properly when the current working directory is a Unix drive and not a bound Windows drive.

We intend to run out test suite on WSL2 when host runner support is available on GitHub Actions, currently this does not appear to be the case.

## Newly installed executable not running?

> I just `npm install -g yarn`, but cannot execute `yarn`. What gives?

`asdf` uses [shims](<https://en.wikipedia.org/wiki/Shim_(computing)>) to manage executables. Those installed by plugins have shims automatically created, whereas installing executables via an `asdf` managed tool will require you to notify `asdf` of the need to create shims. In this instance, to create a shim for [Yarn](https://yarnpkg.com/). See the [`asdf reshim` command docs](/manage/core.md#reshim).

## Shell not detecting newly installed shims?

If `asdf reshim` is not resolving your issue, then it is most-likely due to the sourcing of `asdf.sh` or `asdf.fish` _not_ being at the **BOTTOM** of your Shell config file (`.bash_profile`, `.zshrc`, `config.fish` etc). It needs to be sourced **AFTER** you have set your `$PATH` and **AFTER** you have sourced your framework (oh-my-zsh etc) if any.

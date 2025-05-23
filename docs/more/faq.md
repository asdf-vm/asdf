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

## Why can't I use a version of `latest` in the `.tool-versions` file?

asdf must always have an exact version of every tool in the current directory, not version ranges or special values like `latest` are not permitted. This ensure that asdf behaves in a deterministic and consistent way across time and across different machines. A special version like `latest` would change over time, and could vary between machines if `asdf install` was run at different times. As such it's allowed in asdf commands like `asdf set <tool> latest`, but forbidden in the `.tool-versions` file.

Think of `.tool-versions` file as `Gemfile.lock` or `package-lock.json`. It is a file that contains the exact version of every tool your project depends on.

Note that the `system` version is allowed in `.tool-versions` files, and it could resolve to different versions when used. It is a special value that  effectively disables asdf for a particular tool in the given directory.

See issue https://github.com/asdf-vm/asdf/issues/1012

## Why can't version ranges be used in the `.tool-versions` files?

Similar to the question above on the use of `latest`. With a version range specified, asdf would be free to choose any installed version in the specified range. This could result in different behavior across machines if they have different versions installed. The intent is for asdf to be fully deterministic so the same `.tool-versions` file produces the exact same environment across time and across different computers.

See issue https://github.com/asdf-vm/asdf-nodejs/issues/235#issuecomment-885809776

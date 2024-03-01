# コア

コアとなる`asdf`のコマンドはかなり少量ですが、多くのワークフローを円滑に進めることができます。

## インストール & セットアップ

[はじめよう](/ja-jp/guide/getting-started.md)のガイドで説明されています。

## 実行

```shell
asdf exec <command> [args...]
```

現在のバージョンのShimでコマンドを実行します。

<!-- TODO: expand on this with example -->

## 環境変数

```shell
asdf env <command> [util]
```

<!-- TODO: expand on this with example -->

## 情報

```shell
asdf info
```

OS、シェル、および`asdf`のデバッグ情報を表示するヘルパーコマンドです。バグレポート作成時に共有してください。

## Shimの再作成

```shell
asdf reshim <name> <version>
```

特定のパッケージ・バージョンのShimを再作成します。デフォルトでは、Shimはプラグインによってツールのインストール中に作成されます。[npm CLI](https://docs.npmjs.com/cli/)などのツールは、実行ファイルをグローバルインストールができます(例:`npm install -g yarn`コマンドで[Yarn](https://yarnpkg.com/)をインストール)が、これらの実行ファイルはプラグインのライフサイクルを通してインストールされないため、Shimはまだ存在しません。そのような時に、例えば`asdf reshim nodejs <version>`を実行すると、`nodejs`の`<version>`に対して、`yarn`のような新しい実行ファイルのShimを強制的に再作成させることができます。

## Shimのバージョン

```shell
asdf shim-versions <command>
```

`<command>`のShimを提供するプラグインおよびバージョンを一覧で表示します。

例えば、[Node.js](https://nodejs.org/)には`node`と`npm`という2つの実行ファイルが提供されています。[`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/)プラグインで、複数のバージョンのツールがインストールされている場合、`shim-versions`は下記のような一覧を返します:

```shell
➜ asdf shim-versions node
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

```shell
➜ asdf shim-versions npm
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

## 更新

`asdf`には、Git依存のアップデートコマンドが用意されています(推奨されるインストール方法を使用した場合)。別の方法でインストールした場合、その方法の手順に従ってください:

| 方法           | 最新の安定リリース                                                                                                                 | `master`ブランチの最新コミット   |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| asdf (Git経由) | `asdf update`                                                                                                                      | `asdf update --head`             |
| Homebrew       | `brew upgrade asdf`                                                                                                                | `brew upgrade asdf --fetch-HEAD` |
| Pacman         | 新しい`PKGBUILD`をダウンロードしてリビルド、<br/>または好みの[AURヘルパー](https://wiki.archlinux.org/index.php/AUR_helpers)を使用 |                                  |

## アンインストール

`asdf`をアンインストールするには以下の手順に従ってください:

::: details Bash & Git

1. `~/.bashrc`で、`asdf.sh`およびコマンド補完をsourceしている行を削除します:

```shell
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
```

2. `$HOME/.asdf`ディレクトリを削除します:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Git (macOS)

1. `~/.bash_profile`で、`asdf.sh`およびコマンド補完をsourceしている行を削除します:

```shell
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
```

2. `$HOME/.asdf`ディレクトリを削除します:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Homebrew

1. `~/.bashrc`で、`asdf.sh`およびコマンド補完をsourceしている行を削除します:

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash
```

コマンド補完については、[Homebrewで説明されている方法で設定](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash)されている可能性があるため、そちらのガイドに従って削除する行を見つけてください。

2. パッケージマネージャでアンインストールします:

```shell
brew uninstall asdf --force
```

3. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Homebrew (macOS)

**macOS Catalina以降**では、デフォルトのシェルが**ZSH**に変更されました。もし、`~/.bash_profile`に設定が見つからない場合は、`~/.zshrc`にある可能性があります。その場合は、ZSHの手順をご覧ください。

1. `~/.bash_profile`で、`asdf.sh`およびコマンド補完をsourceしている行を削除します:

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash
```

コマンド補完については、[Homebrewで説明されている方法で設定](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash)されている可能性があるため、そちらのガイドに従って削除する行を見つけてください。

2. パッケージマネージャでアンインストールします:

```shell
brew uninstall asdf --force
```

3. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Pacman

1. `~/.bashrc`で、`asdf.sh`およびコマンド補完をsourceしている行を削除します:

```shell
. /opt/asdf-vm/asdf.sh
```

2. パッケージマネージャでアンインストールします:

```shell
pacman -Rs asdf-vm
```

3. `$HOME/.asdf`ディレクトリを削除します:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

4. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Fish & Git

1. `~/.config/fish/config.fish`で、`asdf.fish`をsourceしている行を削除します:

```shell
source ~/.asdf/asdf.fish
```

そして、次のコマンドで、コマンド補完を削除します:

```shell
rm -rf ~/.config/fish/completions/asdf.fish
```

2. `$HOME/.asdf`ディレクトリを削除します:

```shell
rm -rf (string join : -- $ASDF_DATA_DIR $HOME/.asdf)
```

3. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Fish & Homebrew

1. `~/.config/fish/config.fish`で、`asdf.fish`をsourceしている行を削除します:

```shell
source "(brew --prefix asdf)"/libexec/asdf.fish
```

2. パッケージマネージャでアンインストールします:

```shell
brew uninstall asdf --force
```

3. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Fish & Pacman

1. `~/.config/fish/config.fish`で、`asdf.fish`をsourceしている行を削除します:

```shell
source /opt/asdf-vm/asdf.fish
```

2. パッケージマネージャでアンインストールします:

```shell
pacman -Rs asdf-vm
```

3. `$HOME/.asdf`ディレクトリを削除します:

```shell
rm -rf (string join : -- $ASDF_DATA_DIR $HOME/.asdf)
```

4. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Git

1. `~/.config/elvish/rc.elv`で、`asdf`モジュールを使用している行を削除します:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

そして、次のコマンドで、`asdf`モジュールを削除します:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. `$HOME/.asdf`ディレクトリを削除します:

```shell
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

3. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Homebrew

1. `~/.config/elvish/rc.elv`で、`asdf`モジュールを使用している行を削除します:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

そして、次のコマンドで、`asdf`モジュールを削除します:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. パッケージマネージャでアンインストールします:

```shell
brew uninstall asdf --force
```

3. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Pacman

1. `~/.config/elvish/rc.elv`で、`asdf`モジュールを使用している行を削除します:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

そして、次のコマンドで、`asdf`モジュールを削除します:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. パッケージマネージャでアンインストールします:

```shell
pacman -Rs asdf-vm
```

3. `$HOME/.asdf`ディレクトリを削除します:

```shell
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

4. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details ZSH & Git

1. `~/.zshrc`で、`asdf.sh`およびコマンド補完をsourceしている行を削除します:

```shell
. "$HOME/.asdf/asdf.sh"
# ...
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit
compinit
```

**または**、ZSHフレームワークプラグインを使用します。

2. `$HOME/.asdf`ディレクトリを削除します:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details ZSH & Homebrew

1. `~/.zshrc`で、`asdf.sh`をsourceしている行を削除します:

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
```

2. パッケージマネージャでアンインストールします:

```shell
brew uninstall asdf --force && brew autoremove
```

3. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details ZSH & Pacman

1. `~/.zshrc`で、`asdf.sh`をsourceしている行を削除します:

```shell
. /opt/asdf-vm/asdf.sh
```

2. パッケージマネージャでアンインストールします:

```shell
pacman -Rs asdf-vm
```

3. `$HOME/.asdf`ディレクトリを削除します:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

4. `asdf`のすべての構成ファイルを削除するために次のコマンドを実行します:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

たったこれだけです! 🎉

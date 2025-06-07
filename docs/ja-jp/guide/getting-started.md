# はじめよう

## 1. asdfのインストール

asdfはいくつかの方法でインストールできます:

::: details パッケージマネージャーを使用 - **推奨**

| パッケージマネージャー   | コマンド                                                                                                                                                             |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Homebrew | `brew install asdf`                                                                                                                                                 |
| Pacman   | `git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si` または お好みの [AUR ヘルパー](https://wiki.archlinux.jp/index.php/AUR_%E3%83%98%E3%83%AB%E3%83%91%E3%83%BC) |

:::

:::: details コンパイル済みバイナリをダウンロード - **かんたん**

<!--@include: ./parts/install-dependencies.md-->

##### asdfのインストール

1. https://github.com/asdf-vm/asdf/releases から、お使いのオペレーティングシステム/アーキテクチャの組み合わせに適したアーカイブをダウンロード。
2. アーカイブ内の`asdf`バイナリを`$PATH`のディレクトリに解凍。
3. `type -a asdf`を実行して、シェルの`$PATH`に`asdf`があることを確認します。`asdf`のバイナリを置いたディレクトリが`type`の出力の1行目に表示されるはずです。うまくいかない場合は、2の手順が正しく行えていない可能性があります。

::::

:::: details `go install` を使用

<!--@include: ./parts/install-dependencies.md-->

##### asdfのインストール

<!-- x-release-please-start-version -->
1. [Goをインストールする](https://go.dev/doc/install)
2. コマンドを実行: `go install github.com/asdf-vm/asdf/cmd/asdf@v0.18.0`
<!-- x-release-please-end -->

::::

:::: details ソースコードからビルドする

<!--@include: ./parts/install-dependencies.md-->

##### asdfのインストール

<!-- x-release-please-start-version -->
1. asdfリポジトリをクローン:
  ```shell
  git clone https://github.com/asdf-vm/asdf.git --branch v0.18.0
  ```
<!-- x-release-please-end -->
2. `make`を実行。
3. `asdf`バイナリを`$PATH`上のディレクトリに解凍。
4. `type -a asdf`を実行して、シェルの`$PATH`に`asdf`があることを確認します。`asdf`のバイナリを置いたディレクトリが`type`の出力の1行目に表示されるはずです。うまくいかない場合は、3の手順が正しく行えていない可能性があります。

::::

## 2. asdfの設定

::: tip 備考
ほとんどのユーザーは、asdfが管理するデータ(plugin, install, shim data)の保存先を変更する必要は**ありません**。ただし、デフォルトの`$HOME/.asdf`以外を指定したい場合は変更することができます。別のディレクトリを指定するには、シェルのRCファイルで`ASDF_DATA_DIR`変数をエクスポートしてください。
:::

シェル、OS、インストール方法には様々な組み合わせがあり、その全てがここでの設定に影響します。あなたのシステムに最も適したものを選んでください。

**masOSユーザーはこの節の最後にある`path_helper`に関する警告を必ず参照してください。**

::: details Bash

**macOS Catalina以降**: デフォルトのシェルが**ZSH**に変更されました。Bashに変更していない限り、ZSHの手順を参照してください。

**Pacman**: コマンド補完が必要な場合は、[`bash-completion`](https://wiki.archlinux.jp/index.php/Bash#.E3.82.88.E3.81.8F.E4.BD.BF.E3.82.8F.E3.82.8C.E3.82.8B.E3.83.97.E3.83.AD.E3.82.B0.E3.83.A9.E3.83.A0.E3.81.A8.E3.82.AA.E3.83.97.E3.82.B7.E3.83.A7.E3.83.B3)をインストールしてください。

##### shimsディレクトリをパスに追加する(必須)

`~/.bash_profile`に以下を追記します:
```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### カスタムデータディレクトリの設定(オプション)

`~/.bash_profile`に以下を追記します(先述したパス追加よりも上の行に書くこと):

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
```

##### シェルのコマンド補完設定(オプション)

`.bashrc`に以下を追記します:

```shell
. <(asdf completion bash)
```

:::

::: details Fish

##### shimsディレクトリをパスに追加する(必須)

`~/.config/fish/config.fish`に以下を追記します:

```shell
# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims
```

###### カスタムデータディレクトリの設定(オプション)

**Pacman**: コマンド補完はAURパッケージのインストール時に自動的に設定されます。

`~/.config/fish/config.fish`に以下を追記します(先述したパス追加よりも上の行に書くこと):

```shell
set -gx --prepend ASDF_DATA_DIR "/your/custom/data/dir"
```

##### シェルのコマンド補完設定(オプション)

コマンド補完は以下を実行して手動で設定する必要があります:

```shell
$ asdf completion fish > ~/.config/fish/completions/asdf.fish
```

:::

::: details Elvish

##### shimsディレクトリをパスに追加する(必須)

`~/.config/elvish/rc.elv`に以下を追記します:

```shell
var asdf_data_dir = ~'/.asdf'
if (and (has-env ASDF_DATA_DIR) (!=s $E:ASDF_DATA_DIR '')) {
  set asdf_data_dir = $E:ASDF_DATA_DIR
}

if (not (has-value $paths $asdf_data_dir'/shims')) {
  set paths = [$path $@paths]
}
```

###### カスタムデータディレクトリの設定(オプション)

カスタムデータディレクトリを設定するには、上記のスニペットの以下の行を変更してください:

```diff
-var asdf_data_dir = ~'/.asdf'
+var asdf_data_dir = '/your/custom/data/dir'
```

##### シェルのコマンド補完設定(オプション)

```shell
$ asdf completion elvish >> ~/.config/elvish/rc.elv
$ echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

:::

::: details ZSH

**Pacman**: コマンド補完はZSHから使いやすい場所に配置されますが、[自動補完を使うにはZSHの設定で有効化する必要があります](https://wiki.archlinux.jp/index.php/Zsh#.E3.82.B3.E3.83.9E.E3.83.B3.E3.83.89.E8.A3.9C.E5.AE.8C)。

##### shimsディレクトリをパスに追加する(必須)

`~/.zshrc`に以下を追記します:

```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### カスタムデータディレクトリの設定(オプション)

`~/.zshrc`に以下を追記します(先述したパス追加よりも上の行に書くこと):

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
```

##### シェルのコマンド補完設定(オプション)

コマンド補完はZSHフレームワークの`asdf`プラグイン（[asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf)のようなもの）を使用するか、以下の手順で設定します:

```shell
$ mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
$ asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
```

その場合は`.zshrc`に以下を追記します:

```shell
# append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
```

**備考**

ZSHフレームワークでカスタムされた`compinit`セットアップを使っている場合は、`compinit`がフレームワークのソース配下にあることを確認してください。

コマンド補完はZSHフレームワークの`asdf`で設定するか、[Homebrewの指示に従って設定](https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh)する必要があります。ZSHフレームワークを使っている場合、asdf用のプラグインを更新して`fpath`経由で新しいZSH補完機能を正しく使えるようにする必要があるかもしれません。なお、Oh-My-ZSH asdfプラグインはまだ対応していません。[ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837) を参照してください。
:::

::: details PowerShell Core

##### shimsディレクトリをパスに追加する(必須)

`~/.config/powershell/profile.ps1`に以下を追記します:
```shell
# Determine the location of the shims directory
if ($null -eq $ASDF_DATA_DIR -or $ASDF_DATA_DIR -eq '') {
  $_asdf_shims = "${env:HOME}/.asdf/shims"
}
else {
  $_asdf_shims = "$ASDF_DATA_DIR/shims"
}

# Then add it to path
$env:PATH = "${_asdf_shims}:${env:PATH}"
```

###### カスタムデータディレクトリの設定(オプション)

`~/.config/powershell/profile.ps1`に以下を追記します(先述したスニペットよりも上の行に書くこと):

```shell
$env:ASDF_DATA_DIR = "/your/custom/data/dir"
```

PowerShellはコマンド補完に対応していません。

:::

::: details Nushell

##### shimsディレクトリをパスに追加する(必須)

`~/.config/nushell/config.nu`に以下を追記します:

```shell
let shims_dir = (
  if ( $env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  } | path join 'shims'
)
$env.PATH = ( $env.PATH | split row (char esep) | where { |p| $p != $shims_dir } | prepend $shims_dir )
```

###### カスタムデータディレクトリの設定(オプション)

`~/.config/nushell/config.nu`に以下を追記します(先述したパス追加よりも上の行に書くこと)：

```shell
$env.ASDF_DATA_DIR = "/your/custom/data/dir"
```

##### シェルのコマンド補完設定(オプション)

```shell
# If you've not customized the asdf data directory:
$ mkdir $"($env.HOME)/.asdf/completions"
$ asdf completion nushell | save $"($env.HOME)/.asdf/completions/nushell.nu"

# If you have customized the data directory by setting ASDF_DATA_DIR:
$ mkdir $"($env.ASDF_DATA_DIR)/completions"
$ asdf completion nushell | save $"($env.ASDF_DATA_DIR)/completions/nushell.nu"
```

次に、`~/.config/nushell/config.nu`に以下を追記します:

```shell
let asdf_data_dir = (
  if ( $env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  }
)
. "$asdf_data_dir/completions/nushell.nu"
```

:::

::: details POSIX Shell

##### shimsディレクトリをパスに追加する(必須)

`~/.profile`に以下を追記します:
```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### カスタムデータディレクトリの設定(オプション)

`~/.profile`に以下を追記します(先述したパス追加よりも上の行に書くこと):

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
```

:::

`asdf`のスクリプトは、`$PATH`を設定した**あと**、かつ、使用中のフレームワーク(oh-my-zsh など)を呼び出した**あと**に記述する必要があります。

`PATH`の変更を反映するために、シェルを再起動してください。たいていの場合、ターミナルのタブを新たに開けばOKです。


## コアのインストールが完了！

これで、`asdf`のコアのインストールは完了です :tada:

しかし、`asdf`が役に立つようになるのは、**プラグイン**をインストールしてから**ツール**をインストールし、**バージョン**を管理するようになってからです。引き続き、ガイドを進めていきましょう。

## 4. プラグインのインストール

ここではデモとして、[`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/)プラグインを使用して[Node.js](https://nodejs.org/)をインストール・設定してみましょう。

### プラグインの依存関係

各プラグインには依存関係があるため、プラグインのリポジトリを確認しておきましょう。`asdf-nodejs`の場合、必要なものは次のとおりです:

| OS                             | 依存関係インストールコマンド            |
| ------------------------------ | --------------------------------------- |
| Debian                         | `apt-get install dirmngr gpg curl gawk` |
| CentOS/ Rocky Linux/ AlmaLinux | `yum install gnupg2 curl gawk`          |
| macOS                          | `brew install gpg gawk`                 |

一部のプラグインではインストール後の事後処理でこれらの依存関係が必要となるため、あらかじめインストールしておきましょう。

### プラグインのインストール

```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## 5. 特定のバージョンのインストール

Node.js用のプラグインをインストールしたので、このツールの特定のバージョンをインストールしましょう。

インストール可能なバージョンは`asdf list all nodejs`コマンドで確認できますし、特定のメジャーバージョンのサブセットは`asdf list all nodejs 14`コマンドで確認できます。

最新版をインストールするには、次のコマンドを実行します:

```shell
asdf install nodejs latest
```

::: tip 備考
`asdf`では正確なバージョン番号を指定してください。`latest`は、現時点での最新バージョンを指定できる`asdf`のヘルパーです。
:::

## 6. バージョンをセット

`asdf`は、カレントディレクトリから上位の`$HOME`ディレクトリまでに存在するすべての`.tool-versions`ファイルをもとに、ツールのバージョンを照会します。照会は、`asdf`で管理するツールを実行した際に、ジャストインタイムで行われます。

::: warning 警告
ツールで指定されたバージョンが見つからない場合、**エラー**が発生します。`asdf current`コマンドを実行すると、カレントディレクトリにおいてツールのバージョンを解決可能か確認できるため、どのツールが実行に失敗するか検証することができます。
:::

asdfはまずカレントディレクトリにある `.tool-versions` ファイルを探し、見つからなければ親ディレクトリを参照し `.tool-versions` ファイルが見つかるまでファイルツリーの上位階層を探索します。`.tool-versions`ファイルが見つからない場合、バージョン解決処理は失敗し、エラーが表示されます。

すべてのディレクトリに適用されるデフォルトのバージョンを設定したい場合、`$HOME/.tool-versions`にバージョンを設定できます。特定のディレクトリで別のバージョンを設定しない限り、ホームディレクトリ以下のすべてのディレクトリに同じバージョンが設定されるようになります。

```shell
asdf set -u nodejs 16.5.0
```

`$HOME/.tool-versions`は次のようになります:

```
nodejs 16.5.0
```

一部のOSでは、`python`のように、`asdf`ではなくシステムが管理するツールが既にインストールされていることがあります。それを使用する場合、`asdf`に対して、バージョン管理をシステムに委任するように指示する必要があります。詳しくは、[バージョンのリファレンス](/ja-jp/manage/versions.md)をご覧ください。

asdfが最初にバージョンを探す場所は、現在の作業ディレクトリ（`$PWD/.tool-versions`）です。これはプロジェクトのソースコードやGitリポジトリを含むディレクトリです。目的のディレクトリで`asdf set`を実行すると、バージョンを設定することができます:

```shell
asdf set nodejs 16.5.0
```

`$PWD/.tool-versions`は次のようになります:

```
nodejs 16.5.0
```

### ツールごとに用意された既存バージョンファイルの利用

`asdf`は、他のバージョンマネージャ向けに作られた既存のバージョンファイル(例: `rbenv`の場合は`.ruby-version`ファイル)からの移行をサポートしています。これはプラグイン単位でのサポートです。

[`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/)であれば、`.nvmrc`ファイルと`.node-version`ファイルの両方に対応しています。このサポートを有効にするには、`asdf`の構成設定ファイルである`$HOME/.asdfrc`内に、下記の行を追記してください:

```
legacy_version_file = yes
```

構成設定でのその他のオプションについて詳しくは、[構成設定](/ja-jp/manage/configuration.md)のリファレンスをご覧ください。

## 入門完了！

以上で、`asdf`の入門は完了です:tada: ここまでで、プロジェクトでの`nodejs`のバージョン管理ができるようになりました。プロジェクトで使用するツールごとに、同様の手順を実施してください!

`asdf`には使いこなすと便利なコマンドが他にもいっぱいあり、`asdf --help`コマンドまたは単に`asdf`コマンドを実行すれば、すべてのコマンドの説明を見ることができます。コマンドは大きく分けて3つのカテゴリに分けられます:

- [`asdf`のコア](/ja-jp/manage/core.md)
- [プラグイン](/ja-jp/manage/plugins.md)
- [ツールのバージョン](/ja-jp/manage/versions.md)

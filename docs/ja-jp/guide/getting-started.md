# はじめよう

`asdf`のインストールには次の手順が必要です:

1. 依存関係のインストール
2. `asdf`コアのダウンロード
3. `asdf`のインストール
4. 管理したいツール/ランタイムごとにプラグインをインストール
5. ツール/ランタイムの特定バージョンをインストール
6. `.tool-versions`ファイルで、グローバルまたはプロジェクトのバージョンをセット

## 1. 依存関係のインストール

asdfの動作には`git`および`curl`が必要です。以下の表は、 _あなたが使用している_ パッケージマネージャで実行するコマンドの _一部例_ です(some might automatically install these tools in later steps)。

| OS    | パッケージマネージャ | コマンド                           |
| ----- | -------------------- | ---------------------------------- |
| linux | Aptitude             | `apt install curl git`             |
| linux | DNF                  | `dnf install curl git`             |
| linux | Pacman               | `pacman -S curl git`               |
| linux | Zypper               | `zypper install curl git`          |
| macOS | Homebrew             | `brew install coreutils curl git`  |
| macOS | Spack                | `spack install coreutils curl git` |

::: tip 備考

お使いのシステムの構成によっては、接頭に`sudo`が必要となる場合もあります。

:::

## 2. asdfのダウンロード

### 公式ダウンロード

<!-- x-release-please-start-version -->

```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1

```

<!-- x-release-please-end -->

### コミュニティがサポートするダウンロード方法

理由がない限り、`git`コマンドを使用した公式ダウンロードの手順を使用することを強く推奨します。

| 方法     | コマンド                                                                                                                                                         |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Homebrew | `brew install asdf`                                                                                                                                              |
| Pacman   | `git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si` または好みの[AURヘルパー](https://wiki.archlinux.jp/index.php/AUR_ヘルパー)を使用 |

## 3. asdfのインストール

あなたが使用しているシェル、OS、およびインストール方法によって、ここでの設定方法が変わります。最も適したものを選択してください。

**masOSユーザの方は、この節の最後にある`path_helper`に関する警告を必ず参照してください。**

::: details Bash & Git

`~/.bashrc`に下記の行を追記します:

```shell
. "$HOME/.asdf/asdf.sh"
```

コマンド補完が必要な場合は、`.bashrc`に下記の行を追記します:

```shell
. "$HOME/.asdf/completions/asdf.bash"
```

:::

::: details Bash & Git (macOS)

**macOS Catalina以降**を使用している場合、デフォルトのシェルは**ZSH**です。Bashに変更していない限り、ZSHの手順を参照してください。

`~/.bash_profile`に下記の行を追記します:

```shell
. "$HOME/.asdf/asdf.sh"
```

コマンド補完が必要な場合は、`.bash_profile`に下記の行を追記します:

```shell
. "$HOME/.asdf/completions/asdf.bash"
```

:::

::: details Bash & Homebrew

下記コマンドで、`~/.bashrc`に`asdf.sh`を追加します:

```shell
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.bashrc
```

コマンド補完が必要な場合は、[Homebrewのガイドに従って設定を完了させる](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash)か、下記コマンドを実行します:

```shell
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bashrc
```

:::

::: details Bash & Homebrew (macOS)

**macOS Catalina以降**を使用している場合、デフォルトのシェルは**ZSH**です。Bashに変更していない限り、ZSHの手順を参照してください。

下記コマンドで、`~/.bash_profile`に`asdf.sh`を追加します:

```shell
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.bash_profile
```

コマンド補完が必要な場合は、[Homebrewのガイドに従って設定を完了させる](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash)か、下記コマンドを実行します:

```shell
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bash_profile
```

:::

::: details Bash & Pacman

`~/.bashrc`に下記の行を追記します:

```shell
. /opt/asdf-vm/asdf.sh
```

コマンド補完が必要な場合は、[`bash-completion`](https://wiki.archlinux.jp/index.php/Bash#プログラムとオプションを追加)をインストールします。
:::

::: details Fish & Git

`~/.config/fish/config.fish`に下記の行を追記します:

```shell
source ~/.asdf/asdf.fish
```

コマンド補完が必要な場合は、下記コマンドを実行します:

```shell
mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

:::

::: details Fish & Homebrew

下記コマンドで、`~/.config/fish/config.fish`に`asdf.sh`を追加します:

```shell
echo -e "\nsource "(brew --prefix asdf)"/libexec/asdf.fish" >> ~/.config/fish/config.fish
```

コマンド補完は、[Fish shellのHomebrewが担います](https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish)。親切ですね!
:::

::: details Fish & Pacman

`~/.config/fish/config.fish`に下記の行を追記します:

```shell
source /opt/asdf-vm/asdf.fish
```

コマンド補完は、AURパッケージのインストール時に自動的に設定されます。
:::

::: details Elvish & Git

下記コマンドで、`~/.config/elvish/rc.elv`に`asdf.elv`を追加します:

```shell
mkdir -p ~/.config/elvish/lib; ln -s ~/.asdf/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

コマンド補完は自動的に設定されます。

:::

::: details Elvish & Homebrew

下記コマンドで、`~/.config/elvish/rc.elv`に`asdf.elv`を追加します:

```shell
mkdir -p ~/.config/elvish/lib; ln -s (brew --prefix asdf)/libexec/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

コマンド補完は自動的に設定されます。
:::

::: details Elvish & Pacman

下記コマンドで、`~/.config/elvish/rc.elv`に`asdf.elv`を追加します:

```shell
mkdir -p ~/.config/elvish/lib; ln -s /opt/asdf-vm/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

コマンド補完は自動的に設定されます。
:::

::: details ZSH & Git

`~/.zshrc`に下記の行を追記します:

```shell
. "$HOME/.asdf/asdf.sh"
```

**または**、[asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf)のようなZSHフレームワークプラグインを使用して、このスクリプトをsourceし、コマンド補完をセットアップします。

コマンド補完は、ZSHフレームワークの`asdf`プラグインで設定するか、`~/.zshrc`に下記の行を追記することで設定できます:

```shell
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
```

- `compinit`のセットアップをカスタマイズしている場合は、`asdf.sh`ソース以下に`compinit`がくるようにしてください。
- ZSHフレームワークで`compinit`のセットアップをカスタマイズしている場合は、フレームワークソース以下に`compinit`がくるようにしてください。

**警告**

ZSHフレームワークを使用している場合、新しいZSHコマンド補完を使用するには、`fpath`経由で、関連する`asdf`プラグインの更新が必要となることがあります。Oh-My-ZSH asdfプラグインは、[ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837)でご覧いただくと分かるとおり、まだ更新されていません。
:::

::: details ZSH & Homebrew

下記コマンドで、`~/.zshrc`に`asdf.sh`を追加します:

```shell
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
```

**OR** use a ZSH Framework plugin like [asdf for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf) which will source this script and setup completions.

コマンド補完は、ZSHフレームワーク`asdf`によって設定されるか、[Homebrewの説明に従って設定](https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh)必要があります。ZSHフレームワークを使用している場合、新しいZSHコマンド補完を使用するには、`fpath`経由で、関連する`asdf`プラグインの更新が必要となることがあります。Oh-My-ZSH asdfプラグインは、[ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837)でご覧いただくと分かるとおり、まだ更新されていません。
:::

::: details ZSH & Pacman

`~/.zshrc`に下記の行を追記します:

```shell
. /opt/asdf-vm/asdf.sh
```

コマンド補完は、ZSHに適した場所に配置されますが、[オートコンプリートを使用するようにZSHを設定する必要があります](https://wiki.archlinux.jp/index.php/Zsh#.E3.82.B3.E3.83.9E.E3.83.B3.E3.83.89.E8.A3.9C.E5.AE.8C)。
:::

::: details PowerShell Core & Git

`~/.config/powershell/profile.ps1`に下記の行を追記します:

```shell
. "$HOME/.asdf/asdf.ps1"
```

:::

::: details PowerShell Core & Homebrew

下記コマンドで、`~/.config/powershell/profile.ps1`に`asdf.sh`を追加します:

```shell
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.ps1\"" >> ~/.config/powershell/profile.ps1
```

:::

::: details PowerShell Core & Pacman

`~/.config/powershell/profile.ps1`に下記の行を追記します:

```shell
. /opt/asdf-vm/asdf.ps1
```

:::

::: details Nushell & Git

下記コマンドで、`~/.config/nushell/config.nu`に`asdf.nu`を追加します:

```shell
"\n$env.ASDF_NU_DIR = ($env.HOME | path join '.asdf')\n source " + ($env.HOME | path join '.asdf/asdf.nu') | save --append $nu.config-path
```

コマンド補完は自動的に設定されます。
:::

::: details Nushell & Homebrew

下記コマンドで、`~/.config/nushell/config.nu`に`asdf.nu`を追加します:

```shell
"\n$env.ASDF_NU_DIR = (brew --prefix asdf | str trim | into string | path join 'libexec')\n source " +  (brew --prefix asdf | into string | path join 'libexec/asdf.nu') | save --append $nu.config-path
```

コマンド補完は自動的に設定されます。
:::

::: details Nushell & Pacman

下記コマンドで、`~/.config/nushell/config.nu`に`asdf.nu`を追加します:

```shell
"\n$env.ASDF_NU_DIR = '/opt/asdf-vm/'\n source /opt/asdf-vm/asdf.nu" | save --append $nu.config-path
```

コマンド補完は自動的に設定されます。
:::

::: details POSIX Shell & Git

`~/.profile`に下記の行を追記します:

```shell
export ASDF_DIR="$HOME/.asdf"
. "$HOME/.asdf/asdf.sh"
```

:::

::: details POSIX Shell & Homebrew

下記コマンドで、`~/.profile`に`asdf.sh`を追加します:

```shell
echo -e "\nexport ASDF_DIR=\"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.profile
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.profile
```

:::

::: details POSIX Shell & Pacman

`~/.profile`に下記の行を追記します:

```shell
export ASDF_DIR="/opt/asdf-vm"
. /opt/asdf-vm/asdf.sh
```

:::

`asdf`のスクリプトは、`$PATH`を設定した**あと**、かつ、使用中のフレームワーク(oh-my-zsh など)を呼び出した**あと**に記述する必要があります。

::: warning 警告
macOSでは、BasgまたはZSHシェルを起動すると、自動的に`path_helper`というユーティリティが呼び出されます。`path_helper`は`PATH`(および`MANPATH`)内の項目の順番を並び替えることができるため、特定の順序を必要とするツールの動作に、一貫性が無くなってしまいます。これを回避するため、macOSで`asdf`を利用するときは、強制的に`PATH`エントリの先頭に追加する(優先度を一番高くする)ようにしてください。これは、`ASDF_FORCE_PREPEND`環境変数で制御できます。
:::

`PATH`の変更を反映するために、シェルを再起動してください。たいていの場合、ターミナルのタブを新たに開けばOKです。

## コアのインストールが完了!

これで、`asdf`のコアのインストールは完了です:tada:

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

### グローバル

グローバルのデフォルト設定は、`$HOME/.tool-versions`で管理されます。グローバルのバージョンをセットするには、次のコマンドを実行します:

```shell
asdf global nodejs latest
```

すると、`$HOME/.tool-versions`内には次のように書き込まれます:

```
nodejs 16.5.0
```

一部のOSでは、`python`のように、`asdf`ではなくシステムが管理するツールが既にインストールされていることがあります。それを使用する場合、`asdf`に対して、バージョン管理をシステムに委任するように指示する必要があります。詳しくは、[バージョンのリファレンス](/ja-jp/manage/versions.md)をご覧ください。

### ローカル

ローカルのバージョン設定は、`$PWD/.tool-versions`ファイル(カレントディレクトリ内)で定義されます。たいていの場合は、プロジェクトのGitリポジトリ内となるでしょう。対象となるディレクトリで、下記コマンドを実行します:

```shell
asdf local nodejs latest
```

すると、`$PWD/.tool-versions`内には次のように書き込まれます:

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

## 入門完了!

以上で、`asdf`の入門は完了です:tada: ここまでで、プロジェクトでの`nodejs`のバージョン管理ができるようになりました。プロジェクトで使用するツールごとに、同様の手順を実施してください!

`asdf`には使いこなすと便利なコマンドが他にもいっぱいあり、`asdf --help`コマンドまたは単に`asdf`コマンドを実行すれば、すべてのコマンドの説明を見ることができます。コマンドは大きく分けて3つのカテゴリに分けられます:

- [`asdf`のコア](/ja-jp/manage/core.md)
- [プラグイン](/ja-jp/manage/plugins.md)
- [ツールのバージョン](/ja-jp/manage/versions.md)

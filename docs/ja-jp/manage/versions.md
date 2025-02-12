# バージョン

## バージョンのインストール

```shell
asdf install <name> <version>
# asdf install erlang 17.3
```

プラグインが、ソースコードからのダウンロード・コンパイルをサポートしている場合、`ref:foo`の形式(`foo`は特定のブランチ、タグ、またはコミット)でバージョンを指定できます。アンインストールするときも、同じ名前とバージョンを指定する必要があります。

## 最新安定バージョンのインストール

```shell
asdf install <name> latest
# asdf install erlang latest
```

下記のように、特定のプレフィックスでの最新安定バージョンをインストールすることもできます。

```shell
asdf install <name> latest:<version>
# asdf install erlang latest:17
```

## インストール済みバージョン一覧

```shell
asdf list <name>
# asdf list erlang
```

下記のように、特定のプレフィックスでのバージョンでフィルタすることもできます。

```shell
asdf list <name> <version>
# asdf list erlang 17
```

## インストール可能な全バージョン一覧

```shell
asdf list all <name>
# asdf list all erlang
```

下記のように、特定のプレフィックスでのバージョンでフィルタすることもできます。

```shell
asdf list all <name> <version>
# asdf list all erlang 17
```

## 最新安定バージョンの表示

```shell
asdf latest <name>
# asdf latest erlang
```

下記のように、特定のプレフィックスでの最新安定バージョンで表示することもできます。

```shell
asdf latest <name> <version>
# asdf latest erlang 17
```

## バージョンのセット

#### `.tool-versions`ファイルで管理する

```shell
asdf set [flags] <name> <version> [<version>...]
# asdf set elixir 1.2.4 # set in current dir
# asdf set -u elixir 1.2.4 # set in .tool-versions file in home directory
# asdf set -p elixir 1.2.4 # set in existing .tool-versions file in a parent dir

asdf set <name> latest[:<version>]
# asdf set elixir latest
```

`asdf set`はカレントディレクトリの`.tool-versions`ファイルにバージョンを書き込みます。これは単純に利便性のために存在します。`echo "<tool> <version>" > .tool-versions`を実行するようなものと考えてください。

`u` または `--home`フラグをつけて`asdf set`を実行すると、`$HOME`ディレクトリの`.tool-versions`ファイルにバージョンを書き込みます。ファイルが存在しない場合は作成されます。

`p`または `--parent`フラグをつけて`asdf set`を実行すると、カレントディレクトリから親ディレクトリを探索し、最初に見つかった`.tool-versions` ファイルにバージョンを書き込みます。

#### 環境変数で管理する

バージョンを決定するときに、`ASDF_${TOOL}_VERSION`というパターンの環境変数を探します。バージョンの形式は`.tool-versions`ファイルでサポートされているものと同じです。設定されている場合、この環境変数の値は`.tool-versions`ファイルでのバージョン指定よりも優先されます。たとえば:

```shell
export ASDF_ELIXIR_VERSION=1.18.1
```

これは現在のシェルセッションではElixir `1.18.1`を使うようasdfに指示します。

:::warning
これは環境変数なので、設定されたセッションでのみ有効になります。
実行中の他のセッションでは、`.tool-versions`ファイルに設定されているバージョンを引き続き使用します。

`.tool-versions`ファイルについて詳しくは、[構成設定のリファレンス](/ja-jp/manage/configuration.md)をご覧ください。

:::

下記の例では、バージョン`1.4.0`のElixirプロジェクトに対して、テストを実行させています。

```shell
ASDF_ELIXIR_VERSION=1.4.0 mix test
```

## システムバージョンへの委任

asdfで管理されているバージョンではなく、`<name>`で指定されたツールのシステムバージョンを使用するには、バージョンとして`system`を指定します。

[バージョンのセット](#バージョンのセット)と同様に、`asdf set`または環境変数で`system`をセットしてください。

```shell
asdf set <name> system
# asdf set python system
```

## カレントバージョンの表示

```shell
asdf current
# asdf current
# erlang          17.3          /Users/kim/.tool-versions
# nodejs          6.11.5        /Users/kim/cool-node-project/.tool-versions

asdf current <name>
# asdf current erlang
# erlang          17.3          /Users/kim/.tool-versions
```

## バージョンのアンインストール

```shell
asdf uninstall <name> <version>
# asdf uninstall erlang 17.3
```

## Shims

asdfがパッケージをインストールすると、そのパッケージに含まれるすべての実行プログラムのShimが`$ASDF_DATA_DIR/shims`ディレクトリ(デフォルトは`~/.asdf/shims`)に作成されます。このディレクトリが(`asdf.sh`や`asdf.fish`などによって)`$PATH`に設定されることで、インストールされているプログラムが当該環境で利用できるようになります。

Shim自体は非常に単純なラッパーであり、`asdf exec`というヘルパープログラムに、プラグイン名と、Shimがラップしているインストール済みパッケージの実行ファイルのパスを渡して、`exec`します。

`asdf exec`ヘルパーは、使用するパッケージのバージョン(`.tool-versions`ファイルで指定されたもの、または環境変数で指定されたもの)、パッケージのインストールディレクトリにある実行ファイルの完全パス(プラグインの`exec-path`コールバックで操作可能)、および実行環境(プラグインの`exec-env`スクリプトで提供)を決定し、実行します。

::: warning 備考
本システムは`exec`呼び出しを使用するため、シェルによってsourceされるパッケージ内のスクリプトは、Shimラッパーを経由させずに直接アクセスする必要があります。`asdf`で用意されている`which`および`where`コマンドは、下記のように、インストールされたパッケージへのパスを返すため、この状況を解決するのに役立ちます:
:::

```shell
# returns path to main executable in current version
source $(asdf which ${PLUGIN})/../script.sh

# returns path to the package installation directory
source $(asdf where ${PLUGIN})/bin/script.sh
```

### asdfのShimのバイパス

何らかの理由でasdfのShimをバイパスしたい場合や、プロジェクトのディレクトリに移動した際に自動的に環境変数を設定したい場合は、[asdf-direnv](https://github.com/asdf-community/asdf-direnv)プラグインが役に立ちます。詳細はREADMEをご確認ください。

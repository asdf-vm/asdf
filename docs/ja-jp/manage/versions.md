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

## カレントバージョンのセット

```shell
asdf global <name> <version> [<version>...]
asdf shell <name> <version> [<version>...]
asdf local <name> <version> [<version>...]
# asdf global elixir 1.2.4

asdf global <name> latest[:<version>]
asdf local <name> latest[:<version>]
# asdf global elixir latest
```

`global`の場合、バージョンは`$HOME/.tool-versions`ファイルに書き込まれます。

`shell`の場合、バージョンは`ASDF_${TOOL}_VERSION`という環境変数に設定され、現在のシェルセッションでのみ有効となります。

`local`の場合、バージョンは`$PWD/.tool-versions`ファイルに書き込まれます。存在しない場合は作成されます。

`.tool-versions`ファイルについて詳しくは、[構成設定のリファレンス](/ja-jp/manage/configuration.md)をご覧ください。

:::warning 代替手段
現在のシェルセッションでのみバージョンを設定したい場合、
または、特定のツールバージョンでコマンドを実行するだけのためにバージョンを設定したい場合は、
`ASDF_${TOOL}_VERSION`という環境変数で設定することができます。
:::

下記の例では、バージョン`1.4.0`のElixirプロジェクトに対して、テストを実行させています。
バージョンの表記形式は、`.tool-versions`ファイルでサポートされているものと同じです。

```shell
ASDF_ELIXIR_VERSION=1.4.0 mix test
```

## システムバージョンへの委任

asdfで管理されているバージョンではなく、`<name>`で指定されたツールのシステムバージョンを使用するには、バージョンとして`system`を指定します。

[カレントバージョンのセット](#カレントバージョンのセット)と同様の方法で、`global`、`local`、または`shell`のいずれかに`system`をセットしてください。

```shell
asdf local <name> system
# asdf local python system
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

`asdf exec`ヘルパーは、使用するパッケージのバージョン(`.tool-versions`ファイルで指定されたもの、または`asdf local ...`か`asdf global ...`で指定されたもの)、パッケージのインストールディレクトリにある実行ファイルの完全パス(プラグインの`exec-path`コールバックで操作可能)、および実行環境(プラグインの`exec-env`スクリプトで提供)を決定し、実行します。

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

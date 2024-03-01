# 構成設定

`asdf`の構成設定には、他人と共有可能な`.tool-versions`ファイルと、`.asdfrc`や環境変数によってカスタマイズ可能なユーザ固有の設定とがあります。

## `.tool-versions`

`.tool-versions`ファイルがディレクトリに存在する場合、当該ディレクトリおよびサブディレクトリで、ファイル内で宣言しているツールのバージョンが使用されます。

::: warning 備考

グローバルのデフォルト値は、`$HOME/.tool-versions`ファイルで設定できます。

:::

`.tool-versions`ファイル内は下記のような記述となっています:

```
ruby 2.5.3
nodejs 10.15.0
```

コメントを含めることもできます:

```
ruby 2.5.3 # This is a comment
# This is another comment
nodejs 10.15.0
```

バージョンの表記は下記の形式があります:

- `10.15.0` - 実バージョンの表記です。バイナリのダウンロードに対応しているプラグインの場合、バイナリがダウンロードされます。
- `ref:v1.0.2-a` or `ref:39cb398vb39` - 指定されたタグ/コミット/ブランチをgithubからダウンロードし、コンパイルされます。
- `path:~/src/elixir` - 使用するツールをカスタムコンパイルしたバージョンへのパスです。言語開発者などが使用します。
- `system` - このキーワードを指定した場合、asdfが管理していない、システム上のツールバージョンへパススルーします。

::: tip ヒント

スペースで区切れば、複数のバージョンを指定できます。例えば、Python `3.7.2`を使用し、Python `2.7.15`にフォールバックし、最終的に`system`のPythonにフォールバックさせるには、`.tool-versions`に下記の行を追記します。

```
python 3.7.2 2.7.15 system
```

:::

`.tool-versions`ファイルで定義されているすべてのツールをインストールするには、`.tool-versions`ファイルを含むディレクトリで、`asdf install`コマンドを引数を指定せずに実行します。

`.tool-versions`ファイルで定義されている単一のツールをインストールするには、`.tool-versions`ファイルを含むディレクトリで、`asdf install <name>`コマンドを実行します。ツールは、`.tool-versions`ファイルで指定されたバージョンでインストールされます。

ファイルは、直接編集するか、`asdf local`コマンド(または`asdf global`コマンド)を使用して更新してください。

## `.asdfrc`

`.asdfrc`では、ユーザのマシン固有の構成を設定します。

asdfはデフォルトで`${HOME}/.asdfrc`に構成ファイルを配置します。ファイルの場所は、[`ASDF_CONFIG_FILE`環境変数](#asdf-config-file)で設定できます。

下記は、構成に必要な項目とそのデフォルト値を示しています:

```txt
legacy_version_file = no
use_release_candidates = no
always_keep_download = no
plugin_repository_last_check_duration = 60
disable_plugin_short_name_repository = no
concurrency = auto
```

### `legacy_version_file`

**対応している**プラグインの場合、他のバージョンマネージャで使用されているバージョンファイルを読み込むことができます。例えば、Rubyの`rbenv`であれば`.ruby-version`ファイルを読み込みます。

| オプション                                                    | 説明                                                                                                        |
| :------------------------------------------------------------ | :---------------------------------------------------------------------------------------------------------- |
| `no` <Badge type="tip" text="デフォルト" vertical="middle" /> | バージョンの読み込みには`.tool-versions`を使用します                                                        |
| `yes`                                                         | 利用可能なレガシーバージョンファイル(`.ruby-version`など)がある場合、プラグインのフォールバックで使用します |

### `use_release_candidates`

`asdf update`コマンドでasdfを更新する際に、最新リリースではなく、リリース候補版へ更新するか制御します。

| オプション                                                    | 説明                       |
| :------------------------------------------------------------ | :------------------------- |
| `no` <Badge type="tip" text="デフォルト" vertical="middle" /> | 最新リリースを使用します   |
| `yes`                                                         | リリース候補版を使用します |

### `always_keep_download`

`asdf install`コマンドでダウンロードしたソースコードやバイナリを、保持しておくか削除するかを制御します。

| オプション                                                    | 説明                                                         |
| :------------------------------------------------------------ | :----------------------------------------------------------- |
| `no` <Badge type="tip" text="デフォルト" vertical="middle" /> | インストールが成功したら、ソースコードやバイナリを削除します |
| `yes`                                                         | インストール後も、ソースコードやバイナリを保持します         |

### `plugin_repository_last_check_duration`

asdfプラグインリポジトリの同期間隔(分)を制御します。何らかのトリガーイベントが発生した際に、最後に同期した時刻からの経過時間をチェックします。設定された間隔以上の時間が経過していた倍は、新たに同期が開始されます。

| オプション                                                                                          | 説明                                                                                 |
| :-------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------- |
| `1`から`999999999`までの整数値 <br/> <Badge type="tip" text="デフォルト" vertical="middle" />は`60` | 最後に同期した時刻から指定時間(分)以上経過していた場合、トリガーイベントで同期します |
| `0`                                                                                                 | トリガーイベントのたびに同期します                                                   |
| `never`                                                                                             | 同期しません                                                                         |

同期は、以下のコマンドが実行されたときに発生します:

- `asdf plugin add <name>`
- `asdf plugin list all`

`asdf plugin add <name> <git-url>`コマンドでは、プラグインの同期はトリガーされません。

::: warning 備考

値を`never`にしても、プラグインリポジトリの初期同期は停止されません。この動作については、`disable_plugin_short_name_repository`の節をご覧ください。

:::

### `disable_plugin_short_name_repository`

asdfプラグインのショートネームリポジトリの同期を無効化します。ショートネームリポジトリが無効となっている場合、同期イベントはすぐに終了します。

| オプション                                                    | 説明                                                                           |
| :------------------------------------------------------------ | :----------------------------------------------------------------------------- |
| `no` <Badge type="tip" text="デフォルト" vertical="middle" /> | 同期イベントが発生した際に、asdfプラグインリポジトリをクローンまたは更新します |
| `yes`                                                         | プラグインショートネームリポジトリを無効化します                               |

同期は、以下のコマンドが実行されたときに発生します:

- `asdf plugin add <name>`
- `asdf plugin list all`

`asdf plugin add <name> <git-url>`コマンドでは、プラグインの同期はトリガーされません。

::: warning 備考

プラグインショートネームリポジトリを無効化しても、すでに同期されたリポジトリは削除されません。プラグインリポジトリを削除するには、`rm --recursive --trash $ASDF_DATA_DIR/repository`コマンドを実行してください。

また、プラグインショートネームリポジトリを無効化しても、以前にこのソースからインストールされたプラグインは削除されません。プラグインを削除するには、`asdf plugin remove <name>`コマンドを実行してください。プラグインを削除すると、そのプラグインでインストールされたすべてのツールバージョンが削除されます。

:::

### `concurrency`

コンパイル時に使用するデフォルトのコア数です。

| Options | Description                                                                         |
| :------ | :---------------------------------------------------------------------------------- |
| 整数値  | ソースコードのコンパイル時に使用するコア数です                                      |
| `auto`  | `nproc`、`sysctl hw.ncpu`、`/proc/cpuinfo`、または`1`、の優先順でコア数を計算します |

備考: `ASDF_CONCURRENCY`環境変数が設定されている場合はそちらが優先されます。

## 環境変数

環境変数の設定値は、お使いのシステムやシェルによって異なります。デフォルトロケーションは、インストールした場所や方法(Gitクローン、Homebrew、AUR)によって異なります。

環境変数は通常、`asdf.sh`/`asdf.fish`などをsourceする前に設定する必要があります。Elvishの場合は、`use asdf`の上側に設定します。

以下では、Bashシェルでの使用方法について説明します。

### `ASDF_CONFIG_FILE`

`.asdfrc`構成ファイルへのパスです。任意の場所に設定できます。必ず絶対パスで設定してください。

- 未設定の場合: `$HOME/.asdfrc`の値が使用されます。
- 使用方法: `export ASDF_CONFIG_FILE=/home/john_doe/.config/asdf/.asdfrc`

### `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME`

ツール名とバージョンの情報を格納するファイルのファイル名です。有効なファイル名であれば何でも設定できます。通常、`.tool-versions`ファイルを無視したい場合を除き、この値を変更するべきではありません。

- 未設定の場合: `.tool-versions`の値が使用されます。
- 使用方法: `export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=tool_versions`

### `ASDF_DIR`

`asdf`のコアスクリプト場所です。任意の場所に設定できます。必ず絶対パスで設定してください。

- 未設定の場合: `bin/asdf`実行ファイルの親ディレクトリが使用されます。
- 使用方法: `export ASDF_DIR=/home/john_doe/.config/asdf`

### `ASDF_DATA_DIR`

`asdf`がプラグイン、Shim、ツールのバージョンをインストールする場所です。任意の場所に設定できます。必ず絶対パスで設定してください。

- 未設定の場合: `$HOME/.asdf`ディレクトリが存在すればその場所、存在しない場合は`ASDF_DIR`の値を使用します。
- 使用方法: `export ASDF_DATA_DIR=/home/john_doe/.asdf`

### `ASDF_CONCURRENCY`

ソースコードのコンパイル時に使用するコア数です。この環境変数の値は、asdf構成ファイルの`concurrency`の値よりも優先されます。

- 未設定の場合: asdf構成ファイルの`concurrency`の値が使用されます。
- 使用方法: `export ASDF_CONCURRENCY=32`

### `ASDF_FORCE_PREPEND`

`asdf`のShimやパスのディレクトリを`PATH`の先頭(最高優先度)に追加するかどうかを設定します。

- 未設定の場合: macOSでのデフォルト値は`yes`、その他のシステムでのデフォルト値は`no`です。
- `yes`の場合: `asdf`ディレクトリを強制的に`PATH`の先頭に配置します。
- `yes`以外の文字列を設定した場合: `asdf`ディレクトリを強制的に`PATH`の先頭に配置することは _しません_ 。
- Usage: `ASDF_FORCE_PREPEND=no . "<path-to-asdf-directory>/asdf.sh"`

## 完全な構成の例

下記のように、asdfをシンプルにセットアップしたとします:

- Bashシェル
- インストール先は`$HOME/.asdf`
- Git経由でインストール
- 環境変数は何も設定していない
- `.asdfrc`ファイルは何もカスタマイズしていない

すると、結果として以下のような構成となります:

| 構成                                  | 値               | 値がセットされる過程                                                                                                                  |
| :------------------------------------ | :--------------- | :------------------------------------------------------------------------------------------------------------------------------------ |
| config file location                  | `$HOME/.asdfrc`  | `ASDF_CONFIG_FILE`は空なので、`$HOME/.asdfrc`が使用されます。                                                                         |
| default tool versions filename        | `.tool-versions` | `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME`は空なので、`.tool-versions`が使用されます。                                                     |
| asdf dir                              | `$HOME/.asdf`    | `ASDF_DIR`は空なので、`bin/asdf`の親ディレクトリが使用されます。                                                                      |
| asdf data dir                         | `$HOME/.asdf`    | `ASDF_DATA_DIR`は空であり、`$HOME`が存在するので、`$HOME/.asdf`が使用されます。                                                       |
| concurrency                           | `auto`           | `ASDF_CONCURRENCY`は空なので、[デフォルト構成](https://github.com/asdf-vm/asdf/blob/master/defaults)の`concurrency`の値に依存します。 |
| legacy_version_file                   | `no`             | `.asdfrc`をカスタマイズしていないので、[デフォルト構成](https://github.com/asdf-vm/asdf/blob/master/defaults)を使用します。           |
| use_release_candidates                | `no`             | `.asdfrc`をカスタマイズしていないので、[デフォルト構成](https://github.com/asdf-vm/asdf/blob/master/defaults)を使用します。           |
| always_keep_download                  | `no`             | `.asdfrc`をカスタマイズしていないので、[デフォルト構成](https://github.com/asdf-vm/asdf/blob/master/defaults)を使用します。           |
| plugin_repository_last_check_duration | `60`             | `.asdfrc`をカスタマイズしていないので、[デフォルト構成](https://github.com/asdf-vm/asdf/blob/master/defaults)を使用します。           |
| disable_plugin_short_name_repository  | `no`             | `.asdfrc`をカスタマイズしていないので、[デフォルト構成](https://github.com/asdf-vm/asdf/blob/master/defaults)を使用します。           |

## 内部構成

この節では、パッケージマネージャやインテグレータ向けの`asdf`の内部構成について記述しているため、ユーザが気にする必要はありません。

- `$ASDF_DIR/asdf_updates_disabled`: このファイルが存在する場合、`asdf update`コマンドによる更新は無効になります(ファイル内容は関係ありません)。これは、PacmanやHomebrewのようなパッケージマネージャによって使用され、特定のインストールに対して正しい更新方法を適用するようにします。

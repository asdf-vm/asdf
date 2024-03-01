# プラグインの作成

プラグインとは、
言語/ツールのバージョン管理をサポートするための実行スクリプトを含めたGitリポジトリのことです。
これらのスクリプトは、`asdf list-all <name>`や`asdf install <name> <version>`などの機能をサポートするコマンドを使って、
asdfによって実行されます。

## クイックスタート

オリジナルのプラグインを作成するには、次の2つの方法があります:

1. [asdf-vm/asdf-plugin-template](https://github.com/asdf-vm/asdf-plugin-template)リポジトリを使用し、
   デフォルトのスクリプトが実装されたプラグインリポジトリ(名前は`asdf-<tool_name>`)を
   [生成](https://github.com/asdf-vm/asdf-plugin-template/generate)
   します。
   生成できたら、
   そのリポジトリをクローンして`setup.bash`のスクリプトを実行し、
   テンプレートを対話的に更新していきます。
2. `asdf-<tool_name>`という名前のリポジトリを自分で立ち上げ、
   以降に記載されている必要なスクリプトを実装します。

### プラグインスクリプトの鉄則

- スクリプト内で他の`asdf`コマンドを呼び出しては**いけません**。
- シェルのツール/コマンドへの依存関係を小さく保つようにしてください。
- 移植性のないツールやコマンドフラグの使用は避けてください。
  例えば、`sort -V`などです。
  asdfコアの[禁止コマンド一覧](https://github.com/asdf-vm/asdf/blob/master/test/banned_commands.bats)もご覧ください。

## スクリプトの概要

以下は、asdfから呼び出せるスクリプトの全リストです。

| スクリプト                                                                                     | 説明                                                                         |
| :--------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------- |
| [bin/list-all](#bin-list-all) <Badge type="tip" text="必須" vertical="middle" />               | インストール可能なすべてのバージョンをリストします。                         |
| [bin/download](#bin-download) <Badge type="tip" text="必須" vertical="middle" />               | ツールの特定バージョンのソースコードまたはバイナリをダウンロードします。     |
| [bin/install](#bin-install) <Badge type="tip" text="必須" vertical="middle" />                 | ツールの特定バージョンをインストールします。                                 |
| [bin/latest-stable](#bin-latest-stable) <Badge type="warning" text="推奨" vertical="middle" /> | 指定されたツールの最新安定バージョンをリストします。                         |
| [bin/help.overview](#bin-help.overview)                                                        | プラグインおよびツールに関する概要説明を出力します。                         |
| [bin/help.deps](#bin-help.deps)                                                                | オペレーティングシステムに合わせた依存関係のリストを出力します。             |
| [bin/help.config](#bin-help.config)                                                            | プラグインおよびツールの構成設定一覧を出力します。                           |
| [bin/help.links](#bin-help.links)                                                              | プラグインとツールに関連するリンクリストを出力します。                       |
| [bin/list-bin-paths](#bin-list-bin-paths)                                                      | Shimを作成するバイナリが存在するディレクトリへの相対パスの一覧を出力します。 |
| [bin/exec-env](#bin-exec-env)                                                                  | ツールのバイナリのShimを実行する前に環境を準備します。                       |
| [bin/exec-path](#bin-exec-path)                                                                | ツールの特定バージョンの実行ファイルパスを出力します。                       |
| [bin/uninstall](#bin-uninstall)                                                                | ツールの特定バージョンをアンインストールします。                             |
| [bin/list-legacy-filenames](#bin-list-legacy-filenames)                                        | `.ruby-version`のような、レガシー構成ファイルのリストを出力します。          |
| [bin/parse-legacy-file](#bin-parse-legacy-file)                                                | レガシーバージョンファイルのカスタムパーサーです。                           |
| [bin/post-plugin-add](#bin-post-plugin-add)                                                    | プラグインが追加された後に実行されるフックです。                             |
| [bin/post-plugin-update](#bin-post-plugin-update)                                              | プラグインが更新された後に実行されるフックです。                             |
| [bin/pre-plugin-remove](#bin-pre-plugin-remove)                                                | プラグインが削除される前に実行されるフックです。                             |

どのコマンドがどのスクリプトを呼び出すかについては、
各スクリプトの詳細なドキュメントを参照してください。

## 環境変数の概要

以下は、すべてのスクリプトで使用される環境変数の全リストです。

| 環境変数                 | 説明                                                                                            |
| :----------------------- | :---------------------------------------------------------------------------------------------- |
| `ASDF_INSTALL_TYPE`      | `version`または`ref`です。                                                                      |
| `ASDF_INSTALL_VERSION`   | `ASDF_INSTALL_TYPE`に応じてフルバージョンナンバーまたはGit Refの値が入ります。                  |
| `ASDF_INSTALL_PATH`      | ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。      |
| `ASDF_CONCURRENCY`       | ソースコードのコンパイル時に使用するコア数です。`make -j`のようなフラグを設定する際に便利です。 |
| `ASDF_DOWNLOAD_PATH`     | `bin/download`によってソースコードまたはバイナリがダウンロードされる場所へのパスです。          |
| `ASDF_PLUGIN_PATH`       | プラグインがインストールされている場所へのパスです。                                            |
| `ASDF_PLUGIN_SOURCE_URL` | プラグインソースのURLです。                                                                     |
| `ASDF_PLUGIN_PREV_REF`   | プラグインの以前の`git-ref`です。                                                               |
| `ASDF_PLUGIN_POST_REF`   | 更新後のプラグインの`git-ref`です。                                                             |
| `ASDF_CMD_FILE`          | ソースとなるファイルのフルパスに解決されます。                                                  |

::: tip 備考

**すべてのスクリプトですべての環境変数が使用できるわけではありません。**
以下の各スクリプトのドキュメントで、そのスクリプトで利用可能な環境変数を確認してください。

:::

## 必須スクリプト

### `bin/list-all` <Badge type="tip" text="必須" vertical="middle" />

**説明**

インストール可能なすべてのバージョンをリストします。

**出力フォーマット**

**スペース区切り**のバージョンリストの文字列を出力する必要があります。例えば次のとおりです:

```txt
1.0.1 1.0.2 1.3.0 1.4
```

最新バージョンが末尾にくる必要があります。

asdfコアは各バージョンを1行ずつ表示するため、
いくつかのバージョンは画面外にはみ出る場合があります。

**並べ替え**

ウェブサイト上のリリースページからバージョンを取得する場合、
提供されている順序は正しいリリース順となっていることが多いため、
そのままの順序を使用することを推奨します。
逆順にしたければ、`tsc`をパイプで通すだけで十分です。

どうしても並べ替えが避けられない場合、`sort -V`は移植性が無いため、次のいずれかの方法を使用することを推奨します:

- [Git sort capabilityを使用する](https://github.com/asdf-vm/asdf-plugin-template/blob/main/template/lib/utils.bash)
  (Git `v2.18.0`以上が必要です)
- [カスタムソートメソッドを自分で書く](https://github.com/vic/asdf-idris/blob/master/bin/list-all#L6)
  (`sed`、`sort`、および`awk`が必要です)

**スクリプトで使用できる環境変数**

このスクリプトに環境変数は提供されません。

**このスクリプトを呼び出すコマンド**

- `asdf list all <name> [version]`
- `asdf list all nodejs`: このスクリプトで返されるすべてのバージョンを、
  1行ずつリストします。
- `asdf list all nodejs 18`: このスクリプトで返されるすべてのバージョンから、
  `18`で始まるバージョンのみフィルタし、1行ずつリストします。

**asdfからの呼び出しシグネチャ**

引数はありません。

```bash
"${plugin_path}/bin/list-all"
```

---

### `bin/download` <Badge type="tip" text="必須" vertical="middle" />

**説明**

ツールの特定バージョンのソースコードまたはバイナリを、指定された場所にダウンロードします。

**実装内容**

- スクリプトは、`ASDF_DOWNLOAD_PATH`で指定されたディレクトリに、ソースコードまたはバイナリをダウンロードする必要があります。
- 解凍されたソースコードまたはバイナリのみを、`ASDF_DOWNLOAD_PATH`ディレクトリに配置する必要があります。
- 失敗した場合、`ASDF_DOWNLOAD_PATH`ディレクトリ内に何もファイルを配置しないようにしてください。
- 成功した場合、終了コードは`0`としてください。
- 失敗した場合、終了コードは非ゼロとしてください。

**レガシープラグイン**

このスクリプトはすべてのプラグインで _必須_ とされていますが、このスクリプトが導入される以前の"レガシー"プラグインでは、 _オプション_ となっていました。

このスクリプトが存在しない場合、asdfは`bin/install`スクリプトがあると想定して、バージョンのダウンロード、**かつ**、インストールが実行されます。

レガシープラグインのサポートは最終的に削除される予定のため、今後作成するすべてのプラグインでこのスクリプトを含めるようにしてください。

**スクリプトで使用できる環境変数**

- `ASDF_INSTALL_TYPE`: `version`または`ref`です。。
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`の場合、バージョンのフルナンバーです。
  - `ASDF_INSTALL_TYPE=ref`の場合、Gitのref (tag/commit/branch)です。
- `ASDF_INSTALL_PATH`: ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。
- `ASDF_DOWNLOAD_PATH`: ソースコードまたはバイナリのダウンロード先のパスです。

**このスクリプトを呼び出すコマンド**

- `asdf install <tool> [version]`
- `asdf install <tool> latest[:version]`
- `asdf install nodejs 18.0.0`: Node.jsのバージョン`18.0.0`のソースコードまたはバイナリをダウンロードし、`ASDF_DOWNLOAD_PATH`ディレクトリに配置します。
  そして`bin/install`スクリプトを実行します。

**asdfからの呼び出しシグネチャ**

引数はありません。

```bash
"${plugin_path}"/bin/download
```

---

### `bin/install` <Badge type="tip" text="必須" vertical="middle" />

**説明**

ツールの特定バージョンを指定された場所にインストールします。

**実装内容**

- スクリプトは、指定されたバージョンを`ASDF_INSTALL_PATH`のパスのディレクトリにインストールする必要があります。
- Shimはデフォルトで、`$ASDF_INSTALL_PATH/bin`内にあるファイルに対して作成されます。
  この動作は、オプションの[bin/list-bin-paths](#binlist-bin-paths)スクリプトでカスタマイズできます。
- 成功した場合、終了コードは`0`としてください。
- 失敗した場合、終了コードは非ゼロとしてください。
- TOCTOU (Time-of-Check-to-Time-of-Use)の問題を避けるために、ツールのビルドとインストールが成功したとみなされた場合にのみ、`ASDF_INSTALL_PATH`にファイルを配置するようなスクリプトとしてください。

**レガシープラグイン**

`bin/download`スクリプトが存在しない場合、このスクリプトでは、指定されたバージョンをダウンロード、**かつ**、インストールをする必要があります。

`0.7._`以前と`0.8._`以降のasdfコアの互換性を保つために、`ASDF_DOWNLOAD_PATH`環境変数が設定されているかを確認してください。
設定されている場合は、`bin/download`スクリプトがすでにバージョンをダウンロードしていると想定し、設定されていない場合は、`bin/install`でソースコードをダウンロードするようにしてください。

**スクリプトで使用できる環境変数**

- `ASDF_INSTALL_TYPE`: `version`または`ref`です。
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`の場合、バージョンのフルナンバーです。
  - `ASDF_INSTALL_TYPE=ref`の場合、Gitのref (tag/commit/branch)です。
- `ASDF_INSTALL_PATH`: ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。
- `ASDF_CONCURRENCY`: ソースコードのコンパイル時に使用するコア数です。`make -j`のようなフラグを設定する際に便利です。
- `ASDF_DOWNLOAD_PATH`: ソースコードまたはバイナリのダウンロード先のパスです。

**このスクリプトを呼び出すコマンド**

- `asdf install`
- `asdf install <tool>`
- `asdf install <tool> [version]`
- `asdf install <tool> latest[:version]`
- `asdf install nodejs 18.0.0`: `ASDF_INSTALL_PATH`ディレクトリに、
  Node.jsのバージョン`18.0.0`をインストールします。

**asdfからの呼び出しシグネチャ**

引数はありません。

```bash
"${plugin_path}"/bin/install
```

## オプションスクリプト

### `bin/latest-stable` <Badge type="warning" text="推奨" vertical="middle" />

**説明**

ツールの最新安定バージョンを判定します。このスクリプトが存在しない場合、asdfコアは`bin/list-all`の出力を`tail`した結果をもとに判定しますが、ツールによってはこれが望ましくないことがあります。

**実装内容**

- スクリプトは、ツールの最新安定バージョンを標準出力する必要があります。
- 非安定版やリリース候補版は除外されるべきです。
- フィルタクエリは、スクリプトの第1引数で提供されます。このクエリは、バージョン番号やツールプロバイダによる出力をフィルタするために使用されるべきです。
  - 例えば、[rubyプラグイン](https://github.com/asdf-vm/asdf-ruby)での`asdf list all ruby`の出力は、`jruby`や`rbx`、`truffleruby`などの多くのプロバイダのRubyバージョンをリストアップします。ユーザが提供したフィルタは、セマンティックバージョンやプロバイダをフィルタするために、プラグインで使用できます。
    ```
    > asdf latest ruby
    3.2.2
    > asdf latest ruby 2
    2.7.8
    > asdf latest ruby truffleruby
    truffleruby+graalvm-22.3.1
    ```
- 成功した場合、終了コードは`0`としてください。
- 失敗した場合、終了コードは非ゼロとしてください。

**スクリプトで使用できる環境変数**

- `ASDF_INSTALL_TYPE`: `version`または`ref`です。
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`の場合、バージョンのフルナンバーです。
  - `ASDF_INSTALL_TYPE=ref`の場合、Gitのref (tag/commit/branch)です。
- `ASDF_INSTALL_PATH`: ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。

**このスクリプトを呼び出すコマンド**

- `asdf global <tool> latest`: ツールのグローバルバージョンとして、当該ツールの最新安定バージョンにセットします。
- `asdf local <name> latest`: ツールのローカルバージョンとして、当該ツールの最新安定バージョンにセットします。
- `asdf install <tool> latest`: ツールの最新安定バージョンをインストールします。
- `asdf latest <tool> [<version>]`: オプションのフィルタに基づいて、ツールの最新バージョンを出力します。
- `asdf latest --all`: asdfによって管理されているすべてのツールの最新バージョンと、それらがインストールされているかどうかを出力します。

**asdfからの呼び出しシグネチャ**

このスクリプトは、フィルタクエリという1つの引数を受け取ります。

```bash
"${plugin_path}"/bin/latest-stable "$query"
```

---

### `bin/help.overview`

**説明**

プラグインおよび管理されているツールに関する概要説明を出力します。

**実装内容**

- このスクリプトは、プラグインのヘルプを表示するために必要です。
- ヘッダはasdfコア側で表示するため、スクリプト内では表示しないでください。
- 自由な形式のテキストで出力して構いませんが、短い1段落程度の説明が理想です。
- コアとなるasdf-vmドキュメントですでに説明されている情報は出力しないでください。
- オペレーティングシステムと、インストールされているツールのバージョンに合わせて出力を調整する必要があります(必要に応じて、`ASDF_INSTALL_VERSION`および`ASDF_INSTALL_TYPE`環境変数の値を使用してください)。
- 成功した場合、終了コードは`0`としてください。
- 失敗した場合、終了コードは非ゼロとしてください。

**スクリプトで使用できる環境変数**

- `ASDF_INSTALL_TYPE`: `version`または`ref`です。
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`の場合、バージョンのフルナンバーです。
  - `ASDF_INSTALL_TYPE=ref`の場合、Gitのref (tag/commit/branch)です。
- `ASDF_INSTALL_PATH`: ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。

**このスクリプトを呼び出すコマンド**

- `asdf help <name> [<version>]`: プラグインおよびツールのドキュメントを出力します。

**asdfからの呼び出しシグネチャ**

```bash
"${plugin_path}"/bin/help.overview
```

---

### `bin/help.deps`

**説明**

オペレーティングシステムに合わせた依存関係のリストを出力します。依存関係を1行ごとに出力します。

```bash
git
curl
sed
```

**実装内容**

- このスクリプトの出力を考慮するために、`bin/help.overview`を用意する必要があります。
- オペレーティングシステムと、インストールされているツールのバージョンに合わせて出力を調整する必要があります(必要に応じて、`ASDF_INSTALL_VERSION`および`ASDF_INSTALL_TYPE`環境変数の値を使用してください)。
- 成功した場合、終了コードは`0`としてください。
- 失敗した場合、終了コードは非ゼロとしてください。

**スクリプトで使用できる環境変数**

- `ASDF_INSTALL_TYPE`: `version`または`ref`です。
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`の場合、バージョンのフルナンバーです。
  - `ASDF_INSTALL_TYPE=ref`の場合、Gitのref (tag/commit/branch)です。
- `ASDF_INSTALL_PATH`: ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。

**このスクリプトを呼び出すコマンド**

- `asdf help <name> [<version>]`: プラグインおよびツールのドキュメントを出力します。

**asdfからの呼び出しシグネチャ**

```bash
"${plugin_path}"/bin/help.deps
```

---

### `bin/help.config`

**説明**

プラグインおよびツールで設定必須または任意設定可能な構成設定一覧を出力します。例えば、ツールのインストール・コンパイルに必要な環境変数やその他フラグについて説明します。

**実装内容**

- このスクリプトの出力を考慮するために、`bin/help.overview`を用意する必要があります。
- 自由な形式のテキストで出力できます。
- オペレーティングシステムと、インストールされているツールのバージョンに合わせて出力を調整する必要があります(必要に応じて、`ASDF_INSTALL_VERSION`および`ASDF_INSTALL_TYPE`環境変数の値を使用してください)。
- 成功した場合、終了コードは`0`としてください。
- 失敗した場合、終了コードは非ゼロとしてください。

**スクリプトで使用できる環境変数**

- `ASDF_INSTALL_TYPE`: `version`または`ref`です。
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`の場合、バージョンのフルナンバーです。
  - `ASDF_INSTALL_TYPE=ref`の場合、Gitのref (tag/commit/branch)です。
- `ASDF_INSTALL_PATH`: ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。

**このスクリプトを呼び出すコマンド**

- `asdf help <name> [<version>]`: プラグインおよびツールのドキュメントを出力します。

**asdfからの呼び出しシグネチャ**

```bash
"${plugin_path}"/bin/help.config
```

---

### `bin/help.links`

**説明**

プラグインとツールに関連するリンクリストを出力します。リンクを1行ごとに出力します。

```bash
Git Repository:	https://github.com/vlang/v
Documentation:	https://vlang.io
```

**実装内容**

- このスクリプトの出力を考慮するために、`bin/help.overview`を用意する必要があります。
- リンクを1行ごとに出力してください。
- 形式は以下のいずれかである必要があります:
  - `<title>: <link>`
  - または`<link>`のみ
- オペレーティングシステムと、インストールされているツールのバージョンに合わせて出力を調整する必要があります(必要に応じて、`ASDF_INSTALL_VERSION`および`ASDF_INSTALL_TYPE`環境変数の値を使用してください)。
- 成功した場合、終了コードは`0`としてください。
- 失敗した場合、終了コードは非ゼロとしてください。

**スクリプトで使用できる環境変数**

- `ASDF_INSTALL_TYPE`: `version`または`ref`です。
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`の場合、バージョンのフルナンバーです。
  - `ASDF_INSTALL_TYPE=ref`の場合、Gitのref (tag/commit/branch)です。
- `ASDF_INSTALL_PATH`: ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。

**このスクリプトを呼び出すコマンド**

- `asdf help <name> [<version>]`: プラグインおよびツールのドキュメントを出力します。

**asdfからの呼び出しシグネチャ**

```bash
"${plugin_path}"/bin/help.links
```

---

### `bin/list-bin-paths`

**説明**

ツールの特定バージョンにおける、実行ファイルが含まれるディレクトリの一覧を出力します。

**実装内容**

- このスクリプトが存在しない場合、asdfは`"${ASDF_INSTALL_PATH}"/bin`ディレクトリ内にあるバイナリを探し、そのバイナリ向けのShimを作成します。
- 実行ファイルが含まれるディレクトリのパスをスペース区切りで出力してください。
- パスは`ASDF_INSTALL_PATH`からの相対パスである必要があります。例えば、次のような出力となります:

```bash
bin tools veggies
```

以上の場合、下記ディレクトリ内のファイルへのShimを作成するよう、asdfへ指示されます:
- `"${ASDF_INSTALL_PATH}"/bin`
- `"${ASDF_INSTALL_PATH}"/tools`
- `"${ASDF_INSTALL_PATH}"/veggies`

**スクリプトで使用できる環境変数**

- `ASDF_INSTALL_TYPE`: `version`または`ref`です。
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`の場合、バージョンのフルナンバーです。
  - `ASDF_INSTALL_TYPE=ref`の場合、Gitのref (tag/commit/branch)です。
- `ASDF_INSTALL_PATH`: ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。

**このスクリプトを呼び出すコマンド**

- `asdf install <tool> [version]`: バイナリへのShimを初期作成します。
- `asdf reshim <tool> <version>`: バイナリへのShimを再作成します。

**asdfからの呼び出しシグネチャ**

```bash
"${plugin_path}/bin/list-bin-paths"
```

---

### `bin/exec-env`

**説明**

ツールのバイナリのShimを実行する前に環境を準備します。

**スクリプトで使用できる環境変数**

- `ASDF_INSTALL_TYPE`: `version`または`ref`です。
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`の場合、バージョンのフルナンバーです。
  - `ASDF_INSTALL_TYPE=ref`の場合、Gitのref (tag/commit/branch)です。
- `ASDF_INSTALL_PATH`: ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。

**このスクリプトを呼び出すコマンド**

- `asdf which <command>`: 実行ファイルのパスを表示します。
- `asdf exec <command> [args...]`: 現在のバージョンでShimコマンドを実行します。
- `asdf env <command> [util]`: Shimコマンドの実行時に使用される環境において、util(デフォルト: `env`)を実行します。

**asdfからの呼び出しシグネチャ**

```bash
"${plugin_path}/bin/exec-env"
```

---

### `bin/exec-path`

ツールの特定バージョンの実行ファイルパスを取得します。
実行ファイルへの相対パスを文字列で出力する必要があります。
これにより、プラグインはShimで指定された実行ファイルパスを条件付きで上書きして返すか、
そうでなければ、Shimで指定されたデフォルトのパスを返すことができます。

**説明**

ツールの特定バージョンの実行ファイルパスを取得します。

**実装内容**

- 実行ファイルへの相対パスを文字列で出力する必要があります。
- Shimで指定された実行ファイルパスを条件付きで上書きして返すか、そうでなければ、Shimで指定されたデフォルトのパスを返してください。

```shell
Usage:
  plugin/bin/exec-path <install-path> <command> <executable-path>

Example Call:
  ~/.asdf/plugins/foo/bin/exec-path "~/.asdf/installs/foo/1.0" "foo" "bin/foo"

Output:
  bin/foox
```

**スクリプトで使用できる環境変数**

- `ASDF_INSTALL_TYPE`: `version`または`ref`です。
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`の場合、バージョンのフルナンバーです。
  - `ASDF_INSTALL_TYPE=ref`の場合、Gitのref (tag/commit/branch)です。
- `ASDF_INSTALL_PATH`: ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。

**このスクリプトを呼び出すコマンド**

- `asdf which <command>`: 実行ファイルのパスを表示します。
- `asdf exec <command> [args...]`: 現在のバージョンでShimコマンドを実行します。
- `asdf env <command> [util]`: Shimコマンドの実行時に使用される環境において、util(デフォルト: `env`)を実行します。

**asdfからの呼び出しシグネチャ**

```bash
"${plugin_path}/bin/exec-path" "$install_path" "$cmd" "$relative_path"
```

---

### `bin/uninstall`

**説明**

ツールの特定バージョンをアンインストールします。

**出力フォーマット**

ユーザへの出力は、`stdout`または`stderr`へ適切に送信してください。後続のコア実行によってこれらの出力が読み取られることはありません。

**スクリプトで使用できる環境変数**

このスクリプトに環境変数は提供されません。

**このスクリプトを呼び出すコマンド**

- `asdf list all <name> <version>`
- `asdf uninstall nodejs 18.15.0`: nodejsのバージョン`18.15.0`をアンインストールし、`npm i -g`でグローバルにインストールしたものを含むすべてのShimを削除します。

**asdfからの呼び出しシグネチャ**

引数はありません。

```bash
"${plugin_path}/bin/uninstall"
```

---

### `bin/list-legacy-filenames`

**説明**

ツールのバージョンを決定するために使用されるレガシー構成ファイルのリストを出力します。

**実装内容**

- スペース区切りのファイル名リストを出力してください。
  ```bash
  .ruby-version .rvmrc
  ```
- この内容は、`"${HOME}"/.asdfrc`内の`legacy_version_file`オプションを有効にしたユーザにのみ適用されます。

**スクリプトで使用できる環境変数**

- `ASDF_INSTALL_TYPE`: `version`または`ref`です。
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`の場合、バージョンのフルナンバーです。
  - `ASDF_INSTALL_TYPE=ref`の場合、Gitのref (tag/commit/branch)です。
- `ASDF_INSTALL_PATH`: ツールがインストール _されている_ 場所、またはインストール _されるべき_ 場所へのパスです。

**このスクリプトを呼び出すコマンド**

ツールのバージョンを読み込むすべてのコマンドから呼び出されます。

**asdfからの呼び出しシグネチャ**

引数はありません。

```bash
"${plugin_path}/bin/list-legacy-filenames"
```

---

### `bin/parse-legacy-file`

**説明**

asdfによって発見されたレガシーファイルをパースして、ツールのバージョンを決定します。JavaScriptの`package.json`や、Go言語の`go.mod`のようなファイルから、バージョン番号を抽出するのに役立ちます。

**実装内容**

- このスクリプトが存在しない場合、asdfは単純にレガシーファイルを`cat`してバージョンを決定します。
- **決定論的**で、常に正確で同じバージョンを返す必要があります:
  - 同じレガシーファイルを解析したら、同じバージョンを返すようにしてください。
  - マシンに何がインストールされているか、また、レガシーバージョンが有効で完全かどうかは関係ありません。一部のレガシーファイルのフォーマットは適切でないときもあります。
- 下記のように、バージョン番号を1行で出力してください:
  ```bash
  1.2.3
  ```

**スクリプトで使用できる環境変数**

このスクリプトが呼び出される前に、環境変数が設定されることはありません。

**このスクリプトを呼び出すコマンド**

ツールのバージョンを読み込むすべてのコマンドから呼び出されます。

**asdfからの呼び出しシグネチャ**

このスクリプトは、レガシーファイルの内容を読み込むために、レガシーファイルのパスという1つの引数を受け取ります。

```bash
"${plugin_path}/bin/parse-legacy-file" "$file_path"
```

---

### `bin/post-plugin-add`

**説明**

このスクリプトは、asdfの`asdf plugin add <tool>`コマンドで、プラグインが _追加_ された **後に** 呼び出されます。

関連するコマンドフックについても参照してください:

- `pre_asdf_plugin_add`
- `pre_asdf_plugin_add_${plugin_name}`
- `post_asdf_plugin_add`
- `post_asdf_plugin_add_${plugin_name}`

**スクリプトで使用できる環境変数**

- `ASDF_PLUGIN_PATH`: プラグインがインストールされている場所へのパスです。
- `ASDF_PLUGIN_SOURCE_URL`: プラグインソースのURLです。ローカルディレクトリパスを指定することもできます。

**asdfからの呼び出しシグネチャ**

引数はありません。

```bash
"${plugin_path}/bin/post-plugin-add"
```

---

### `bin/post-plugin-update`

**説明**

このスクリプトは、asdfの`asdf plugin update <tool> [<git-ref>]`コマンドで、 _更新_ されたプラグインがダウンロードされた **後に** 呼び出されます。

関連するコマンドフックについても参照してください:

- `pre_asdf_plugin_updated`
- `pre_asdf_plugin_updated_${plugin_name}`
- `post_asdf_plugin_updated`
- `post_asdf_plugin_updated_${plugin_name}`

**スクリプトで使用できる環境変数**

- `ASDF_PLUGIN_PATH`: プラグインがインストールされている場所へのパスです。
- `ASDF_PLUGIN_PREV_REF`: プラグインの以前のgit-refです。
- `ASDF_PLUGIN_POST_REF`: 更新後のプラグインのgit-refです。

**asdfからの呼び出しシグネチャ**

引数はありません。

```bash
"${plugin_path}/bin/post-plugin-update"
```

---

### `bin/pre-plugin-remove`

**説明**

このスクリプトは、asdfの`asdf plugin remove <tool>`コマンドで、プラグインが _削除_ される **前に** 呼び出されます。

関連するコマンドフックについても参照してください:

- `pre_asdf_plugin_remove`
- `pre_asdf_plugin_remove_${plugin_name}`
- `post_asdf_plugin_remove`
- `post_asdf_plugin_remove_${plugin_name}`

**スクリプトで使用できる環境変数**

- `ASDF_PLUGIN_PATH`: プラグインがインストールされている場所へのパスです。

**asdfからの呼び出しシグネチャ**

引数はありません。

```bash
"${plugin_path}/bin/pre-plugin-remove"
```

<!-- TODO: document command hooks -->
<!-- ## Command Hooks -->

## asdf CLIの拡張コマンド <Badge type="danger" text="高度" vertical="middle" />

プラグイン名をサブコマンドとして使用し、
asdfコマンドラインインターフェースを通して呼び出すことのできる`lib/commands/command*.bash`スクリプトまたは実行ファイルを用意することで、
新しいasdfコマンドを定義することができます。

例えば、`foo`というプラグインがあるとすると:

```shell
foo/
  lib/commands/
    command.bash
    command-bat.bash
    command-bat-man.bash
    command-help.bash
```

ユーザは下記コマンドが実行できるようになります:

```shell
$ asdf foo         # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash`
$ asdf foo bar     # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash bar`
$ asdf foo help    # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-help.bash`
$ asdf foo bat man # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat-man.bash`
$ asdf foo bat baz # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat.bash baz`
```

プラグイン開発者はこの機能を使って、ツールに関連するユーティリティを提供したり、
asdf自体のコマンド拡張プラグインを作成したりすることができます。

実行可能ビット(executable bit)が付与されている場合、
asdfの実行に代わって、当該スクリプトが実行されます。

実行可能ビット(executable bit)が付与されていない場合、asdfは当該スクリプトをBashスクリプトとしてsourceします。

`$ASDF_CMD_FILE`環境変数は、ソースとなるファイルのフルパスに解決されます。

[`haxe`](https://github.com/asdf-community/asdf-haxe)は、
この機能使ったプラグインの素晴らしい例です。
このプラグインは、`asdf haxe neko-dylibs-link`を提供しており、
Haxeの実行ファイルが実行ディレクトリから相対的に動的ライブラリを見つけようとしてしまう問題を修正します。

プラグインのREADMEには、asdf拡張コマンドに関することを必ず記載するようにしてください。

## カスタムShimテンプレート <Badge type="danger" text="高度" vertical="middle" />

::: warning 警告

**どうしても**必要な場合にのみ使用してください。

:::

asdfでは、カスタムShimテンプレートを使用することができます。
`foo`という実行ファイルに対して、プラグイン内に`shims/foo`ファイルが存在すれば、
asdfは標準Shimテンプレートを使用する代わりに、そのファイルをコピーします。

**この機能は賢く使う必要があります。**

asdfコアチームが把握している限り、
この機能は公式プラグインである[Elixirプラグイン](https://github.com/asdf-vm/asdf-elixir)でのみ使用されています。
実行ファイルは、実行ファイルであると同時に、Elixirファイルとしても読み込まれます。
そのため、標準的なBashのShimを使用できないのです。

## テスト

asdfでは、プラグインをテストするための`plugin-test`コマンドを用意しており、下記のように使用できます:

```shell
asdf plugin test <plugin_name> <plugin_url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git_ref>] [test_command...]
```

- `<plugin_name>`と`<plugin_url>`は必須です。
- オプションで`[--asdf-tool-version <version>]`を指定すると、そのバージョンのツールがインストールされます。
  デフォルトは、`asdf latest <plugin-name>`です。
- オプションで`[--asdf-plugin-gitref <git_ref>]`を指定すると、
  そのコミット/ブランチ/タグでプラグイン自体をチェックアウトします。
  これは、プラグインのCIにおいて、プルリクエストをテストする際に便利です。
- オプションの`[test_command...]`パラメータは、インストールしたツールが正しく動作するかを確認するために実行するコマンドです。
  通常は、`<tool> --version`または`<tool> --help`となります。
  例えば、NodeJSプラグインをテストするときは、次のように実行します:
  ```shell
  # asdf plugin test <plugin_name>  <plugin_url>                               [test_command]
    asdf plugin test nodejs         https://github.com/asdf-vm/asdf-nodejs.git node --version
  ```

::: tip 備考

LinuxとmacOSの両方のCI環境でテストすることを推奨します。

:::

### GitHub Action

[asdf-vm/actions](https://github.com/asdf-vm/actions)リポジトリでは、
GitHub上でホストされているプラグインをテストするためのGitHub Actionを提供しています。
`.github/workflows/test.yamlのActionsワークフローの例は以下のとおりです:

```yaml
name: Test
on:
  push:
    branches:
      - main
  pull_request:

jobs:
  plugin_test:
    name: asdf plugin test
    strategy:
      matrix:
        os:
          - ubuntu-latest
          - macos-latest
    runs-on: ${{ matrix.os }}
    steps:
      - name: asdf_plugin_test
        uses: asdf-vm/actions/plugin-test@v2
        with:
          command: "<MY_TOOL> --version"
```

### TravisCI 構成設定

以下は、`.travis.yml`ファイルの例です。必要に応じてカスタマイズしてください:

```yaml
language: c
script: asdf plugin test <MY_TOOL> $TRAVIS_BUILD_DIR '<MY_TOOL> --version'
before_script:
  - git clone https://github.com/asdf-vm/asdf.git asdf
  - . asdf/asdf.sh
os:
  - linux
  - osx
```

::: tip 備考

他のCIを使用する場合、
プラグインの場所への相対パスを渡す必要がある場合があります:

```shell
asdf plugin test <tool_name> <path> '<tool_command> --version'
```

:::

## APIレート制限

`bin/list-all`や`bin/latest-stable`のように、コマンドが外部APIへのアクセスに依存している場合、
自動テスト中にレート制限が発生することがあります。
これを軽減するため、環境変数経由で認証トークンを提供するコードパスがあることを確認してください。
以下に例を示します:

```shell
cmd="curl --silent"
if [ -n "$GITHUB_API_TOKEN" ]; then
 cmd="$cmd -H 'Authorization: token $GITHUB_API_TOKEN'"
fi

cmd="$cmd $releases_path"
```

### `GITHUB_API_TOKEN`

`GITHUB_API_TOKEN`を利用する際は、
まず、
`public_repo`アクセスのみをもつ[新しいパーソナルトークン](https://github.com/settings/tokens/new)を作成してください。

次に、このトークンをCIパイプライン環境変数に追加してください。

::: warning 警告

認証トークンをコードリポジトリで公開してはいけません。

:::

## プラグインショートネームインデックス

::: tip ヒント

推奨されるプラグインのインストール方法は、URLをもとに直接インストールする方法です:

```shell
# asdf plugin add <name> <git_url>
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs
```

:::

asdfの各種コマンドで`git_url`が指定されなかった場合、
asdfは正確な`git_url`を決定するために、
[ショートネームインデックスリポジトリ](https://github.com/asdf-vm/asdf-plugins)を使用します。

このリポジトリの指示に従うことで、
あなたが作成したプラグインを、
[ショートネームインデックス](https://github.com/asdf-vm/asdf-plugins)に追加することができます。

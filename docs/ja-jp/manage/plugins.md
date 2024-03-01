# プラグイン

プラグインは、`asdf`がNode.jsやRuby、Elixirなどの様々なツールを取り扱えるようにするためのものです。

様々なツールをサポートするために使用されるプラグインAPIについては、[プラグインの作成](/ja-jp/plugins/create.md)をご覧ください。

## 追加

下記コマンドでは、GitのURLからプラグインを追加します:

```shell
asdf plugin add <name> <git-url>
# asdf plugin add elm https://github.com/vic/asdf-elm
```

または下記のコマンドで、プラグインリポジトリのショートネームを指定して追加します:

```shell
asdf plugin add <name>
# asdf plugin add erlang
```

::: tip 推奨

リポジトリのショートネームに依存しないために、`git-url`を使用することを推奨します。

:::

## インストール済みプラグイン一覧

```shell
asdf plugin list
# asdf plugin list
# java
# nodejs
```

```shell
asdf plugin list --urls
# asdf plugin list
# java            https://github.com/halcyon/asdf-java.git
# nodejs          https://github.com/asdf-vm/asdf-nodejs.git
```

## 全プラグインのショートネーム一覧

```shell
asdf plugin list all
```

全プラグインのショートネーム一覧については、[プラグインショートネームの一覧](https://github.com/asdf-vm/asdf-plugins)もご覧ください。

## 更新

```shell
asdf plugin update --all
```

特定のプラグインパッケージを更新したい場合は、下記のように指定してください。

```shell
asdf plugin update <name>
# asdf plugin update erlang
```

この更新コマンドは、プラグインリポジトリの _origin_ の _デフォルトブランチ_ における _最新コミット_ を取得します。バージョニングされたプラグインの更新機能については、現在開発中です([#916](https://github.com/asdf-vm/asdf/pull/916))。

## 削除

```bash
asdf plugin remove <name>
# asdf plugin remove erlang
```

プラグインを削除すると、当該プラグインでインストールされたすべてのツールが削除されます。これは、各ツールの未使用バージョンを手っ取り早くクリーンアップ/プルーニングするのに有用です。

## ショートネームリポジトリの同期

ショートネームリポジトリはローカルマシンに同期され、定期的に更新されます。同期のタイミングの条件は、次のとおりです:

- 同期イベントは、下記コマンドによってトリガーされます:
  - `asdf plugin add <name>`
  - `asdf plugin list all`
- 構成設定の`disable_plugin_short_name_repository`オプションが`yes`の場合、同期は中止されます。詳しくは[asdfの構成設定](/ja-jp/manage/configuration.md)のリファレンスをご覧ください。
- もし、過去`X`分の間に同期が行われていない場合、同期が開始されます。
  - `X`のデフォルト値は`60`ですが、`.asdfrc`ファイルの`plugin_repository_last_check_duration`オプションで変更することができます。詳しくは[asdfの構成設定](/ja-jp/manage/configuration.md)のリファレンスをご覧ください。

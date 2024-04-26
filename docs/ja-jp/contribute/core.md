# asdf

これは、`asdf`コアのコントリビューションガイドです。

## 初期セットアップ

GitHubで`asdf`をフォークするか、デフォルトのブランチをGitクローンしてください:

```shell
# clone your fork
git clone https://github.com/<GITHUB_USER>/asdf.git
# or clone asdf
git clone https://github.com/asdf-vm/asdf.git
```

コア開発用のツールは、このリポジトリの`.tool-versions`で定義されています。`asdf`自身でこれらのツールを管理したい場合は、下記のようにプラグインを追加してください:

```shell
asdf plugin add bats https://github.com/timgluz/asdf-bats.git
asdf plugin add shellcheck https://github.com/luizm/asdf-shellcheck.git
asdf plugin add shfmt https://github.com/luizm/asdf-shfmt.git
```

`asdf`の開発に必要なバージョンを、下記のようにインストールします:

```shell
asdf install
```

開発ツールに影響を与える特定の機能を壊す可能性もあるため、ローカルマシンで開発する際は、`asdf`を使用しないほうが _良いかもしれません_ 。下記に、使用しているツールを列挙します:

- [bats-core](https://github.com/bats-core/bats-core): BashまたはPOSIX準拠のスクリプトを単体テストするための、Bash自動テストシステムです。
- [shellcheck](https://github.com/koalaman/shellcheck): シェルスクリプトの静的解析ツールです。
- [shfmt](https://github.com/mvdan/sh): Bashをサポートするシェルパーサ、フォーマッタ、インタプリタです。

## 開発

インストール済みの`asdf`に変更を加えずに、あなたが開発した変更内容を試したいときは、`$ASDF_DIR`変数に、クローンしたリポジトリのパスを設定し、そのディレクトリの`bin`と`shims`ディレクトリを一時的にパスの先頭へ追加します。

リモートにコミットまたはプッシュする前に、コードをローカルでフォーマット、Lint、およびテストすることを推奨します。その際は、次のスクリプト/コマンドを使用してください:

```shell
# Lint
./scripts/lint.bash --check

# Fix & Format
./scripts/lint.bash --fix

# Test: all tests
./scripts/test.bash

# Test: for specific command
bats test/list_commands.bash
```

::: tip ヒント

**テストを作ってください!** - 新機能にとってテストは**必要不可欠**であり、バグ修正のレビューをスピードアップさせることができます。プルリクエストを作成する前に、新しいコードをカバーするようなテストを作成してください。[bats-coreのドキュメント](https://bats-core.readthedocs.io/en/stable/index.html)もご覧ください。

:::

### Gitignore

下記は、`asdf-vm/asdf`リポジトリの`.gitignore`ファイルです。プロジェクト固有のファイルは無視をしています。使用しているOS、ツール、およびワークフロー固有のファイルは、グローバルな`.gitignore`構成で無視する必要があります。詳しくは[こちら](http://stratus3d.com/blog/2018/06/03/stop-excluding-editor-temp-files-in-gitignore/)をご覧ください。

@[Gitignoreコード](https://github.com/asdf-vm/asdf/blob/master/.gitignore)

### `.git-blame-ignore-revs`

`asdf`では、`.git-blame-ignore-revs`を使用して、Blameを実行する際のノイズを減らしています。詳しくは、[git blameのドキュメント](https://git-scm.com/docs/git-blame)をご覧ください。

`git blame`を実行するときは、下記のように、このファイルと共に使います:

```sh
git blame --ignore-revs-file .git-blame-ignore-revs ./test/install_command.bats
```

毎回手動でファイルを指定しなくても、gitのオプションで、`blame`を呼び出すたびにこのファイルを使うように設定することもできます:

```sh
git config blame.ignoreRevsFile .git-blame-ignore-revs
```

このファイルを使用するように、IDEを設定することもできます。例えば、VSCode(および[GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens))を使う場合は、`.vscode/settings.json`に下記のように記述します:

```json
{
  "gitlens.advanced.blame.customArguments": [
    "--ignore-revs-file",
    ".git-blame-ignore-revs"
  ]
}
```

## Batsテスト

ローカルでテストを実行するには、下記のようにテストを呼び出します:

```shell
./scripts/test.bash
```

テストを作成する前に、**下記項目を一通り参照してください**:

- `test/`内にすでに作成されているテスト
- [bats-coreのドキュメント](https://bats-core.readthedocs.io/en/stable/index.html)
- `scripts/test.bash`で使用されている既存のBatsの設定

### Batsのヒント

Batsでのデバッグは、難しいことがあります。`-t`フラグを指定してTAP出力を有効にすると、テスト実行中に特殊なファイルディスクリプタ`>&3`を使用して出力を表示できるため、デバッグが簡単になります。例えば次のとおりです:

```shell
# test/some_tests.bats

printf "%s\n" "Will not be printed during bats test/some_tests.bats"
printf "%s\n" "Will be printed during bats -t test/some_tests.bats" >&3
```

詳しくは、bats-coreドキュメント内の[Printing to the Terminal](https://bats-core.readthedocs.io/en/stable/writing-tests.html#printing-to-the-terminal)で説明されています。

## プルリクエスト、リリース、Conventional Commits

`asdf`は、[Release Please](https://github.com/googleapis/release-please)という自動リリースツールを使用して、[セマンティックバージョン](https://semver.org/)を自動的に引き上げ、[Changelog](https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md)を生成しています。この情報は、前回のリリースからのコミット履歴を読み込むことで生成されます。

[Conventional Commit messages](https://www.conventionalcommits.org/ja/)では、デフォルトブランチでのコミットメッセージのフォーマットとなる、プルリクエストタイトルのフォーマットを定義しています。これは、GitHub Action[`amannn/action-semantic-pull-request`](https://github.com/amannn/action-semantic-pull-request)で強制されます。

Conventional Commitは、下記のフォーマットに従います:

```
<type>[optional scope][optional !]: <description>

<!-- examples -->
fix: some fix
feat: a new feature
docs: some documentation update
docs(website): some change for the website
feat!: feature with breaking change
```

`<types>`の種類は次のとおりです: `feat`、`fix`、`docs`、`style`、 `refactor`、 `perf`、`test`、`build`、`ci`、`chore`、 `revert`。

- `!`: 破壊的変更を示します
- `fix`: セマンティックバージョンの`patch`を新しく作成します
- `feat`: セマンティックバージョンの`minor`を新しく作成します
- `<type>!`: セマンティックバージョンの`major`を新しく作成します

プルリクエストのタイトルは、このフォーマットに従う必要があります。

::: tip ヒント

プルリクエストのタイトルには、Conventional Commit messageのフォーマットを使用してください。

:::

## Dockerイメージ

[asdf-alpine](https://github.com/vic/asdf-alpine)および[asdf-ubuntu](https://github.com/vic/asdf-ubuntu)プロジェクトは、一部のasdfツールのDocker化されたイメージを提供する取り組みを継続的に行っています。これらのDockerイメージは、開発用サーバのベースとしたり、本番用アプリケーションの実行用途として使用することができます。

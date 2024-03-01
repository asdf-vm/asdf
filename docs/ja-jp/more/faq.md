# FAQ

ここでは、`asdf`に関するよくある質問を紹介します。

## WSL1をサポートしていますか?

WSL1 ([Windows Subsystem for Linux](https://ja.wikipedia.org/wiki/Windows_Subsystem_for_Linux) 1)は公式にはサポートしていません。`asdf`は正常に動作しない可能性があります。WSL1を公式にサポートする予定はありません。

## WSL2をサポートしていますか?

WSL2 ([Windows Subsystem for Linux](https://ja.wikipedia.org/wiki/Windows_Subsystem_for_Linux#WSL2) 2)では、あなたが選択したWSLディストリビューションに基づいて、セットアップと依存関係の解決を済ませれば、動作するはずです。

重要なのは、WSL2が正常に動作するのは、カレントワークディレクトリがWindowsドライブではなくUnixドライブである場合に _限られる_ ということです。

GitHub Actionsでホストランナーのサポートが可能になれば、WSL2でテストスイートを実行する予定ですが、現時点ではそうではないようです。

## 新しくインストールした実行ファイルが実行できないのですが?

> `npm install -g yarn`を実行したにも関わらず、`yarn`が実行できません。どうなっているの?

`asdf`は[Shim](<https://en.wikipedia.org/wiki/Shim_(computing)>)を使って実行ファイルを管理しています。プラグインによってインストールされるものは、自動的にShimが作成されますが、`asdf`が管理しているツールによって実行ファイルがインストールされた場合は、Shimを作成しなければならないということを`asdf`に通知する必要があります。上記の例では、[Yarn](https://yarnpkg.com/)のShimを作成しなければいけません。詳しくは、[`asdf reshim`コマンドのドキュメント](/ja-jp/manage/core.md#shimの再作成)をご覧ください。

## シェルが、新しくインストールされたShimを検知してくれないのですが?

`asdf reshim`コマンドを実行しても問題が解決しない場合、`asdf.sh`や`asdf.fish`のsourceが、シェルの構成ファイル(`.bash_profile`、`.zshrc`、`config.fish`など)の**一番下**にないことが原因である可能性があります。`$PATH`を設定した**後**、そしてフレームワーク(oh-my-zshなど)を使用しているのれあればそれをsourceした**後**に、sourceする必要があります。

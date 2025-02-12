##### 依存関係のインストール

asdfの動作には`git`が必要です。以下の表は、 _あなたが使用している_ パッケージマネージャで実行するコマンドの _一部例_ です(いくつかのツールは、後の手順で自動的にインストールされます)。

| OS    | パッケージマネージャー | コマンド                       |
| ----- | ------------------ | ----------------------------- |
| linux | Aptitude           | `apt install git`             |
| linux | DNF                | `dnf install git`             |
| linux | Pacman             | `pacman -S git`               |
| linux | Zypper             | `zypper install git`          |
| macOS | Homebrew           | `brew install coreutils git`  |
| macOS | Spack              | `spack install coreutils git` |

::: tip 備考

お使いのシステムの構成によっては、`sudo`が必要となる場合があります。

:::

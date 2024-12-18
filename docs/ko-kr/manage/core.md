# 코어

코어 `asdf` 명령어는 소수지만, 많은 워크플로우를 원활하게 만들어줍니다.

## 설치 & 설정

[시작하기](/ko-kr/guide/getting-started.md)의 가이드에 설명되어 있습니다.

## 실행

```shell
asdf exec <command> [args...]
```

현재 버전의 shim 명령어를 실행합니다.

<!-- TODO: expand on this with example -->

## 환경 변수

```shell
asdf env <command> [util]
```

<!-- TODO: expand on this with example -->

## 정보

```shell
asdf info
```

운영체제, 셸 및 `asdf` 디버깅 정보를 출력하는 헬퍼 명령어입니다. 버그 리포트 작성시 공유해주세요.

## Shim 재생성 <a id='Shim-재생성'></a>

```shell
asdf reshim <name> <version>
```

패키지의 현재 버전 shim을 재생성합니다. 기본적으로, shim들은 플러그인을 통해 툴 설치 중에 생성됩니다. [npm CLI](https://docs.npmjs.com/cli/) 등과 같은 툴들은 실행파일을 글로벌 설치할 수 있습니다, 예를 들어, `npm install -g yarn`을 통한 [Yarn](https://yarnpkg.com/) 설치. 이러한 실행파일은 플러그인의 라이프사이클을 통해 설치되지 않았기 때문에, 해당 플러그인을 위한 shim이 아직 존재하지 않습니다. 이때, `nodejs`의 `<version>`에 대해서, 예를 들면 `yarn`과 같은, 새로운 실행파일의 shim을 `asdf reshim nodejs <version>`을 통해 강제적으로 재작성 할 수 있습니다.

## Shim 버전

```shell
asdf shim-versions <command>
```

shim을 제공하는 플러그인 및 버전들을 나열합니다.

예를 들면, [Node.js](https://nodejs.org/)에는 `node`와 `npm`이라고 하는 2개의 실행파일이 제공되고 있습니다. [`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/)을 통해 여러 버전의 툴이 설치되어 있는 경우, `shim-versions`는 아래와 같은 내용을 출력할 수 있습니다:

```shell
➜ asdf shim-versions node
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

```shell
➜ asdf shim-versions npm
nodejs 14.8.0
nodejs 14.17.3
nodejs 16.5.0
```

## 업데이트

`asdf`는 (권장 설치 방법) Git에 의존하는 빌트인 업데이트 명령어가 있습니다. 다른 방법으로 설치한 경우, 그 방법을 위한 절차를 따라주세요:

| 방법           | 최신 안정 릴리스                                                                                                          | `master`에 최신 커밋             |
| -------------- | ------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| asdf (via Git) | `asdf update`                                                                                                             | `asdf update --head`             |
| Homebrew       | `brew upgrade asdf`                                                                                                       | `brew upgrade asdf --fetch-HEAD` |
| Pacman         | 새로운 `PKGBUILD` 다운로드 & 재빌드 <br/> 혹은 선호하는 [AUR 헬퍼](https://wiki.archlinux.org/index.php/AUR_helpers) 사용 |                                  |

## 제거

`asdf` 제거를 위해 다음 절차를 따르세요:

::: details Bash & Git

1. `~/.bashrc`에서, `asdf.sh` 및 자동완성을 source하고 있는 행들을 삭제:

```shell
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
```

2. `$HOME/.asdf` 디렉토리 제거:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Git (macOS)

1. `~/.bash_profile`에서, `asdf.sh` 및 자동완성을 source하고 있는 행들을 삭제:

```shell
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
```

2. `$HOME/.asdf` 디렉토리 제거:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Homebrew

1. `~/.bashrc`에서, `asdf.sh` 및 자동완성을 source하고 있는 행들을 삭제:

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash
```

명령어 자동완성에 대해서는 [Homebrew에 설명되어 있는 방법으로 설정](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) 되어 있을 가능성이 있으므로, 그 가이드에 따라 삭제할 행을 찾아주세요.

2. 패키지 관리자를 사용하여 제거:

```shell
brew uninstall asdf --force
```

3. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Homebrew (macOS)

**macOS Catalina 혹은 그 이상**을 사용하신다면, 기본 셸이 **ZSH**로 변경되었습니다. 만약, `~/.bash_profile`에서 설정을 찾을 수 없는 경우는, `~/.zshrc`에 있을 가능성이 있는데 이 경우 ZSH의 설명을 봐 주세요.

1. `~/.bash_profile`에서, `asdf.sh` 및 자동완성을 source하고 있는 행들을 삭제:

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash
```

명령어 자동완성에 대해서는 [Homebrew에 설명되어 있는 방법으로 설정](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) 되어 있을 가능성이 있으므로, 그 가이드에 따라 삭제할 행을 찾아주세요.

2. 패키지 관리자를 사용하여 제거:

```shell
brew uninstall asdf --force
```

3. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Bash & Pacman

1. `~/.bashrc`에서, `asdf.sh` 및 자동완성을 source하고 있는 행들을 삭제:

```shell
. /opt/asdf-vm/asdf.sh
```

2. 패키지 관리자를 사용하여 제거:

```shell
pacman -Rs asdf-vm
```

3. `$HOME/.asdf` 디렉토리 제거:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

4. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Fish & Git

1. `~/.config/fish/config.fish`에서, `asdf.fish`를 source하고 있는 행들을 삭제:

```shell
source ~/.asdf/asdf.fish
```

그리고 자동완성을 다음 명령어로 제거:

```shell
rm -rf ~/.config/fish/completions/asdf.fish
```

2. `$HOME/.asdf` 디렉토리 제거:

```shell
rm -rf (string join : -- $ASDF_DATA_DIR $HOME/.asdf)
```

3. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Fish & Homebrew

1. `~/.config/fish/config.fish`에서, `asdf.fish`를 source하고 있는 행들을 삭제:

```shell
source "(brew --prefix asdf)"/libexec/asdf.fish
```

2. 패키지 관리자를 사용하여 제거:

```shell
brew uninstall asdf --force
```

3. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Fish & Pacman

1. `~/.config/fish/config.fish`에서, `asdf.fish`를 source하고 있는 행들을 삭제:

```shell
source /opt/asdf-vm/asdf.fish
```

2. 패키지 관리자를 사용하여 제거:

```shell
pacman -Rs asdf-vm
```

3. `$HOME/.asdf` 디렉토리 제거:

```shell
rm -rf (string join : -- $ASDF_DATA_DIR $HOME/.asdf)
```

4. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Git

1. `~/.config/elvish/rc.elv`에서, `asdf` 모듈을 사용하는 행들을 삭제:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

그리고 `asdf` 모듈을 다음 명령어로 제거:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. `$HOME/.asdf` 디렉토리 제거:

```shell
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

3. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Homebrew

1. `~/.config/elvish/rc.elv`에서, `asdf` 모듈을 사용하는 행들을 삭제:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

그리고 `asdf` 모듈을 다음 명령어로 제거:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. 패키지 관리자를 사용하여 제거:

```shell
brew uninstall asdf --force
```

3. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details Elvish & Pacman

1. `~/.config/elvish/rc.elv`에서, `asdf` 모듈을 사용하는 행들을 삭제:

```shell
use asdf _asdf; var asdf~ = $_asdf:asdf~
set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~
```

그리고 `asdf` 모듈을 다음 명령어로 제거:

```shell
rm -f ~/.config/elvish/lib/asdf.elv
```

2. 패키지 관리자를 사용하여 제거:

```shell
pacman -Rs asdf-vm
```

3. `$HOME/.asdf` 디렉토리 제거:

```shell
if (!=s $E:ASDF_DATA_DIR "") { rm -rf $E:ASDF_DATA_DIR } else { rm -rf ~/.asdf }
```

4. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details ZSH & Git

1. `~/.zshrc`에서, `asdf.sh` 및 자동완성을 source하고 있는 행들을 삭제:

```shell
. "$HOME/.asdf/asdf.sh"
# ...
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit
compinit
```

**혹은** 사용된 ZSH 프레임워크 플러그인 제거.

2. `$HOME/.asdf` 디렉토리 제거:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

3. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details ZSH & Homebrew

1. `~/.zshrc`에서, `asdf.sh`을 source하고 있는 행들을 삭제:

```shell
. $(brew --prefix asdf)/libexec/asdf.sh
```

2. 패키지 관리자를 사용하여 제거:

```shell
brew uninstall asdf --force && brew autoremove
```

3. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

::: details ZSH & Pacman

1. `~/.zshrc`에서, `asdf.sh`을 source하고 있는 행들을 삭제:

```shell
. /opt/asdf-vm/asdf.sh
```

2. 패키지 관리자를 사용하여 제거:

```shell
pacman -Rs asdf-vm
```

3. `$HOME/.asdf` 디렉토리 제거:

```shell
rm -rf "${ASDF_DATA_DIR:-$HOME/.asdf}"
```

4. 모든 `asdf` 설정 파일들 제거를 위해 아래 명령어 실행:

```shell
rm -rf "$HOME/.tool-versions" "$HOME/.asdfrc"
```

:::

끝! 🎉

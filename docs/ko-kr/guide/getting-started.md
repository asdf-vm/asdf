# 시작하기

`asdf` 설치는 다음과 같습니다:

1. dependencies 설치
2. `asdf` 코어 다운로드
3. `asdf` 설치
4. 관리하고 싶은 각각의 툴/런타임 플러그인 설치
5. 툴/런타임 버전 설치
6. `.tool-versions` 설정 파일들을 통해 글로벌 혹은 프로젝트 버전들 설정

## 1. Dependencies 설치

asdf는 `git` & `curl`이 필요합니다. _당신이_ 필요한 패키지 매니저를 구동하기 위한 _일부_ 명령어들의 목록입니다. (몇몇은 나중 단계에서 자동으로 설치될 수 있습니다).

| 운영체제 | 패키지 매니저 | 명령어                             |
| -------- | ------------- | ---------------------------------- |
| linux    | Aptitude      | `apt install curl git`             |
| linux    | DNF           | `dnf install curl git`             |
| linux    | Pacman        | `pacman -S curl git`               |
| linux    | Zypper        | `zypper install curl git`          |
| macOS    | Homebrew      | `brew install coreutils curl git`  |
| macOS    | Spack         | `spack install coreutils curl git` |

::: tip 노트

시스템 설정에 의해 `sudo`가 필요할 수 있습니다.

:::

## 2. asdf 다운로드

### 공식 다운로드

<!-- x-release-please-start-version -->


```shell
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0

```

<!-- x-release-please-end -->

### 커뮤니티 지원 다운로드 방법

공식 `git` 방식을 사용할 것을 적극적으로 권장드립니다.

| 방법     | 명령어                                                                                                                                                             |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Homebrew | `brew install asdf`                                                                                                                                                |
| Pacman   | `git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si` 혹은 선호하시는 [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) 사용 |

## 3. asdf 설치

설정에 영향을 미치는 다양한 셸, 운영체제들 & 설치방법의 조합들이 있습니다. 아래 선택사항들 중 가장 적합한 것을 사용하세요.

**macOS 사용자들은 이 섹션 마지막 부분에 `path_helper`에 경고를 반드시 읽어보세요.**

::: details Bash & Git

다음을 `~/.bashrc`에 추가하세요:

```shell
. "$HOME/.asdf/asdf.sh"
```

자동완성 설정은 다음을 `.bashrc`에 추가하세요:

```shell
. "$HOME/.asdf/completions/asdf.bash"
```

:::

::: details Bash & Git (macOS)

**macOS Catalina 혹은 그 이상**을 사용하신다면, 기본 셸이 **ZSH**로 변경되었습니다. Bash로 다시 변경하지 않으셨다면, ZSH의 설치방법을 따라주세요.

다음을 `~/.bash_profile`에 추가하세요:

```shell
. "$HOME/.asdf/asdf.sh"
```

자동완성 설정은 다음을 `.bash_profile`에 직접 추가하세요:

```shell
. "$HOME/.asdf/completions/asdf.bash"
```

:::

::: details Bash & Homebrew

`~/.bashrc`에 `asdf.sh`를 추가하세요:

```shell
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.bashrc
```

자동완성은 [Homebrew'의 방법에 따라 설정되어야 합니다](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) 혹은 다음을 이용하세요:

```shell
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bashrc
```

:::

::: details Bash & Homebrew (macOS)

**macOS Catalina 혹은 그 이상**을 사용하신다면, 기본 셸이 **ZSH**로 변경되었습니다. Bash로 다시 변경하지 않으셨다면, ZSH의 설치방법을 따라주세요.

`~/.bash_profile`에 `asdf.sh` 추가하기:

```shell
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.bash_profile
```

자동완성은 [Homebrew'의 방법에 따라 설정되어야 합니다](https://docs.brew.sh/Shell-Completion#configuring-completions-in-bash) 혹은 다음을 이용하세요:

```shell
echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bash_profile
```

:::

::: details Bash & Pacman

다음을 `~/.bashrc`에 추가하세요:

```shell
. /opt/asdf-vm/asdf.sh
```

자동완성을 위해 [`bash-completion`](https://wiki.archlinux.org/title/bash#Common_programs_and_options)이 설치 되어야합니다.
:::

::: details Fish & Git

다음을 `~/.config/fish/config.fish`에 추가하세요:

```shell
source ~/.asdf/asdf.fish
```

다음 명령어로 자동완성을 설정하세요:

```shell
mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
```

:::

::: details Fish & Homebrew

`~/.config/fish/config.fish`에 `asdf.fish`를 추가하세요:

```shell
echo -e "\nsource "(brew --prefix asdf)"/libexec/asdf.fish" >> ~/.config/fish/config.fish
```

자동완성은 [Fish 셸 Homebrew에 의해 관리됩니다](https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish). 편하죠!
:::

::: details Fish & Pacman

다음을 `~/.config/fish/config.fish`에 추가하세요:

```shell
source /opt/asdf-vm/asdf.fish
```

자동완성은 AUR 패키지를 통한 설치로 자동적으로 설정됩니다.
:::

::: details Elvish & Git

`~/.config/elvish/rc.elv`에 `asdf.elv`를 추가하세요:

```shell
mkdir -p ~/.config/elvish/lib; ln -s ~/.asdf/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

자동완성은 자동적으로 설정됩니다.

:::

::: details Elvish & Homebrew

Add `asdf.elv` to your `~/.config/elvish/rc.elv` with:

```shell
mkdir -p ~/.config/elvish/lib; ln -s (brew --prefix asdf)/libexec/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

자동완성은 자동적으로 설정됩니다.
:::

::: details Elvish & Pacman

`~/.config/elvish/rc.elv`에 `asdf.elv`를 추가하세요:

```shell
mkdir -p ~/.config/elvish/lib; ln -s /opt/asdf-vm/asdf.elv ~/.config/elvish/lib/asdf.elv
echo "\n"'use asdf _asdf; var asdf~ = $_asdf:asdf~' >> ~/.config/elvish/rc.elv
echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

자동완성은 자동적으로 설정됩니다.
:::

::: details ZSH & Git

다음을 `~/.zshrc`에 추가하세요:

```shell
. "$HOME/.asdf/asdf.sh"
```

**혹은** 위 스크립트와 자동완성을 설정하는 [asdf를 위한 oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf)와 같은 ZSH 프레임워크 플러그인을 사용하세요.

자동완성은 ZSH 프레임워크 `asdf` 플러그인 혹은 다음을 `.zshrc`에 추가함으로써 설정됩니다:

```shell
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
```

- 만약 custom `compinit` 설정을 사용중이라면, `asdf.sh`를 source하고 난 다음 `compinit`가 오도록 해주세요
- 만약 ZSH 프레임워크를 통해 custom `compinit` 설정을 사용중이라면, 해당 프레임워크를 source하고 난 다음 `compinit`가 오도록 해주세요

**경고**

만약 ZSH 프레임워크를 사용중이라면, `fpath`를 통해 새로운 ZSH 자동완성을 사용하려면 관련된 `asdf` 플러그인이 업데이트 되어야합니다. Oh-My-ZSH asdf 플로그인이 아직 업데이트 되지 않았습니다, [ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837) 참고.
:::

::: details ZSH & Homebrew

`~/.zshrc`에 `asdf.sh`를 추가하세요:

```shell
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
```

**혹은** 위 스크립트와 자동완성을 설정하는 [asdf를 위한 oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf)와 같은 ZSH 프레임워크 플러그인을 사용하세요.

자동완성은 `asdf` ZSH 프레임워크 혹은 [Homebrew'의 방법](https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh)에 따라 설정되어야 합니다. 만약 ZSH 프레임워크를 사용중이라면, `fpath`를 통해 새로운 ZSH 자동완성을 사용하려면 관련된 asdf 플러그인이 업데이트 되어야합니다. Oh-My-ZSH asdf 플로그인이 아직 업데이트 되지 않았습니다, [ohmyzsh/ohmyzsh#8837](https://github.com/ohmyzsh/ohmyzsh/pull/8837) 참고.
:::

::: details ZSH & Pacman

다음을 `~/.zshrc`에 추가하세요:

```shell
. /opt/asdf-vm/asdf.sh
```

자동완성은 ZSH 친화적인 위치에 있지만, [ZSH는 자동완성 사용을 위해 반드시 설정 되어야합니다](https://wiki.archlinux.org/index.php/zsh#Command_completion).
:::

::: details PowerShell Core & Git

다음을 `~/.config/powershell/profile.ps1`에 추가하세요:

```shell
. "$HOME/.asdf/asdf.ps1"
```

:::

::: details PowerShell Core & Homebrew

`~/.config/powershell/profile.ps1`에 `asdf.sh`를 추가하세요:

```shell
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.ps1\"" >> ~/.config/powershell/profile.ps1
```

:::

::: details PowerShell Core & Pacman

다음을 `~/.config/powershell/profile.ps1`에 추가하세요:

```shell
. /opt/asdf-vm/asdf.ps1
```

:::

::: details Nushell & Git

`~/.config/nushell/config.nu`에 `asdf.nu`를 추가하세요:

```shell
"\n$env.ASDF_DIR = ($env.HOME | path join '.asdf')\n source " + ($env.HOME | path join '.asdf/asdf.nu') | save --append $nu.config-path
```

자동완성은 자동적으로 설정됩니다.
:::

::: details Nushell & Homebrew

`~/.config/nushell/config.nu`에 `asdf.nu`를 추가하세요:

```shell
"\n$env.ASDF_DIR = (brew --prefix asdf | str trim | into string | path join 'libexec')\n source " +  (brew --prefix asdf | str trim | into string | path join 'libexec/asdf.nu') | save --append $nu.config-path
```

자동완성은 자동적으로 설정됩니다.
:::

::: details Nushell & Pacman

`~/.config/nushell/config.nu`에 `asdf.nu`를 추가하세요:

```shell
"\n$env.ASDF_DIR = '/opt/asdf-vm/'\n source /opt/asdf-vm/asdf.nu" | save --append $nu.config-path
```

자동완성은 자동적으로 설정됩니다.
:::

::: details POSIX Shell & Git

다음을 `~/.profile`에 추가하세요:

```shell
export ASDF_DIR="$HOME/.asdf"
. "$HOME/.asdf/asdf.sh"
```

:::

::: details POSIX Shell & Homebrew

`~/.profile`에 `asdf.sh`를 추가하세요:

```shell
echo -e "\nexport ASDF_DIR=\"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.profile
echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.profile
```

:::

::: details POSIX Shell & Pacman

다음을 `~/.profile`에 추가하세요:

```shell
export ASDF_DIR="/opt/asdf-vm"
. /opt/asdf-vm/asdf.sh
```

:::

`asdf` 스크립트들은 `$PATH` 설정한 **이후에** 프레임워크 (oh-my-zsh 등) source **이후에** source 되어야 합니다. 

::: 경고
macOS에서, Bash 혹은 Zsh 셸 시작시에 자동적으로 `path_helper` 유틸리티를 실행시킵니다. `path_helper`는 `PATH` (와 `MANPATH`)에 항목들을 재배열 시켜 특정 순서를 요구하는 툴들의 일관된 동작을 방해합니다. 이를 방지하기 위해, macOS에서 `asdf`는 `PATH` 앞부분에 (가장 높은 우선순위) 강제로 추가합니다. 이는 `ASDF_FORCE_PREPEND`를 통해 변경가능합니다.
:::

`PATH` 업데이트를 위해 셸을 재시작하세요. 새로운 터미널을 여는 경우 대부분 해결됩니다.

## 코어 설치 완료!

`asdf` 코어 설치를 완료했습니다 :tada:

`asdf`는 **플러그인**과 **툴**을 설치하고, **버전**들을 관리해야 유용합니다. 설치 및 관리방법을 이 가이드 아래에서 계속해서 배우세요.

## 4. 플러그인 설치

데모 목적으로 우리는 [`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/) 플러그인을 통해 [Node.js](https://nodejs.org/) 설치 & 설정을 해보겠습니다.

### 플러그인 Dependencies

각 플러그인은 dependencies 갖고 있어 우리는 플러그인 리포지토리의 목록을 확인해야합니다. `asdf-nodejs`는 다음을 가지고 있습니다:

| OS                             | Dependency 설치                         |
| ------------------------------ | --------------------------------------- |
| Debian                         | `apt-get install dirmngr gpg curl gawk` |
| CentOS/ Rocky Linux/ AlmaLinux | `yum install gnupg2 curl gawk`          |
| macOS                          | `brew install gpg gawk`                 |

우리는 어떤 플러그인들은 설치-후 훅들을 갖고있어 dependencies 먼저 설치해야합니다.

### 플러그인 설치

```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## 5. 버전 설치

이제 우리는 Node.js를 위한 플러그인을 갖고있어 툴 버전을 설치할 수 있습니다.

우리는 `asdf list all nodejs`를 통해 어떤 버전들이 이용가능한지 혹은 `asdf list all nodejs 14`를 통해 하위 버전들을 확인가능합니다.

우리는 이용가능한 `latest` 버전을 설치할 것입니다.

```shell
asdf install nodejs latest
```

::: tip 노트
`asdf`는 정확한 버전들을 강제합니다. `latest`는 `asdf`가 실행했을때 실제 버전을 찾는 헬퍼입니다.
:::

## 6. 버전 설정

`asdf`는 현재 작업 디렉토리부터 `$HOME` 디렉토리까지 모든 `.tool-versions` 파일들에서 버전 검색을 수행합니다. 검색은 `asdf`가 관리하는 툴을 실행시킬때 맞춰서 실행됩니다.

::: 경고
툴 실행을 위한 툴 버전을 설정하지 않으면 **에러**가 발생합니다. `asdf current`는 현재 디렉토리로부터 툴 & 버전을 표시함으로써 어떤 툴들이 실행을 실패하는지 관찰할 수 있게합니다.
:::

### 글로벌

글로벌 기본값들은 `$HOME/.tool-versions`에서 관리됩니다. 글로벌 버전을 다음을 이용해 설정하세요:

```shell
asdf global nodejs latest
```


`$HOME/.tool-versions`은 다음과 같습니다:

```
nodejs 16.5.0
```

어떤 운영체제들은 `asdf`가 아닌 시스템에 의해 관리되는 툴들이 이미 설치되어 있습니다, `python`이 대표적인 예시입니다. 당신은 시스템에 의한 툴 관리를 위해 `asdf`를 설정해야합니다. [버전 참조 섹션](/ko-kr/manage/versions.md)를 참고하세요.

### 로컬

로컬 버전들은 (현재 작업 디렉토리) `$PWD/.tool-versions` 파일에 정의 되어 있습니다. 보통, 이 디렉토리는 하나의 프로젝트의 Git 리포지토리입니다. 툴 버전을 설정하고 싶은 디렉토리에서 다음을 실행시키세요:

```shell
asdf local nodejs latest
```

`$PWD/.tool-versions`은 다음과 같습니다:

```
nodejs 16.5.0
```

### 기존의 툴 버전 파일들 사용하기

`asdf`는 기존의 다른 버전 매니저들의 버전 파일들 마이그레이션을 지원합니다. 예시: `rbenv`의 `.ruby-version`. 이는 각 플러그인 기준으로 지원됩니다.

[`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/)는 `.nvmrc`와 `.node-version` 파일들을 지원합니다. 이를 활성화하기 위해, 다음을 `asdf` 설정 파일 `$HOME/.asdfrc`에 추가하세요:

```
legacy_version_file = yes
```

더 많은 설정 옵션들은 [configuration](/ko-kr/manage/configuration.md) 페이지를 참고하세요.

## 가이드 끝!

`asdf` 시작하기 가이드가 끝났습니다. :tada: 당신은 이제 당신의 프로젝트의 `nodejs` 버전들을 관리할 수 있습니다. 같은 방법으로 다른 각각의 툴들의 버전을 관리하세요!

`asdf`는 우리가 익숙해져야하는 더 많은 명령어들을 가지고 있고, `asdf --help` 혹은 `asdf`를 통해 확인할 수 있습니다. 명령어들의 코어의 3가지 카테고리로 나눠질 수 있습니다:

- [코어 `asdf`](/ko-kr/manage/core.md)
- [플러그인](/ko-kr/manage/plugins.md)
- [툴 버전](/ko-kr/manage/versions.md)

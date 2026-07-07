# 시작하기

## 1. asdf 설치

asdf는 여러가지 방법으로 설치할 수 있습니다:

::: details 패키지 매니저 사용 - **추천**

| 패키지 매니저 | 명령어                                                                                                                                                              |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Homebrew      | `brew install asdf`                                                                                                                                                  |
| Zypper        | `zypper install asdf`                                                                                                                                                |
| Pacman        | `git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si` 혹은 선호하시는 [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) 사용   |

:::

:::: details 미리 컴파일된 바이너리 다운로드 - **간편**

<!--@include: @/ko-kr/parts/install-dependencies.md-->

##### asdf 설치

1. https://github.com/asdf-vm/asdf/releases 에서 당신의 운영체제/아키텍처 조합에 맞는 아카이브를 다운로드하세요.
2. 아카이브 안의 `asdf` 바이너리를 `$PATH`에 포함된 디렉토리에 추출하세요.
3. `type -a asdf`를 실행하여 `asdf`가 셸의 `$PATH`에 있는지 확인하세요. `asdf` 바이너리를 위치시킨 디렉토리가 `type` 출력의 첫 줄에 나타나야 합니다. 그렇지 않다면 #2 단계가 올바르게 완료되지 않은 것입니다.

::::

:::: details `go install` 사용

<!--@include: @/ko-kr/parts/install-dependencies.md-->

##### asdf 설치

<!-- x-release-please-start-version -->
1. [Go 설치](https://go.dev/doc/install)
2. `go install github.com/asdf-vm/asdf/cmd/asdf@v0.20.0` 실행
<!-- x-release-please-end -->

::::

:::: details 소스에서 빌드

<!--@include: @/ko-kr/parts/install-dependencies.md-->

##### asdf 설치

<!-- x-release-please-start-version -->
1. asdf 리포지토리 클론:
  ```shell
  git clone https://github.com/asdf-vm/asdf.git --branch v0.20.0
  ```
<!-- x-release-please-end -->
2. `make` 실행
3. `asdf` 바이너리를 `$PATH`에 포함된 디렉토리로 복사하세요.
4. `type -a asdf`를 실행하여 `asdf`가 셸의 `$PATH`에 있는지 확인하세요. `asdf` 바이너리를 위치시킨 디렉토리가 `type` 출력의 첫 줄에 나타나야 합니다. 그렇지 않다면 #3 단계가 올바르게 완료되지 않은 것입니다.

::::

## 2. asdf 설정

::: tip 노트
대부분의 사용자는 asdf가 플러그인, 설치, 심(shim) 데이터를 쓰는 위치를 변경할 **필요가 없습니다**. 하지만 `$HOME/.asdf`가 아닌 디렉토리에 asdf 데이터를 저장하고 싶다면 위치를 변경할 수 있습니다. 셸의 RC 파일에서 `ASDF_DATA_DIR`라는 이름의 변수를 export하여 디렉토리를 지정하세요.
:::

셸과 환경마다 설정 방법이 다릅니다. 아래 내용 중 시스템에 맞는 항목을 펼쳐서 확인해보세요.

::: details Bash

**macOS Catalina 혹은 그 이상**: 기본 셸이 **ZSH**로 변경되었습니다. Bash로 다시 변경하지 않으셨다면, ZSH의 설치방법을 따라주세요.

**Pacman**: 자동완성이 동작하려면 [`bash-completion`](https://wiki.archlinux.org/title/bash#Common_programs_and_options)이 설치되어야 합니다.

##### 심(shim) 디렉토리를 path에 추가 (필수)

다음을 `~/.bash_profile`에 추가하세요:
```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### Custom 데이터 디렉토리 (선택)

다음을 `~/.bash_profile`의 위에서 추가한 줄보다 위에 추가하세요:

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
```

##### 셸 자동완성 설정 (선택)

자동완성은 다음을 `.bashrc`에 추가하여 설정해야 합니다:

```shell
. <(asdf completion bash)
```

:::

::: details Fish

##### 심(shim) 디렉토리를 path에 추가 (필수)

다음을 `~/.config/fish/config.fish`에 추가하세요:

```shell
# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims
```

###### Custom 데이터 디렉토리 (선택)

**Pacman**: 자동완성은 AUR 패키지를 통한 설치로 자동적으로 설정됩니다.

다음을 `~/.config/fish/config.fish`의 위에서 추가한 줄들보다 위에 추가하세요:

```shell
set -gx --prepend ASDF_DATA_DIR "/your/custom/data/dir"
```

##### 셸 자동완성 설정 (선택)

자동완성은 다음 명령어로 직접 설정해야 합니다:

```shell
$ asdf completion fish > ~/.config/fish/completions/asdf.fish
```

:::

::: details Elvish

##### 심(shim) 디렉토리를 path에 추가 (필수)

다음을 `~/.config/elvish/rc.elv`에 추가하세요:

```shell
var asdf_data_dir = ~'/.asdf'
if (and (has-env ASDF_DATA_DIR) (!=s $E:ASDF_DATA_DIR '')) {
  set asdf_data_dir = $E:ASDF_DATA_DIR
}

if (not (has-value $paths $asdf_data_dir'/shims')) {
  set paths = [$path $@paths]
}
```

###### Custom 데이터 디렉토리 (선택)

custom 데이터 디렉토리를 설정하려면 위 스니펫의 다음 줄을 변경하세요:

```diff
-var asdf_data_dir = ~'/.asdf'
+var asdf_data_dir = '/your/custom/data/dir'
```

##### 셸 자동완성 설정 (선택)

```shell
$ asdf completion elvish >> ~/.config/elvish/rc.elv
$ echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> ~/.config/elvish/rc.elv
```

:::

::: details ZSH

**Pacman**: 자동완성은 ZSH 친화적인 위치에 있지만, [ZSH는 자동완성 사용을 위해 반드시 설정 되어야합니다](https://wiki.archlinux.org/index.php/zsh#Command_completion).

##### 심(shim) 디렉토리를 path에 추가 (필수)

다음을 `~/.zshrc`에 추가하세요:
```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### Custom 데이터 디렉토리 (선택)

다음을 `~/.zshrc`의 위에서 추가한 줄보다 위에 추가하세요:

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
```

##### 셸 자동완성 설정 (선택)

자동완성은 ZSH 프레임워크 `asdf` 플러그인([asdf를 위한 oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf)와 같은)을 통해 설정하거나 다음을 통해 설정합니다:

```shell
$ mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
$ asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
```

그런 다음 `.zshrc`에 다음을 추가하세요:

```shell
# append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
```

**노트**

ZSH 프레임워크와 함께 custom `compinit` 설정을 사용중이라면, `compinit`가 프레임워크를 source하는 부분보다 아래에 오도록 해주세요.

자동완성은 ZSH 프레임워크 `asdf`를 통해 설정하거나 [Homebrew의 방법에 따라 설정](https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh)해야 합니다. ZSH 프레임워크를 사용중이라면, `fpath`를 통해 새로운 ZSH 자동완성을 올바르게 사용하려면 관련된 asdf 플러그인이 업데이트 되어야 할 수 있습니다.
:::

::: details PowerShell Core

##### 심(shim) 디렉토리를 path에 추가 (필수)

다음을 `~/.config/powershell/profile.ps1`에 추가하세요:
```shell
# Determine the location of the shims directory
if ($null -eq $ASDF_DATA_DIR -or $ASDF_DATA_DIR -eq '') {
  $_asdf_shims = "${env:HOME}/.asdf/shims"
}
else {
  $_asdf_shims = "$ASDF_DATA_DIR/shims"
}

# Then add it to path
$env:PATH = "${_asdf_shims}:${env:PATH}"
```

###### Custom 데이터 디렉토리 (선택)

다음을 `~/.config/powershell/profile.ps1`의 위에서 추가한 스니펫보다 위에 추가하세요:

```shell
$env:ASDF_DATA_DIR = "/your/custom/data/dir"
```

PowerShell은 셸 자동완성을 사용할 수 없습니다.

:::

::: details Nushell

##### 심(shim) 디렉토리를 path에 추가 (필수)

다음을 `~/.config/nushell/config.nu`에 추가하세요:

```shell
const asdf_data_dir = '~/.asdf' | path expand # or wherever you like
const asdf_shims = [$asdf_data_dir shims] | path join
$env.PATH = $env.PATH | where {$in != $asdf_shims} | prepend $asdf_shims
```

###### Custom 데이터 디렉토리 ($asdf_data_dir != '~/.asdf'일 때 필수)

$asdf_data_dir을 기본값 `~/.asdf`가 아닌 다른 값으로 설정했다면 다음을 `~/.config/nushell/config.nu`에 추가해야 합니다:

```shell
$env.ASDF_DATA_DIR = $asdf_data_dir
```

##### 셸 자동완성 설정 (선택)

필수 설정 이후에, 다음을 `~/.config/nushell/config.nu`에 추가하세요:

```shell
const asdf_cmp = [$asdf_data_dir completions nushell.nu] | path join
mkdir ($asdf_cmp | path dirname)
asdf completion nushell | save -f $asdf_cmp
source $asdf_cmp
```

:::

::: details POSIX Shell

##### 심(shim) 디렉토리를 path에 추가 (필수)

다음을 `~/.profile`에 추가하세요:
```shell
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

###### Custom 데이터 디렉토리 (선택)

다음을 `~/.profile`의 위에서 추가한 줄보다 위에 추가하세요:

```shell
export ASDF_DATA_DIR="/your/custom/data/dir"
```

:::

`asdf` 스크립트들은 `$PATH`를 설정한 **이후에**, 그리고 프레임워크(oh-my-zsh 등)를 source한 **이후에** source 되어야 합니다.

`PATH` 변경이 적용되도록 셸을 재시작하세요. 새로운 터미널 탭을 여는 경우 대부분 해결됩니다.


## 코어 설치 완료!

`asdf` 코어 설치를 완료했습니다 :tada:

`asdf`는 **플러그인**을 설치하고, **도구**를 설치하고, **버전**들을 관리해야 유용합니다. 그 방법을 배우려면 아래 가이드를 계속 진행하세요.

## 4. 플러그인 설치

테스트 목적으로 [`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/) 플러그인을 통해 [Node.js](https://nodejs.org/)를 설치 & 설정해보겠습니다.

### 플러그인 의존성

각 플러그인의 의존성은 플러그인 레포에서 확인할 수 있습니다. 예를 들어 `asdf-nodejs`는 아래 의존성이 필요합니다:

| OS                             | 의존성 설치 명령어                          |
| ------------------------------ | --------------------------------------- |
| Debian                         | `apt-get install dirmngr gpg curl gawk` |
| CentOS/ Rocky Linux/ AlmaLinux | `yum install gnupg2 curl gawk`          |
| macOS                          | `brew install gpg gawk`                 |

의존성을 먼저 설치하는 것이 좋습니다. 어떤 플러그인들은 설치 후 실행되는 (post-install) 훅이 있는데, 이 경우 제대로 동작하지 않을 수 있습니다.

### 플러그인 설치

```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## 5. 버전 설치

이제 `Node.js` 플러그인을 통해 `Node.js`를 설치할 수 있습니다.

`asdf list all nodejs`를 통해 어떤 버전들이 이용가능한지, 혹은 `asdf list all nodejs 14`를 통해 버전의 하위 집합을 확인할 수 있습니다.

이용가능한 `latest` 버전을 설치해 보겠습니다:

```shell
asdf install nodejs latest
```

::: tip 노트
`asdf`는 항상 정확한 버전을 강제합니다. `latest`는 `asdf` 전반에서 사용되는 도우미로, 실행 시점에는 실제 버전으로 변환됩니다.
:::

## 6. 버전 설정

`asdf`는 현재 작업 디렉토리부터 `$HOME` 디렉토리까지 모든 `.tool-versions` 파일에서 도구의 버전 검색을 수행합니다. 검색은 `asdf`가 관리하는 도구를 실행할 때 그 시점에 맞춰(just-in-time) 실행됩니다.

::: warning 경고
도구에 버전이 지정되지 않으면 도구는 실행되지 않고 **에러**가 발생합니다. `asdf current`는 현재 디렉토리에서의 도구 & 버전 정보를 표시하여, 어떤 도구가 버전이 지정되지 않았는지 확인할 수 있습니다.
:::

asdf는 현재 디렉토리에서 `.tool-versions` 파일을 먼저 찾고, 파일을 찾지 못하면 부모 디렉토리에서 `.tool-versions`를 찾을 때까지 파일 트리를 거슬러 올라갑니다. `.tool-versions` 파일을 찾지 못하면 버전 해석 과정이 실패하고 에러가 출력됩니다.

당신이 작업하는 모든 디렉토리에 적용되는 기본 버전을 설정하고 싶다면 `$HOME/.tool-versions`에 버전을 설정할 수 있습니다. 특정 디렉토리가 다른 버전을 설정하지 않는 한, 홈 디렉토리 아래의 모든 디렉토리는 같은 버전이 설정됩니다.

```shell
asdf set -u nodejs 16.5.0
```

`$HOME/.tool-versions`에는 아래와 같이 기록됩니다:

```
nodejs 16.5.0
```

어떤 운영체제들은 `asdf`가 아닌 시스템에 의해 관리되는 도구들이 이미 설치되어 있습니다, `python`이 대표적인 예시입니다. 당신은 `asdf`에게 관리를 시스템으로 위임하도록 알려줘야 합니다. [버전 참조 섹션](/ko-kr/manage/versions.md)을 참고하세요.

asdf가 버전을 찾는 첫 번째 위치는 현재 작업 디렉토리(`$PWD/.tool-versions`)입니다. 이는 프로젝트의 소스 코드나 Git 리포지토리를 담고 있는 디렉토리일 수 있습니다. 원하는 디렉토리에서 `asdf set`을 사용해 버전을 설정할 수 있습니다:

```shell
asdf set nodejs 16.5.0
```

`$PWD/.tool-versions`에는 아래와 같이 기록됩니다:

```
nodejs 16.5.0
```

### 기존 도구 버전 파일 사용하기

`asdf`는 다른 버전 매니저의 기존 버전 파일로부터의 마이그레이션을 지원합니다. 예시: `rbenv`의 경우 `.ruby-version`. 이는 각 플러그인 기준으로 지원됩니다.

[`asdf-nodejs`](https://github.com/asdf-vm/asdf-nodejs/)는 `.nvmrc`와 `.node-version` 파일을 모두 지원합니다. 이를 활성화하려면, 다음을 `asdf` 설정 파일 `$HOME/.asdfrc`에 추가하세요:

```
legacy_version_file = yes
```

더 많은 설정 옵션은 [configuration](/ko-kr/manage/configuration.md) 페이지를 참고하세요.

## 가이드 완료!

`asdf` 시작하기 가이드가 끝났습니다. :tada: 당신은 이제 당신의 프로젝트의 `nodejs` 버전을 관리할 수 있습니다. 프로젝트의 각 도구를 같은 방식으로 관리해보세요!

`asdf`는 이외에도 여러가지 명령어를 가지고 있고, `asdf --help` 혹은 `asdf`를 통해 모두 확인할 수 있습니다. 핵심 명령어들은 세 가지 카테고리로 나뉩니다:

- [코어 `asdf`](/ko-kr/manage/core.md)
- [플러그인](/ko-kr/manage/plugins.md)
- [도구 버전](/ko-kr/manage/versions.md)

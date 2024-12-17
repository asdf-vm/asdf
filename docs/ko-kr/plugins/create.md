# 플러그인 생성하기

플러그인은 언어 / 툴의 버전 관리를 지원하는 실행 가능한 스크립트들이 있는 
Git 리포지토리입니다. 이 스크립트들은 asdf에 의해 특정 명령어들을 받아 
`asdf list-all <name>`, `asdf install <name> <version>` 
등의 지원을 위해 실행됩니다.

## 빠른 시작

자체 플러그인을 만드는 것을 시작하는 두 가지 옵션이 있습니다:

1. [asdf-vm/asdf-plugin-template](https://github.com/asdf-vm/asdf-plugin-template)
   리포지토리 사용해서
   기본 스크립트가 구현된 (`asdf-<tool_name>` 이름으로) 플러그인 리포지토리
   [생성하기](https://github.com/asdf-vm/asdf-plugin-template/generate). 리포지토리가 생성되면,
   그 리포지토리를 clone하고 템플릿을 
   유기적으로 업데이트하여 
   `setup.bash` 스크립트를 실행합니다.
2. `asdf-<tool_name>`로 이룸 붙인 리포지토리를 시작하고 
   아래 문서에 필수 스크립트들을 구현하세요.

### 플리그인 스크립트들을 위한 황금률

- 스크립트는 다른 `asdf` 명령어를 호출하면 **안됩니다**.
- 셸 툴/명령어의 dependency를 최소로 유지하세요.
- non-portable 툴이나 명령어 플래그의 사용을 피하세요. 예를 들어, `sort -V`.
  asdf core를 참고하세요
  [금지된 명령어 목록](https://github.com/asdf-vm/asdf/blob/master/test/banned_commands.bats)

## 스크립트 개요

asdf에서 호출 가능한 스크립트의 전체 목록입니다.

| 스크립트                                                                                       | 설명                                                                       |
| :--------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------- |
| [bin/list-all](#bin-list-all) <Badge type="tip" text="필수" vertical="middle" />               | 모든 설치 가능한 버전들을 나열                                             |
| [bin/download](#bin-download) <Badge type="tip" text="필수" vertical="middle" />               | 지정한 버전에 대한 소스 코드 또는 바이너리 다운로드                        |
| [bin/install](#bin-install) <Badge type="tip" text="필수" vertical="middle" />                 | 지정된 버전을 설치                                                         |
| [bin/latest-stable](#bin-latest-stable) <Badge type="warning" text="추천" vertical="middle" /> | 지정된 도구의 최신 안정 버전 나열                                          |
| [bin/help.overview](#bin-help.overview)                                                        | 플러그인 및 도구에 대한 일반적인 설명을 출력                               |
| [bin/help.deps](#bin-help.deps)                                                                | 운영 체제별 dependencies 목록 출력                                         |
| [bin/help.config](#bin-help.config)                                                            | 플러그인 및 툴 설정 정보 출력                                              |
| [bin/help.links](#bin-help.links)                                                              | 플러그인 및 툴에 대한 링크 목록 출력                                       |
| [bin/list-bin-paths](#bin-list-bin-paths)                                                      | shim들을 생성하기 위해 바이너리 파일이 있는 디렉토리에 대한 상대 경로 나열 |
| [bin/exec-env](#bin-exec-env)                                                                  | 바이너리 실행을 위한 환경 준비                                             |
| [bin/exec-path](#bin-exec-path)                                                                | 툴 버전의 실행파일 경로 출력                                               |
| [bin/uninstall](#bin-uninstall)                                                                | 툴의 특정 버전 제거                                                        |
| [bin/list-legacy-filenames](#bin-list-legacy-filenames)                                        | 레거시 버전 파일의 이름 출력: `.ruby-version`                              |
| [bin/parse-legacy-file](#bin-parse-legacy-file)                                                | 레거시 버전 파일들을 위한 맞춤 parser                                      |
| [bin/post-plugin-add](#bin-post-plugin-add)                                                    | 플러그인이 추가된 후 실행될 훅                                             |
| [bin/post-plugin-update](#bin-post-plugin-update)                                              | 플러그인이 업데이트 된 후 실행될 훅                                        |
| [bin/pre-plugin-remove](#bin-pre-plugin-remove)                                                | 플러그인이 제거되기 전 실행될 훅                                           |

어떤 명령어가 어떤 스크립트를 호출하는지 확인하려면, 각 스크립트에 대한 자세한 문서를
참조하세요.

## 환경 변수 개요

모든 스크립트에서 사용되는 환경 변수의 전체 목록입니다.

| 환경 변수                | 설명                                                              |
| :----------------------- | :---------------------------------------------------------------- |
| `ASDF_INSTALL_TYPE`      | `version` 또는 `ref`                                              |
| `ASDF_INSTALL_VERSION`   | `ASDF_INSTALL_TYPE`에 따른 풀 버전 번호 또는 Git Ref              |
| `ASDF_INSTALL_PATH`      | 툴이 설치 _되어야하는_ 혹은 _되어있는_ 경로                       |
| `ASDF_CONCURRENCY`       | 소스 코드를 컴파일할 때 사용할 코어 수. `make-j`를 설정할 때 유용 |
| `ASDF_DOWNLOAD_PATH`     | `bin/download`에 의해 소스 코드 또는 바이너리가 다운로드 된 경로  |
| `ASDF_PLUGIN_PATH`       | 플러그인이 설치된 경로                                            |
| `ASDF_PLUGIN_SOURCE_URL` | 플러그인의 소스 URL                                               |
| `ASDF_PLUGIN_PREV_REF`   | 플러그인 리포지토리의 이전 `git-ref`                              |
| `ASDF_PLUGIN_POST_REF`   | 플러그인 리포지토리의 업데이트 된 `git-ref`                       |
| `ASDF_CMD_FILE`          | source 되는 파일의 전체 경로를 해결                               |

::: tip 노트

**모든 스크립트에서 모든 환경 변수를 사용할 수 있는 것은 아닙니다.** 아래 각 스크립트에 대한
문서를 확인하여 사용할 수 있는 환경 변수들을 확인하세요.

:::

## 필수적 스크립트

### `bin/list-all` <Badge type="tip" text="필수" vertical="middle" />

**설명**

설치 가능한 모든 버전 나열.

**출력 형식**

**공백으로 구분된** 문자열을 반드시 출력. 예를 들어:

```txt
1.0.1 1.0.2 1.3.0 1.4
```

최신 버전이 마지막에 와야 합니다.

asdf core는 각 버전을 각각의 행에 출력하여, 일부 버전을 화면 밖으로
밀어낼 가능성이 있습니다.

**정렬**

웹사이트의 릴리스 페이지에서 버전을 가져오는 경우에는 
이미 올바른 순서로 되어 있는 경우가 많기 때문에 제공된 순서대로 두는 것이 
좋습니다. 역순으로 되어 있는 경우 `tac`을 통해 해당 버전들을 바로 잡는것으로
충분합니다.

정렬이 불가피한 경우, `sort -V`는 사용이 불가능하므로, 다음 중 하나를 제안합니다:

- [Git 정렬 기능 사용](https://github.com/asdf-vm/asdf-plugin-template/blob/main/template/lib/utils.bash)
  (Git `v2.18.0` 이상 필요)
- [맞춤 정렬 함수 작성](https://github.com/vic/asdf-idris/blob/master/bin/list-all#L6)
  (`sed`, `sort` & `awk` 필요)

**스크립트에서 사용 가능한 환경 변수**

이 스크립트에는 환경 변수가 제공되지 않습니다.

**이 스크립트를 호출하는 명령어**

- `asdf list all <name> [version]`
- `asdf list all nodejs`: 이 스크립트에 의해 반환된 모든 버전을 나열합니다,
  한 행에 한개씩.
- `asdf list all nodejs 18`: 이 스크립트에 의해 반환된 모든 버전을 나열하며,
  각 행에 하나씩, `18`로 시작하는 모든 버전에 필터가 적용됩니다.

**asdf core에서 호출 시그니처**

제공되는 매개변수는 없습니다.

```bash
"${plugin_path}/bin/list-all"
```

---

### `bin/download` <Badge type="tip" text="필수" vertical="middle" />

**설명**

지정된 장소에 지정된 버전에 대한 소스 코드 또는 바이너리 다운로드

**구현 세부사항**

- 스크립트는 소스 또는 바이너리를 `ASDF_DOWNLOAD_PATH`에서 지정된 디렉토리에 다운로드해야합니다.
- 압축 해제된 소스 코드 또는 바이너리만 `ASDF_DOWNLOAD_PATH` 디렉토리에 위치해야합니다.
- 실패 시에는 `ASDF_DOLOAD_PATH`에 어떠한 파일도 남아서는 안 됩니다.
- 성공 시에는 `0`이 종료 코드입니다.
- 실패 시에는 0이 아닌 상태의 종료 코드입니다.

**레거시 플러그인**

비록 이 스크립트는 모든 플러그인에서 _필수_로 되어 있지만, 이 스크립트가 도입되기 이전의 "레거시" 플러그인에서는 _선택_ 입니다.

이 스크립트가 없는 경우, asdf는 `bin/install` 스크립트가 있다고 가정하고 해당 버전을 다운로드 **그리고** 설치합니다.

레거시 플러그인 지원은 최종적으로 제거될 예정이기 때문에 앞으로 작성할 모든 플러그인에서 이 스크립트를 포함해야합니다.

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_INSTALL_TYPE`: `version` 또는 `ref`
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`의 경우, 풀 버전 번호.
  - `ASDF_INSTALL_TYPE=ref`의 경우, Git ref (태그/커밋/브랜치).
- `ASDF_INSTALL_PATH`: 툴이 설치 _되어있는_, 또는 _되어야하는_ 경로.
- `ASDF_DOWNLOAD_PATH`: 소스 코드 또는 바이너리 파일이 다운로드 된 경로.

**이 스크립트를 호출하는 명령어**

- `asdf install <tool> [version]`
- `asdf install <tool> latest[:version]`
- `asdf install nodejs 18.0.0`: Node.js 버전 `18.0.0`의 소스 코드 또는 바이너리를 다운로드하고
  `ASDF_DOWLOAD_PATH` 디렉토리에 저장. 그 다음 `bin/install` 스크립트를 실행.

**asdf core에서 호출 시그니처**

제공되는 매개변수는 없습니다.

```bash
"${plugin_path}"/bin/download
```

---

### `bin/install` <Badge type="tip" text="필수" vertical="middle" />

**설명**

특정 버전의 도구를 지정된 위치에 설치.

**구현 세부사항**

- 스크립트는 `ASDF_INSTALL_PATH` 경로에 지정된 버전을 설치해야합니다.
- Shim은 `$ASDF_INSTALL_PATH/bin`에 있는 어떠한 파일에 대해서든 기본적으로 생성됩니다. 이 동작은
선택적 [bin/list-bin-paths](#binlist-bin-paths) 스크립트로 맞춤 설정 가능합니다.
- 성공 시에는 `0`이 종료 코드입니다.
- 실패 시에는 0이 아닌 상태의 종료 코드입니다.
- TOCTOU(Time-of-Check-to-Off-Use) 문제를 방지하려면, 툴의 빌드 및 설치가 성공적이라고 판단될때만 스크립트에서 파일을 `ASDF_INSTALL_PATH`에 배치합니다.

**레거시 플러그인**

`bin/download` 스크립트가 없는 경우, 이 스크립트는 지정된 버전을 다운로드 **그리고** 설치해야합니다.

`0.7._`보다 이전 그리고 `0.8._`보다 이후 asdf 코어 버전들의 호환성을 확인하려면, `ASDF_DOWNLOAD_PATH` 환경 변수가 있는지 확인합니다.
그 환경 변수가 존재하는 경우, 이미 `bin/download` 스크립트가 그 버전을 다운로드했다고 가정하고, 존재하지 않으면 `bin/install` 스크립트에서 소스 코드를 다운로드합니다.

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_INSTALL_TYPE`: `version` 또는 `ref`
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`의 경우, 풀 버전 번호.
  - `ASDF_INSTALL_TYPE=ref`의 경우, Git ref (태그/커밋/브랜치).
- `ASDF_INSTALL_PATH`: 툴이 설치 _되어있는_, 또는 _되어야하는_ 경로.
- `ASDF_CONCURRENCY`: 소스 코드를 컴파일할 때 사용할 코어 수. `make-j`를 설정할 때 유용.
- `ASDF_DOWNLOAD_PATH`: 소스 코드 또는 바이너리 파일이 다운로드 된 경로.

**이 스크립트를 호출하는 명령어**

- `asdf install`
- `asdf install <tool>`
- `asdf install <tool> [version]`
- `asdf install <tool> latest[:version]`
- `asdf install nodejs 18.0.0`: Node.js 버전 `18.0.0`을
  `ASDF_INSTALL_PATH` 디렉토리에 설치.

**asdf core에서 호출 시그니처**

제공되는 매개변수는 없습니다.

```bash
"${plugin_path}"/bin/install
```

## 선택적 스크립트

### `bin/latest-stable` <Badge type="warning" text="추천" vertical="middle" />

**설명**

도구의 최신 안정 버전을 결정합니다. 이 스크립트가 존재하지 않는 경우, asdf 코어는 `bin/list-all`의 출력을 비의도적으로 `tail`합니다.

**구현 세부사항**

- 스크립트는 도구의 최신 안정 버전을 표준 출력에 출력해야합니다.
- 비안정판이나 릴리스 후보판은 제외되어야 합니다.
- 필터 쿼리는 스크립트의 첫 번째 인수로 제공됩니다 이 쿼리는 버전 번호나 툴 제공자에 의한 출력값을 필터하기 위해 사용되어야 합니다.
  - 예를 들어 [ruby 플러그인](https://github.com/asdf-vm/asdf-ruby)에서의 `asdf list all ruby`는 `jruby`, `rbx`, `truffleruby` 등의 많은 제공자들의 Ruby 버전 목록을 출력합니다. 사용자가 제공한 필터는 플러그인이 유의적 버전 및/또는 공급자를 필터링하는 데 사용될 수 있습니다.
    ```
    > asdf latest ruby
    3.2.2
    > asdf latest ruby 2
    2.7.8
    > asdf latest ruby truffleruby
    truffleruby+graalvm-22.3.1
    ```
- 성공 시에는 `0`이 종료 코드입니다.
- 실패 시에는 0이 아닌 상태의 종료 코드입니다.

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_INSTALL_TYPE`: `version` 또는 `ref`
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`의 경우, 풀 버전 번호.
  - `ASDF_INSTALL_TYPE=ref`의 경우, Git ref (태그/커밋/브랜치).
- `ASDF_INSTALL_PATH`: 툴이 설치 _되어있는_, 또는 _되어야하는_ 경로.

**이 스크립트를 호출하는 명령어**

- `asdf global <tool> latest`: 툴의 글로벌 버전을 해당 툴의 최신 안정 버전으로 설정합니다.
- `asdf local <name> latest`: 툴의 로컬 버전을 해당 툴의 최신 안정 버전으로 설정합니다.
- `asdf install <tool> latest`: 최신 버전의 툴을 설치합니다.
- `asdf latest <tool> [<version>]`: 선택적인 필터를 기반으로 도구의 최신 버전을 출력합니다.
- `asdf latest --all`: asdf에서 관리하는 모든 툴의 최신 버전과 설치 여부를 출력합니다.

**asdf core에서 호출 시그니처**

이 스크립트는 필터 쿼리라는 하나의 인수를 받습니다.

```bash
"${plugin_path}"/bin/latest-stable "$query"
```

---

### `bin/help.overview`

**설명**

플러그인 및 관리 중인 툴에 대한 일반적인 설명을 출력.

**구현 세부사항**

- 플러그인에 대한 도움말 출력을 표시하려면 이 스크립트가 필요합니다.
- asdf 코어가 머리말를 인쇄하므로 머리말을 출력해서는 안 됩니다.
- 자유로운 형식의 텍스트로 출력해도 상관없지만 짧은 한 단락 정도의 설명이 이상적입니다.
- 핵심이 되는 asdf-vm 문서에서 이미 설명되어 있는 정보는 출력하지 않아야 합니다.
- 운영 체제와 설치된 툴의 버전에 맞게 출력해야합니다 (필요에 따라 `ASDF_INSTALL_VERSION` 및 `ASDF_INSTALL_TYPE` 환경 변수의 값을 사용하십시오).
- 성공 시에는 `0`이 종료 코드입니다.
- 실패 시에는 0이 아닌 상태의 종료 코드입니다.

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_INSTALL_TYPE`: `version` 또는 `ref`
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`의 경우, 풀 버전 번호.
  - `ASDF_INSTALL_TYPE=ref`의 경우, Git ref (태그/커밋/브랜치).
- `ASDF_INSTALL_PATH`: 툴이 설치 _되어있는_, 또는 _되어야하는_ 경로.

**이 스크립트를 호출하는 명령어**

- `asdf help <name> [<version>]`: 플러그인 및 도구 문서를 출력

**asdf core에서 호출 시그니처**

```bash
"${plugin_path}"/bin/help.overview
```

---

### `bin/help.deps`

**설명**

운영 체제에 맞는 dependencies 목록을 출합니다. 한 행마다 한 개의 dependency.

```bash
git
curl
sed
```

**구현 세부사항**

- 이 스크립트의 출력되기 위해서는 `bin/help.overview`가 필요합니다.
- 운영 체제와 설치된 툴의 버전에 맞게 출력해야합니다 (필요에 따라 `ASDF_INSTALL_VERSION` 및 `ASDF_INSTALL_TYPE` 환경 변수의 값을 사용하십시오).
- 성공 시에는 `0`이 종료 코드입니다.
- 실패 시에는 0이 아닌 상태의 종료 코드입니다.

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_INSTALL_TYPE`: `version` 또는 `ref`
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`의 경우, 풀 버전 번호.
  - `ASDF_INSTALL_TYPE=ref`의 경우, Git ref (태그/커밋/브랜치).
- `ASDF_INSTALL_PATH`: 툴이 설치 _되어있는_, 또는 _되어야하는_ 경로.

**이 스크립트를 호출하는 명령어**

- `asdf help <name> [<version>]`: 플러그인 및 도구 문서를 출력

**asdf core에서 호출 시그니처**

```bash
"${plugin_path}"/bin/help.deps
```

---

### `bin/help.config`

**설명**

플러그인 및 도구에 필수적 또는 선택적 설정 출력. 예를 들어, 도구를 설치하거나 컴파일하는 데 필요한 환경 변수나 기타 플래그를 설명.

**구현 세부사항**

- 이 스크립트의 출력되기 위해서는 `bin/help.overview`가 필요합니다.
- 자유로운 형식의 텍스트로 출력할 수 있습니다.
- 운영 체제와 설치된 툴의 버전에 맞게 출력해야합니다 (필요에 따라 `ASDF_INSTALL_VERSION` 및 `ASDF_INSTALL_TYPE` 환경 변수의 값을 사용하십시오).
- 성공 시에는 `0`이 종료 코드입니다.
- 실패 시에는 0이 아닌 상태의 종료 코드입니다.

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_INSTALL_TYPE`: `version` 또는 `ref`
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`의 경우, 풀 버전 번호.
  - `ASDF_INSTALL_TYPE=ref`의 경우, Git ref (태그/커밋/브랜치).
- `ASDF_INSTALL_PATH`: 툴이 설치 _되어있는_, 또는 _되어야하는_ 경로.

**이 스크립트를 호출하는 명령어**

- `asdf help <name> [<version>]`: 플러그인 및 도구 문서를 출력

**asdf core에서 호출 시그니처**

```bash
"${plugin_path}"/bin/help.config
```

---

### `bin/help.links`

**설명**

플러그인 및 툴과 관련된 링크 목록을 출력. 한 행마다 한 개의 링크.

```bash
Git Repository:	https://github.com/vlang/v
Documentation:	https://vlang.io
```

**구현 세부사항**

- 이 스크립트의 출력되기 위해서는 `bin/help.overview`가 필요합니다.
- 한행마다 한 개의 링크.
- 형식은 다음 중에 하나여야합니다:
  - `<title>: <link>`
  - 또는 그냥 `<link>`
- 운영 체제와 설치된 툴의 버전에 맞게 출력해야합니다 (필요에 따라 `ASDF_INSTALL_VERSION` 및 `ASDF_INSTALL_TYPE` 환경 변수의 값을 사용하십시오).
- 성공 시에는 `0`이 종료 코드입니다.
- 실패 시에는 0이 아닌 상태의 종료 코드입니다.

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_INSTALL_TYPE`: `version` 또는 `ref`
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`의 경우, 풀 버전 번호.
  - `ASDF_INSTALL_TYPE=ref`의 경우, Git ref (태그/커밋/브랜치).
- `ASDF_INSTALL_PATH`: 툴이 설치 _되어있는_, 또는 _되어야하는_ 경로.

**이 스크립트를 호출하는 명령어**

- `asdf help <name> [<version>]`: 플러그인 및 도구 문서를 출력

**asdf core에서 호출 시그니처**

```bash
"${plugin_path}"/bin/help.links
```

---

### `bin/list-bin-paths`

**설명**

툴의 특정 버전에서 실행파일이 포함된 디렉토리 목록을 출력.

**구현 세부사항**

- 이 스크립트가 존재하지 않는 경우, asdf는 `"${ASDF_INSTALL_PATH}"/bin` 디렉토리 내에 있는 바이너리들을 찾아 그 바이너리를 위한 shim들을 생성합니다.
- 실행파일이 포함된 디렉토리의 경로를 공백으로 구분하여 출력합니다.
- 경로는 `ASDF_INSTALL_PATH`로의 상대 경로이어야 합니다. 출력 예시는 다음과 같습니다:

```bash
bin tools veggies
```

이는 asdf가 그 파일들을 위한 shim들을 다음 위치에 생성하게 지시합니다:
- `"${ASDF_INSTALL_PATH}"/bin`
- `"${ASDF_INSTALL_PATH}"/tools`
- `"${ASDF_INSTALL_PATH}"/veggies`

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_INSTALL_TYPE`: `version` 또는 `ref`
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`의 경우, 풀 버전 번호.
  - `ASDF_INSTALL_TYPE=ref`의 경우, Git ref (태그/커밋/브랜치).
- `ASDF_INSTALL_PATH`: 툴이 설치 _되어있는_, 또는 _되어야하는_ 경로.

**이 스크립트를 호출하는 명령어**

- `asdf install <tool> [version]`: 초기에 바이너리들을 위한 shim들 생성.
- `asdf reshim <tool> <version>`: 바이너리들을 위한 shim들 재생성.

**asdf core에서 호출 시그니처**

```bash
"${plugin_path}/bin/list-bin-paths"
```

---

### `bin/exec-env`

**설명**

툴 바이너리의 shim을 실행하기 전에 환경을 준비.

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_INSTALL_TYPE`: `version` 또는 `ref`
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`의 경우, 풀 버전 번호.
  - `ASDF_INSTALL_TYPE=ref`의 경우, Git ref (태그/커밋/브랜치).
- `ASDF_INSTALL_PATH`: 툴이 설치 _되어있는_, 또는 _되어야하는_ 경로.

**이 스크립트를 호출하는 명령어**

- `asdf which <command>`: 실행파일의 경로 표시
- `asdf exec <command> [args...]`: 현재 버전에서 shim 명령을 실행
- `asdf env <command> [util]`: shim 명령어 실행 시 사용되는 환경에서 유틸리티(기본값: `env`)를 실행.

**asdf core에서 호출 시그니처**

```bash
"${plugin_path}/bin/exec-env"
```

---

### `bin/exec-path`

툴의 특정 버전의 실행파일 경로를 가져옵니다.
실행파일에 대한 상대 경로를 문자열로 출력해야합니다.
이는 플러그인이 shim에서 지정한 실행파일 경로를 조건부로 덮어쓰게 하거나,
그렇지 않으면 shim에서 지정한 기본 경로를 반환합니다.

**설명**

툴의 특정 버전의 실행파일 경로를 가져옵니다.

**구현 세부사항**

- 실행파일에 대한 상대 경로를 문자열로 출력.
- Shim에서 지정한 실행파일 경로를 조건부로 덮어쓰거나, 그렇지 않으면 shim에서 지정한 기본 경로를 반환.

```shell
Usage:
  plugin/bin/exec-path <install-path> <command> <executable-path>

Example Call:
  ~/.asdf/plugins/foo/bin/exec-path "~/.asdf/installs/foo/1.0" "foo" "bin/foo"

Output:
  bin/foox
```

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_INSTALL_TYPE`: `version` 또는 `ref`
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`의 경우, 풀 버전 번호.
  - `ASDF_INSTALL_TYPE=ref`의 경우, Git ref (태그/커밋/브랜치).
- `ASDF_INSTALL_PATH`: 툴이 설치 _되어있는_, 또는 _되어야하는_ 경로.

**이 스크립트를 호출하는 명령어**

- `asdf which <command>`: 실행파일의 경로 표시
- `asdf exec <command> [args...]`: 현재 버전에서 shim 명령을 실행
- `asdf env <command> [util]`: shim 명령어 실행 시 사용되는 환경에서 유틸리티(기본값: `env`)를 실행.

**asdf core에서 호출 시그니처**

```bash
"${plugin_path}/bin/exec-path" "$install_path" "$cmd" "$relative_path"
```

---

### `bin/uninstall`

**설명**

툴의 지정된 버전을 제거합니다.

**출력 형식**

출력값은 `stdout` 또는 `stderr`에 적절히 송신 되어야 합니다. 어떠한 출력값도 후속 코어 실행에 의해 사용되지 않습니다.

**스크립트에서 사용 가능한 환경 변수**

이 스크립트에는 환경 변수가 제공되지 않습니다.

**이 스크립트를 호출하는 명령어**

- `asdf list all <name> <version>`
- `asdf uninstall nodejs 18.15.0`: nodejs의 `18.15.0` 버전을 제거, `npm i -g`로 설치된 모든 글로벌 shim들 또한 제거.

**asdf core에서 호출 시그니처**

제공되는 매개변수는 없습니다.

```bash
"${plugin_path}/bin/uninstall"
```

---

### `bin/list-legacy-filenames`

**설명**

툴 버전을 결정하는 데 사용된 레거시 설정 파일 목록을 출력.

**구현 세부사항**

- 파일이름들의 목록을 공백으로 구분하여 출력.
  ```bash
  .ruby-version .rvmrc
  ```
- `"${HOME}"/.asdfrc`에서 `legacy_version_file` 옵션을 활성화한 사용자에게만 적용됩니다.

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_INSTALL_TYPE`: `version` 또는 `ref`
- `ASDF_INSTALL_VERSION`:
  - `ASDF_INSTALL_TYPE=version`의 경우, 풀 버전 번호.
  - `ASDF_INSTALL_TYPE=ref`의 경우, Git ref (태그/커밋/브랜치).
- `ASDF_INSTALL_PATH`: 툴이 설치 _되어있는_, 또는 _되어야하는_ 경로.

**이 스크립트를 호출하는 명령어**

툴 버전을 가져오는 모든 명령에서 호출됩니다.

**asdf core에서 호출 시그니처**

제공되는 매개변수는 없습니다.

```bash
"${plugin_path}/bin/list-legacy-filenames"
```

---

### `bin/parse-legacy-file`

**설명**

asdf에 의해 발견된 레거시 파일을 parse하여 툴의 버전을 결정. 자바스크립트의 `package.json`이나 Go 언어의 `go.mod`와 같은 파일에서 버전 번호를 추출하는 데 유용.

**구현 세부사항**

- 이 스크립트가 존재하지 않는 경우, asdf는 단순히 레거시 파일을 `cat`하여 버전을 결정합니다.
- 다음과 같은 상황에서도 **결정론적**이고 항상 동일하고 정확한 버전을 반환해야합니다:
  - 동일한 레거시 파일을 구문 parsing할 때.
  - 무엇이 설치되어 있는지 또는 레거시 버전이 유효하거나 완전한지는 관계 없이. 일부 레거시 파일 형식은 맞지 않을 수도 있습니다.
- 아래와 같이 버전 번호를 한 줄로 출력해 주세요:
  ```bash
  1.2.3
  ```

**스크립트에서 사용 가능한 환경 변수**

이 스크립트가 호출되기 전에 환경 변수가 설정되지 않습니다.

**이 스크립트를 호출하는 명령어**

툴 버전을 가져오는 모든 명령에서 호출됩니다.

**asdf core에서 호출 시그니처**

이 스크립트는 레거시 파일의 내용을 읽기 위해 레거시 파일의 경로라는 하나의 인수를 받습니다.

```bash
"${plugin_path}/bin/parse-legacy-file" "$file_path"
```

---

### `bin/post-plugin-add`

**설명**

이 콜백 스크립트는 asdf의 `asdf plugin add <tool>` 명령어로 플러그인이 _추가된_ **후에** 실행됩니다.

관련된 명령어 훅들을 참조하세요:

- `pre_asdf_plugin_add`
- `pre_asdf_plugin_add_${plugin_name}`
- `post_asdf_plugin_add`
- `post_asdf_plugin_add_${plugin_name}`

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_PLUGIN_PATH`: 플러그인이 설치된 경로.
- `ASDF_PLUGIN_SOURCE_URL`: 플러그인 소스의 URL. 로컬 디렉토리 경로일 수 있음.

**asdf core에서 호출 시그니처**

제공되는 매개변수는 없습니다.

```bash
"${plugin_path}/bin/post-plugin-add"
```

---

### `bin/post-plugin-update`

**설명**

이 콜백 스크립트는 asdf가 `asdf plugin update <tool> [<git-ref>]` 커맨드로 플러그인 _업데이트_ 를 다운로드한 **후에** 실행됩니다.

관련된 명령어 훅들을 참조하세요:

- `pre_asdf_plugin_update`
- `pre_asdf_plugin_update_${plugin_name}`
- `post_asdf_plugin_update`
- `post_asdf_plugin_update_${plugin_name}`

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_PLUGIN_PATH`: 플러그인이 설치된 경로.
- `ASDF_PLUGIN_PREV_REF`: 플러그인의 이전 git-ref
- `ASDF_PLUGIN_POST_REF`: 플러그인의 업데이트 된 git-ref

**asdf core에서 호출 시그니처**

제공되는 매개변수는 없습니다.

```bash
"${plugin_path}/bin/post-plugin-update"
```

---

### `bin/pre-plugin-remove`

**설명**

asdf가 `asdf plugin remove <tool>` 커맨드로 플러그인을 제거하기 **전에** 이 콜백 스크립트를 실행시키세요.

관련된 명령어 훅들을 참조하세요:

- `pre_asdf_plugin_remove`
- `pre_asdf_plugin_remove_${plugin_name}`
- `post_asdf_plugin_remove`
- `post_asdf_plugin_remove_${plugin_name}`

**스크립트에서 사용 가능한 환경 변수**

- `ASDF_PLUGIN_PATH`: 플러그인이 설치된 경로.

**asdf core에서 호출 시그니처**

제공되는 매개변수는 없습니다.

```bash
"${plugin_path}/bin/pre-plugin-remove"
```

<!-- TODO: document command hooks -->
<!-- ## Command Hooks -->

## asdf CLI 확장 명령어 <Badge type="danger" text="고급" vertical="middle" />

`lib/commands/command*.bash` 스크립트 또는 플러그인 이름을 하위명령어로 사용하여
asdf 명령줄 인터페이스를 통해 호출할 수 있는 실행파일을 제공함으로써
새로운 asdf 명령어를 정의할 수 있습니다.

예를 들면, `foo`라고 하는 플러그인이 있다고 하면:

```shell
foo/
  lib/commands/
    command.bash
    command-bat.bash
    command-bat-man.bash
    command-help.bash
```

사용자는 아래 명령을 실행할 수 있게 됩니다:

```shell
$ asdf foo         # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash`
$ asdf foo bar     # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command.bash bar`
$ asdf foo help    # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-help.bash`
$ asdf foo bat man # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat-man.bash`
$ asdf foo bat baz # same as running `$ASDF_DATA_DIR/plugins/foo/lib/commands/command-bat.bash baz`
```

플러그인 개발자는 이 기능을 사용하여 툴과 관련된 유틸리티를 제공하거나,
asdf 자체의 명령어 확장 플러그인을 생성할 수 있습니다.

실행 가능 비트(executable bit)가 부여되어 있는 경우, asdf 실행을 대신하여
해당 스크립트가 실행됩니다.

실행 가능 비트(executable bit)가 부여되지 않은 경우, asdf는 해당 스크립트를 Bash 스크립트로 source합니다.

`$ASDF_CMD_FILE`는 source 되는 파일의 전체 경로를 해결합니다.

[`haxe`](https://github.com/asdf-community/asdf-haxe)는
이 기능을 사용하는 플러그인의 좋은 예시입니다.
이 플러그인은 Haxe 실행파일이 해당 디렉토리에서 상대적으로 동적 라이브러리를 찾으려하는
문제해결을 위해 `asdf haxe neko-dylibs-link`를 제공합니다.

플러그인 README에는 asdf 확장 명령어에 관한 것을 반드시 기재하도록 하십시오.

## 맞춤 Shim 템플릿 <Badge type="danger" text="고급" vertical="middle" />

::: warning 경고

**반드시** 필요한 경우에만 사용하세요.

:::

asdf에서는 맞춤 shim 템플릿을 사용할 수 있습니다. `foo`라고 하는 실행파일에 대해,
플러그인 내에 `shims/foo` 파일이 존재하면, asdf는 표준 shim 템플릿을
사용하는 대신 그 파일을 복사합니다.

**이 기능은 현명하게 사용해야합니다.**

asdf 코어팀이 파악하고 있는 것은, 이 기능은 오직 공식 플러그인
[Elixir 플러그인](https://github.com/asdf-vm/asdf-elixir)에서만 사용되고 있습니다.
이는 실행파일은 실행파일일 뿐만 아니라 Elixir 파일로도 읽히기 때문입니다.
이 때문에 표준 Bash shim을 사용할 수 없습니다.

## 테스팅

`asdf`에는 플러그인을 테스트하기 위한 `plugin-test` 명령어가 포함되어 있습니다:

```shell
asdf plugin test <plugin_name> <plugin_url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git_ref>] [test_command...]
```

- `<plugin_name>` 및 `<plugin_url>`는 필수적입니다
- 옵션에서 `[--asdf-tool-version <version>]`를 지정하면, 해당 지정된 버전의 툴이 설치됩니다.
  기본값은 `asdf latest <plugin-name>`입니다.
- 옵션에서 `[--asdf-plugin-gitref <git_ref>]`를 지정하면,
  그 커밋/브랜치/태그로 플러그인 자체를 체크아웃합니다.
  이것은 플러그인 CI에서 풀 요청을 테스트할 때 유용합니다.
- 선택적 매개변수 `[test_command...]`는 설치된 툴이 올바르게 동작하는지 확인하기위해 실행시키는 명령어입니다.
  일반적으로 `<tool> --version` 또는
  `<tool> --help`입니다. 예를 들어, NodeJS 플러그인을 테스트하기 위해, 다음을 실행시킬 수 있습니다
  ```shell
  # asdf plugin test <plugin_name>  <plugin_url>                               [test_command]
    asdf plugin test nodejs         https://github.com/asdf-vm/asdf-nodejs.git node --version
  ```

::: tip 노트

리눅스와 맥 운영체제 양쪽 CI 환경에서 모두 테스트하는 것을 권장합니다.

:::

### GitHub Action

[asdf-vm/actions](https://github.com/asdf-vm/actions) 리포지토리는
GitHub에서 호스팅되는 플러그인을 테스트하기 위한 GitHub Action을 제공합니다.
`.github/workflows/test.yaml` 액션 워크플로우 예시:

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

### TravisCI 설정

`.travis.yml` 예시 파일, 필요에 따라 바꿔 사용하세요:

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

::: tip 노트

다른 CI를 사용하는 경우,
플러그인 위치에 대한 상대 경로를 전달할 필요가 있는 경우가 있습니다:

```shell
asdf plugin test <tool_name> <path> '<tool_command> --version'
```

:::

## API 속도 제한

`bin/list-all`이나 `bin/latest-stable`과 같이 명령어가 외부 API에 대한 접근에 의존하고 있는 경우,
자동화 테스트 중에 속도 제한이 발생할 수 있습니다.
이를 줄이기 위해, 환경 변수를 통해 인증 토큰을 제공하는 코드 경로가 있는지 확인하십시오.
예를 들어:

```shell
cmd="curl --silent"
if [ -n "$GITHUB_API_TOKEN" ]; then
 cmd="$cmd -H 'Authorization: token $GITHUB_API_TOKEN'"
fi

cmd="$cmd $releases_path"
```

### `GITHUB_API_TOKEN`

`GITHUB_API_TOKEN`를 사용할 때는,
오직 `public_repo` 액세스 권환으로 
[새로운 개인 토큰](https://github.com/settings/tokens/new)을 생성합니다.

다음으로 이 토큰을 CI pipeline 환경 변수에 추가하십시오.

::: warning 경고

절대 인증 토큰을 코드 리포지토리에 공개해서는 안됩니다.

:::

## 플러그인 Shortname 인덱스

::: tip

권장되는 플러그인 설치 방법은 URL을 바탕으로 직접 설치입니다:

```shell
# asdf plugin add <name> <git_url>
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs
```

:::

`git_url`이 지정되지 않은 경우,
asdf는 사용될 `git_url`을 정확히 결정하기 위해
[Shortname 인덱스 리포지토리](https://github.com/asdf-vm/asdf-plugins)를 사용합니다.

[Shortname 인덱스](https://github.com/asdf-vm/asdf-plugins)에
설명서에 따라 플러그인을 
해당 리포지토리에 추가할 수 있습니다.

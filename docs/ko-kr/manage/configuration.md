# 설정

`asdf`의 설정은 공유가능한 `.tool-versions` 파일들 뿐만 아니라 `.asdfrc`를 통한 특정한 사용자 맞춤화 및 환경 변수들을 모두 포함합니다.

## `.tool-versions`

한 디렉토리에 `.tool-versions` 파일이 존재하면, 해당 파일에 정의된 툴 버전들은 해당 디렉토리와 모든 하위 디렉토리에서 사용됩니다.

::: warning 노트

글로벌 기본값들은 `$HOME/.tool-versions` 파일에 설정 가능합니다

:::

`.tool-versions` 파일의 형태는 다음과 같습니다:

```
ruby 2.5.3
nodejs 10.15.0
```

다음과 같이 주석을 넣을 수 있습니다:

```
ruby 2.5.3 # This is a comment
# This is another comment
nodejs 10.15.0
```

버전들은 다음과 같은 형식일 수 있습니다:

- `10.15.0` - 실제 버전. 바이너리 다운로드를 지원하는 플러그인은 바이너리를 다운로드합니다.
- `ref:v1.0.2-a` 혹은 `ref:39cb398vb39` - 지정된 태그/커밋/브랜치 Github로부터 다운로드하고 컴파일됩니다.
- `path:~/src/elixir` - 사용하려는 툴의 맞춤 컴파일 버전을 위한 경로. 언어 개발자들 등이 사용합니다.
- `system` - 이 키워드는 asdf가 asdf에 의해 관리되지 않는 시스템 버전 툴의 버전을 사용하게합니다.

::: tip

다양한 버전들은 공백으로 구분하여 설정될 수 있습니다. 예를 들어, 파이썬 `3.7.2`를 사용하고, 파이썬 `2.7.15`로 그리고 마지막으로 `system` 파이썬으로 폴백하려면, 다음을 `.tool-versions`에 추가해주세요.

```
python 3.7.2 2.7.15 system
```

:::

`.tool-version` 파일에 정의된 모든 툴들을 설치하려면 `.tool-version` 파일이 포함된 디렉토리에서 다른 인수 없이 `asdf install`을 실행합니다.

`.tool-versions` 파일에 정의된 하나의 툴을 설치하려면 `.tool-version` 파일이 포함된 디렉토리에서 `asdf install <name>`를 실행합니다. 이 툴은 `.tool-versions` 파일에 정의된 버전으로 설치됩니다.

해당 파일은 직접 편집하거나 `asdf local` 명령어(또는 `asdf global` 명령어)를 사용하여 업데이트해 주세요.

## `.asdfrc`

`.asdfrc` 파일은 사용자의 머신별 설정을 정의합니다.

`${HOME}/.asdfrc`는 asdf가 사용하는 기본 위치입니다. 이는 [환경 변수 `ASDF_CONFIG_FILE`](#asdfconfigfile)로 설정 가능합니다.

아래 파일은 필수적인 형식과 기본값들을 보여줍니다:

```txt
legacy_version_file = no
use_release_candidates = no
always_keep_download = no
plugin_repository_last_check_duration = 60
disable_plugin_short_name_repository = no
concurrency = auto
```

### `legacy_version_file`

**지원되는** 플러그인들은 다른 버전 매니저에서 사용되는 버전 파일들을 읽을 수 있습니다, 예를 들어, 루비의 `rbenv`에서 `.ruby-version`.

| 옵션                                                    | 설명                                                                                        |
| :------------------------------------------------------ | :------------------------------------------------------------------------------------------ |
| `no` <Badge type="tip" text="기본" vertical="middle" /> | 버전을 불러오는 데는 `.tool-versions`를 사용합니다                                          |
| `yes`                                                   | 이용 가능한 레거시 버전 파일(`.ruby-version` 등)이 있는 경우 플러그인의 폴백으로 사용합니다 |

### `use_release_candidates`

`asdf update` 명령어로 asdf를 최신 유의적 버전이 아닌 최신 버전 후보판으로 업그레이드 되도록 설정합니다.

| 옵션                                                    | 설명               |
| :------------------------------------------------------ | :----------------- |
| `no` <Badge type="tip" text="기본" vertical="middle" /> | 유의적 버전 사용   |
| `yes`                                                   | 릴리스 후보판 사용 |

### `always_keep_download`

`asdf install` 명령어로 다운로드하는 소스 코드 또는 바이너리를 유지 또는 제거하도록 설정합니다

| 옵션                                                    | 설명                                          |
| :------------------------------------------------------ | :-------------------------------------------- |
| `no` <Badge type="tip" text="기본" vertical="middle" /> | 성공적인 설치 후 소스 코드 또는 바이너리 제거 |
| `yes`                                                   | 설치 후 소스 코드 또는 바이너리 유지          |

### `plugin_repository_last_check_duration`

asdf 플러그인 리포지토리 동기화 간격(분)을 설정합니다. 트리거 이벤트는 지난 동기화 시간을 확인하게 합니다. 마지막 동기화 이후 지정된 동기화 간격보다 더 많은 시간이 경과하면, 새로운 동기화가 발생합니다.

| 옵션                                                                                          | 설명                                                                |
| :-------------------------------------------------------------------------------------------- | :------------------------------------------------------------------ |
| `1`에서 `999999999` 사이의 정수 <br/> `60` <Badge type="tip" text="기본" vertical="middle" /> | 마지막 동기화 이후 지속 시간(분)이 초과된 경우 트리거 이벤트 동기화 |
| `0`                                                                                           | 각 트리거 이벤트에서 동기화                                         |
| `never`                                                                                       | 동기화 하지 않음                                                    |

동기화 이벤트는 다음 명령어들을 실행할 때 발생합니다:

- `asdf plugin add <name>`
- `asdf plugin list all`

`asdf plugin add <name> <git-url>` 플러그인 동기화를 트리거하지 않습니다.

::: warning 노트

해당 값을 `never`로 설정하는 것은 플러그인 리포지토리의 초기 동기화를 막지 않고, 해당 기능을 위해 `disable_plugin_short_name_repository`를 참조하세요.

:::

### `disable_plugin_short_name_repository`

asdf 플러그인 short-name 리포지토리의 동기화를 비활성화합니다. short-name 리포지토리가 비활성화 되어있으면 동기화 이벤트가 조기 종료됩니다.

| 옵션                                                    | 설명                                                           |
| :------------------------------------------------------ | :------------------------------------------------------------- |
| `no` <Badge type="tip" text="기본" vertical="middle" /> | 동기화 이벤트에서 asdf 플러그인 리포지토리 clone 또는 업데이트 |
| `yes`                                                   | short-name 플러그인 리포지토리 비활성화                        |

동기화 이벤트는 다음 명령어들을 실행할 때 발생합니다:

- `asdf plugin add <name>`
- `asdf plugin list all`

`asdf plugin add <name> <git-url>`는 플러그인 동기화를 트리거하지 않습니다.

::: warning 노트

플러그인 short-name repository를 비활성화해도 리포지토리가 이미 동기화된 경우 제거되지 않습니다. `rm --recursive --trash $ASDF_DATA_DIR/repository`로 플러그인 리포지토리를 제거합니다.

플러그인 short-name 리포지토리를 비활성화해도 그 리포지토리로부터 설치된 이전의 플러그인은 제거되지 않습니다. `asdf plugin remove <name>`을 사용하여 플러그인을 제거할 수 있습니다. 플러그인을 제거하면 해당 툴의 모든 설치된 버전이 제거됩니다.

:::

### `concurrency`

컴파일 중에 사용할 기본 코어 수입니다.

| 옵션   | 설명                                                                                           |
| :----- | :--------------------------------------------------------------------------------------------- |
| 정수   | 소스 코드를 컴파일할 때 사용할 코어 수                                                         |
| `auto` | `nproc`, `sysctl hw.ncpu`, `/proc/cpuinfo` 또는 `1`을 순차적으로 사용하여 코어 수를 계산합니다 |

노트: `ASDF_CONCURRENCY` 환경 변수가 존재하는 경우 우선 순위를 갖습니다.

### 플러그인 훅

다음에서 사용자 맞춤 코드를 실행이 가능합니다:

- 플러그인 설치, shim 재생성, 업데이트, 또는 제거 전 또는 후
- 플러그인 명령어 실행 전 또는 후

예를 들어 `foo`라는 플러그인이 설치되어 있고 `bar`라는 실행파일이 제공된 경우, 다음 훅들을 사용하여 사용자 맞춤 코드를 먼저 실행할 수 있습니다:

```text
pre_foo_bar = echo Executing with args: $@
```

지원되는 패턴은 다음과 같습니다:

- `pre_<plugin_name>_<command>`
- `pre_asdf_download_<plugin_name>`
- `{pre,post}_asdf_{install,reshim,uninstall}_<plugin_name>`
  - `$1`: 풀 버전
- `{pre,post}_asdf_plugin_{add,update,remove,reshim}`
  - `$1`: 플러그인 이름
- `{pre,post}_asdf_plugin_{add,update,remove}_<plugin_name>`

어떤 명령어 훅들이 어떤 명령어 이전 또는 이후에 실행되는 지에 대한 자세한 내용은 [플러그인 생성하기](../plugins/create.md)를 참조하세요.

## 환경 변수

환경 변수 설정은 시스템과 셸에 따라 다릅니다. 기본 위치는 설치 위치와 방식(Git clone, Homebrew, AUR)에 달려있습니다.

환경 변수들은 일반적으로 `asdf.sh`/`asdf.fish` 등을 source하기 전에 설정됩니다. Elvish의 경우는, 상단에서 `use asdf`로 설정합니다.

다음은 Bash 셸에서 사용법에 관한 설명입니다.

### `ASDF_CONFIG_FILE`

`.asdfrc` 설정 파일의 경로. 임의의 위치로 설정 가능합니다. 절대 경로여야 합니다.

- 미설정 시: `$HOME/.asdfrc`가 사용됩니다.
- 사용법: `export ASDF_CONFIG_FILE=/home/john_doe/.config/asdf/.asdfrc`

### `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME`

툴 이름과 버전을 저장하는 파일의 파일이름입니다. 임의의 유효한 파일 이름이면 됩니다. 일반적으로, `.tool-version` 파일들을 무시하고 싶을 때 해당 값을 설정하세요.

- 미설정 시: `.tool-versions`가 사용됩니다.
- 사용법: `export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=tool_versions`

### `ASDF_DIR`

`asdf` 코어 스크립트의 위치. 임의의 위치로 설정할 수 있습니다. 절대 경로여야 합니다.

- 미설정 시: `bin/asdf` 실행파일의 한 단계 상위 디렉토리가 사용됩니다.
- 사용법: `export ASDF_DIR=/home/john_doe/.config/asdf`

### `ASDF_DATA_DIR`

`asdf`가 플러그인, shim들, 툴 버전들을 설치하는 위치. 임의의 위치로 설정할 수 있습니다. 절대 경로여야 합니다.

- 미설정 시: `$HOME/.asdf` 존재 시 사용, 존재하지 않는 경우 `ASDF_DIR` 사용
- 사용법: `export ASDF_DATA_DIR=/home/john_doe/.asdf`

### `ASDF_CONCURRENCY`

소스 코드를 컴파일할 때 사용할 코어 수입니다. 설정하면 이 값이 asdf 설정 `concurrency` 값보다 우선 시 됩니다.

- 미설정 시: asdf 설정 `concurrency` 값이 사용됩니다.
- 사용법: `export ASDF_CONCURRENCY=32`

### `ASDF_FORCE_PREPEND`

`PATH`의 맨 앞(최우선순위) 부분에 `asdf` shim과 경로 디렉토리를 추가할 것인지 여부.

- 미설정 시: 맥 운영체제에서, `yes`가 기본값; 다른 시스템에서는 `no`가 기본값
- `yes`: `PATH`의 앞 부분에 `asdf` 디렉토리 강제 추가
- `yes` 이외의 _다른_ 문자열: `PATH`의 앞 부분에 `asdf` 디렉토리 강제로 추가하지 _않음_
- 사용법: `ASDF_FORCE_PREPEND=no . "<path-to-asdf-directory>/asdf.sh"`

## 전체 설정의 예시

다음을 이용한 간단한 asdf 설치는:

- Bash 셸
- `$HOME/.asdf` 설치 위치
- Git을 통한 설치
- 환경 변수 설정 없음
- 맞춤 `.asdfrc` 파일 없음

다음의 결과가 나오게 됩니다:

| 항목                                  | 값               | 값이 세팅되는 과정                                                                                                           |
| :------------------------------------ | :--------------- | :--------------------------------------------------------------------------------------------------------------------------- |
| config file location                  | `$HOME/.asdfrc`  | `ASDF_CONFIG_FILE`가 비었으므로, `$HOME/.asdfrc`을 사용                                                                      |
| default tool versions filename        | `.tool-versions` | `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME`가 비었으므로, `.tool-versions`을 사용                                                  |
| asdf dir                              | `$HOME/.asdf`    | `ASDF_DIR`가 비었으므로, `bin/asdf`의 한 단계 상위 디렉토리 사용                                                             |
| asdf data dir                         | `$HOME/.asdf`    | `ASDF_DATA_DIR`가 비었으므로, `$HOME/.asdf`를 `$HOME`으로 사용.                                                              |
| concurrency                           | `auto`           | `ASDF_CONCURRENCY`가 비었으므로, [기본 설정](https://github.com/asdf-vm/asdf/blob/master/defaults)의 `concurrency` 값에 의존 |
| legacy_version_file                   | `no`             | 맞춤 `.asdfrc` 없음, [기본 설정](https://github.com/asdf-vm/asdf/blob/master/defaults) 사용                                  |
| use_release_candidates                | `no`             | 맞춤 `.asdfrc` 없음, [기본 설정](https://github.com/asdf-vm/asdf/blob/master/defaults)  사용                                 |
| always_keep_download                  | `no`             | 맞춤 `.asdfrc` 없음, [기본 설정](https://github.com/asdf-vm/asdf/blob/master/defaults)  사용                                 |
| plugin_repository_last_check_duration | `60`             | 맞춤 `.asdfrc` 없음, [기본 설정](https://github.com/asdf-vm/asdf/blob/master/defaults)  사용                                 |
| disable_plugin_short_name_repository  | `no`             | 맞춤 `.asdfrc` 없음, [기본 설정](https://github.com/asdf-vm/asdf/blob/master/defaults)  사용                                 |

## 내부 설정

이 섹션은 패키지 관리자 및 통합자에게 유용한 `asdf` 내부 설정을 설명하므로 일반 사용자들은 이 섹션에 대해 걱정할 필요가 없습니다.

- `$ASDF_DIR/asdf_updates_disabled`: 이 파일이 있으면 `asdf update` 명령어를 통한 업데이트가 (내용과 무관하게) 비활성화됩니다. 이는 Pacman이나 Homebrew와 같은 패키지 매니저들이 특정 설치에 올바른 업데이트 방법이 사용되었는지 확인하는 데 사용됩니다.

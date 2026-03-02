# 버전

## 버전 설치

```shell
asdf install <name> <version>
# asdf install erlang 17.3
```

플러그인이 소스에서 다운로드 & 컴파일을 지원하는 경우, `ref:foo`를 지정할 수 있으며 여기서 `foo`는 특정 브랜치, 태그 또는 커밋입니다. 제거할 때도 동일한 이름과 참조를 사용해야 합니다.

## 최신 안정 버전 설치

```shell
asdf install <name> latest
# asdf install erlang latest
```

주어진 문자열로 시작하는 최신 안정 버전을 설치합니다.

```shell
asdf install <name> latest:<version>
# asdf install erlang latest:17
```

## 설치된 버전 목록

```shell
asdf list <name>
# asdf list erlang
```

주어진 문자열로 시작하는 버전으로 필터링합니다.

```shell
asdf list <name> <version>
# asdf list erlang 17
```

## 사용 가능한 모든 버전 목록

```shell
asdf list all <name>
# asdf list all erlang
```

주어진 문자열로 시작하는 버전으로 필터링합니다.

```shell
asdf list all <name> <version>
# asdf list all erlang 17
```

## 최신 안정 버전 보기

```shell
asdf latest <name>
# asdf latest erlang
```

주어진 문자열로 시작하는 최신 안정 버전을 보여줍니다.

```shell
asdf latest <name> <version>
# asdf latest erlang 17
```

## 현재 버전 설정 <a id='현재-버전-설정'></a>

```shell
asdf set [flags] <name> <version> [<version>...]
# asdf set elixir 1.2.4 # set in current dir
# asdf set -u elixir 1.2.4 # set in .tool-versions file in home directory
# asdf set -p elixir 1.2.4 # set in existing .tool-versions file in a parent dir

asdf set <name> latest[:<version>]
# asdf set elixir latest
```

`asdf set`은 현재 디렉터리에 `.tool-versions` 파일에 버전을 기록하며, 파일이 없으면 새로 생성합니다. 이는 순전히 편의 기능으로,
`echo "<tool> <version>" > .tool-versions` 를 실행하는 것과 같다고 생각하면 됩니다.

`-u` / `--home` 플래그를 사용하면 `asdf set`은 `$HOME` 디렉터리에 있는 `.tool-versions` 파일에 기록하며, 해당 파일이 없을 경우 새로 생성합니다.

`-p` / `--parent` 플래그를 사용하면 `asdf set`은 현재 디렉터리에서 가장 가까운 상위 디렉터리에 있는 `.tool-versions` 파일을 찾아 그 파일에 기록합니다.

### 환경 변수 사용 (Via Environment Variable)

버전을 결정할 때 `asdf`는 `ASDF_${TOOL}_VERSION` 형식의 환경 변수를 먼저 확인합니다.
버전 형식은 `.tool-versions` 파일에서 지원하는 형식과 동일합니다.

이 환경 변수가 설정되어 있으면, 어떤 `.tool-versions` 파일에 해당 도구의 버전이 설정되어 있더라도 **해당 값이 우선 적용**됩니다.

예를 들어:

```bash
export ASDF_ELIXIR_VERSION=1.18.1
```

위 설정은 현재 셸 세션에서 `asdf`가 **Elixir 1.18.1**을 사용하도록 지정합니다.

---

:::warning 대체 수단

이 설정은 **환경 변수**이기 때문에, **해당 변수가 설정된 위치(셸 세션)**에서만 적용됩니다.
이미 실행 중인 다른 셸 세션들은 `.tool-versions` 파일에 설정된 버전을 계속 사용합니다.

세부 내용은 Configuration 섹션의 `.tool-versions` [설정 섹션에 파일](/ko-kr/manage/configuration.md)을 참고하세요.
:::

---

다음 예시는 Elixir 프로젝트의 테스트를 **버전 1.4.0**으로 실행합니다:

```bash
ASDF_ELIXIR_VERSION=1.4.0 mix test
```

## 시스템 버전으로의 폴백

asdf 관리 버전이 아닌 `<name>` 도구의 시스템 버전을 사용하려면 도구의 버전을 `system`으로 설정할 수 있습니다.

위에 [현재 버전 설정](#현재-버전-설정) 섹션에 나와있는대로, `asdf set`이나 환경 변수를 사용하여 설정하세요.

```shell
asdf set <name> system
# asdf set python system
```

## 현재 버전 보기

```shell
asdf current
# asdf current
# erlang          17.3          /Users/kim/.tool-versions
# nodejs          6.11.5        /Users/kim/cool-node-project/.tool-versions

asdf current <name>
# asdf current erlang
# erlang          17.3          /Users/kim/.tool-versions
```

## 버전 제거

```shell
asdf uninstall <name> <version>
# asdf uninstall erlang 17.3
```

## Shims

asdf는 패키지를 설치할 때 해당 패키지의 모든 실행 프로그램에 대한 shim들을 `$ASDF_DATA_DIR/shims` 디렉토리 (기본값은 `~/.asdf/shims`)에 생성합니다. 이 디렉토리는 설치된 프로그램들이 이용가능하도록 `$PATH` (`asdf.sh`, `asdf.fish` 등)에 존재합니다.

Shim 자체는 플러그인 이름과 shim이 감싸고 있는 설치된 패키지의 실행파일의 경로를 넘겨주는 `asdf exec`라는 헬퍼 프로그램을 `exec`시키는 매우 단순한 wrapper입니다.

`asdf exec` 헬퍼는 사용할 패키지의 버전( `.tool-versions` 파일이나 환경 변수에 지정된 버전)을 결정하고,
패키지 설치 디렉터리 안에서 실행 파일의 최종 경로를 산출합니다
(이 경로는 플러그인의 `exec-path` 콜백을 통해 조정될 수 있습니다).

또한 실행에 사용할 환경을 결정하는데, 이 역시 플러그인이 제공하는 `exec-env` 스크립트를 통해 설정됩니다.

이 모든 과정이 끝나면, 해당 실행 파일을 실제로 실행합니다.

::: warning 노트
이 시스템은 `exec` 호출을 사용하기 때문에, 실행 대신 셸에 의해 source 되야하는 패키지의 스크립트는 shim wrapper를 통하지 않고 직접 액세스되야 합니다. 두 가지 `asdf` 명령어: `which`와 `where`는 설치된 패키지로의 경로를 반환할 수 있습니다:
:::

```shell
# returns path to main executable in current version
source $(asdf which ${PLUGIN})/../script.sh

# returns path to the package installation directory
source $(asdf where ${PLUGIN})/bin/script.sh
```

### asdf shims 우회

어떠한 이유로 asdf의 shim들을 우회하고 싶거나 프로젝트의 디렉토리로 이동했을 때 자동으로 환경 변수를 설정되게 하고 싶으시면 [asdf-direnv](https://github.com/asdf-community/asdf-direnv) 플러그인이 도움이 될 것입니다. 상세한 내용은 README를 확인해 주세요.

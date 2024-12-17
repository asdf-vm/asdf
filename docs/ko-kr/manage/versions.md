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
asdf global <name> <version> [<version>...]
asdf shell <name> <version> [<version>...]
asdf local <name> <version> [<version>...]
# asdf global elixir 1.2.4

asdf global <name> latest[:<version>]
asdf local <name> latest[:<version>]
# asdf global elixir latest
```

`global`은 해당 버전을 `$HOME/.tool-versions`에 작성합니다.

현재 셸 세션에 대해서만, `shell`은 `ASDF_${TOOL}_VERSION`이라는 이름의 환경 변수로 버전을 설정합니다.

`local`은 해당 버전을 `$PWD/.tool-versions`에 작성합니다, 존재하지 않을 시에 새로 만듦.

세부 내용은 `.tool-versions` [설정 섹션에 파일](/ko-kr/manage/configuration.md)을 참고하세요.

:::warning 대체수단
현재 셸 세션에 대해서만 버전을 설정하려는 경우
또는 특정 툴 버전 하에 단순히 한개의 명령어만 실행하기 위해, 당신은
`ASDF_${TOOL}_VERSION`과 같은 환경 변수를 설정할 수 있습니다.
:::

다음 예시에서는 버전 `1.4.0`의 Elixir 프로젝트에서 테스트를 수행합니다.
버전 형식은 `.tool-versions` 파일에서 지원되는 것과 동일하게 지원됩니다.

```shell
ASDF_ELIXIR_VERSION=1.4.0 mix test
```

## 시스템 버전으로의 폴백

asdf 관리 버전이 아닌 `<name>` 도구의 시스템 버전을 사용하려면 도구의 버전을 `system`으로 설정할 수 있습니다.

위에 [현재 버전 설정](#현재-버전-설정) 섹션에 나와있는대로, `system`을 `global`, `local` or `shell` 중에 하나로 설정하세요.

```shell
asdf local <name> system
# asdf local python system
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

`asdf exec` 헬퍼는 (`.tool-version` 파일에 지정된 대로, `asdf local...` 또는 `asdf global...`에서 선택된 대로) 사용할 패키지의 버전을 결정합니다, (플러그인의 `exec-path` 콜백에 의해 조정될 수 있음) 패키지 설치 디렉토리의 실행 파일에 대한 최종 경로 및 (플러그인에 의해 제공된 - `exec-env` 스크립트) 실행할 환경을 결정하고, 최종적으로 이를 실행합니다.

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

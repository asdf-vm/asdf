# 플러그인

플로그인들은 `asdf`가 Node.js, Ruby, Elixir 등 여러가지 툴들을 취급하는 방법입니다.

더 많은 툴들 지원을 위한 플러그인 API는 [플러그인 생성하기](/ko-kr/plugins/create.md) 참고하세요.

## 추가하기

Git URL로 플러그인 추가하기:

```shell
asdf plugin add <name> <git-url>
# asdf plugin add elm https://github.com/vic/asdf-elm
```

또는 플러그인 리포지토리에 short-name을 통해 추가하기:

```shell
asdf plugin add <name>
# asdf plugin add erlang
```

::: tip 추천

short-name 리포지토리에 독립적인 긴 `git-url` 방식이 선호됩니다.

:::

## 설치된 목록

```shell
asdf plugin list
# asdf plugin list
# java
# nodejs
```

```shell
asdf plugin list --urls
# asdf plugin list
# java            https://github.com/halcyon/asdf-java.git
# nodejs          https://github.com/asdf-vm/asdf-nodejs.git
```

## 모든 Short-name 리포지토리 목록

```shell
asdf plugin list all
```

플러그인들의 전체 short-name 목록을 [플러그인 Shortname 인덱스](https://github.com/asdf-vm/asdf-plugins)에서 확인하세요.

## 업데이트

```shell
asdf plugin update --all
```

특정 패키지를 업데이트하고 싶다면, 다음 명령어를 사용하세요.

```shell
asdf plugin update <name>
# asdf plugin update erlang
```

이 명령어는 해당 플러그인 리포지토리의 _origin_ _기본 브랜치_ 의 _가장 최근 커밋_ 을 fetch합니다. 버전화된 플러그인들과 업데이트들은 현재 개발 진행중 입니다 ([#916](https://github.com/asdf-vm/asdf/pull/916)).

## 제거

```bash
asdf plugin remove <name>
# asdf plugin remove erlang
```

플러그인 제거는 해당 툴과 관련된 모든 것을 제거합니다. 이것은 한 툴의 미사용중인 많은 버전들의 cleaning/pruning에 유용합니다.

## asdf Short-name 리포지토리 동기화

Short-name 리포지토리는 로컬 머신에 주기적으로 동기화됩니다. 동기화 방식들로 다음 방식들이 있습니다:

- 명령어들에 의한 동기화 이벤트:
  - `asdf plugin add <name>`
  - `asdf plugin list all`
- 만약 `disable_plugin_short_name_repository` 설정 옵션이 `yes`로 설정되어 있다면, 동기화는 조기 종료됩니다. [asdf 설정 문서](/ko-kr/manage/configuration.md)에서 더보기.
- 만약 동기화가 지난 `X`분 동안 진행되지 않았다면, 동기화가 진행됩니다.
  - `X`의 기본값은 `60`입니다만, `.asdfrc`의 `plugin_repository_last_check_duration` 옵션을 통해 설정될 수 있습니다. [asdf 설정 문서](/ko-kr/manage/configuration.md)에서 더보기.

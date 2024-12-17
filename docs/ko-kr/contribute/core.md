# asdf

`asdf` 코어 기여 가이드.

## 초기 설정

Github의 `asdf`를 fork하거나 clone하세요:

```shell
# clone your fork
git clone https://github.com/<GITHUB_USER>/asdf.git
# or clone asdf
git clone https://github.com/asdf-vm/asdf.git
```

코어 개발을 위한 툴들은 이 리포지토리의 `.tool-versions`에 있습니다. 만약 `asdf`가 직접 관리하기를 바라신다면, 다음 플러그인들을 설치하세요:

```shell
asdf plugin add bats https://github.com/timgluz/asdf-bats.git
asdf plugin add shellcheck https://github.com/luizm/asdf-shellcheck.git
asdf plugin add shfmt https://github.com/luizm/asdf-shfmt.git
```

`asdf`를 개발하기 위한 버전들을 설치하세요:

```shell
asdf install
```

로컬 머신에서 개발 도구를 손상시킬 수 있는 기능을 개발 중일 경우 `asdf`를 사용하지 않는 것이 _좋을 수_ 있습니다. 개발 도구들의 원본 목록입니다:

- [bats-core](https://github.com/bats-core/bats-core): Bash 또는 POSIX 준수 스크립트를 단위 테스트하기 위한 Bash 자동화 테스트 시스템.
- [shellcheck](https://github.com/koalaman/shellcheck): 셸 스크립트 정적 분석 도구.
- [shfmt](https://github.com/mvdan/sh): Bash를 지원하는 셸 parser, formatter, interpreter; shfmt 포함

## 개발

만약 설치된 `asdf`에 영향 없이 변화들을 테스트해보시고 싶으시다면, `$ASDF_DIR` 변수를 리포지토리를 clone한 경로에 지정하시고, 그 다음 임시로 `bin`와 `shims` 디렉토리들을 경로 앞에 추가하세요.

원격 리포지토리에 커밋 혹은 push하기 전에, 당신의 코드를 format, lint, 그리고 locally test하세요. 다음 스크립트/명령어들을 사용하세요:

```shell
# Lint
./scripts/lint.bash --check

# Fix & Format
./scripts/lint.bash --fix

# Test: all tests
./scripts/test.bash

# Test: for specific command
bats test/list_commands.bash
```

::: tip

**테스트 추가!** - 새로운 기능들과 버그 수정들의 리뷰 속도 향상을 위해 테스트들은 **필수적**입니다. 풀 리퀘스트 요청을 만드시기 전에 새로운 코드 경로들을 추가해주세요. [bats-core 문서](https://bats-core.readthedocs.io/en/stable/index.html) 참조

:::

### Gitignore

다음은 `asdf-vm/asdf` 리포지토리에 `.gitignore` 파일입니다. 우리는 프로젝트에 관련된 특정한 파일들을 무시합니다. 운영체제, 툴, workflows에 관련된 파일들은 글로벌 `.gitignore` 설정에서 무시되어야합니다, [더 보기](http://stratus3d.com/blog/2018/06/03/stop-excluding-editor-temp-files-in-gitignore/).

@/../.gitignore

### `.git-blame-ignore-revs`

`asdf`는 `.git-blame-ignore-revs` 사용해 blame 실행에서 잡음을 줄입니다. 더 많은 정보 [git blame 문서](https://git-scm.com/docs/git-blame).

다음과 같이 `git blame`과 `.git-blame-ignore-revs`을 사용:

```sh
git blame --ignore-revs-file .git-blame-ignore-revs ./test/install_command.bats
```

선택적으로, 수동적으로 파일을 제공하는 대신 모든 `blame`에서 해당 파일을 사용하도록 설정:

```sh
git config blame.ignoreRevsFile .git-blame-ignore-revs
```

IDE들에서 이 파일을 사용하도록 설정할 수 있습니다. 예를 들어, VSCode를 사용하실 경우 ([GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)와 함께), 다음을 `.vscode/settings.json`에 추가하세요:

```json
{
  "gitlens.advanced.blame.customArguments": [
    "--ignore-revs-file",
    ".git-blame-ignore-revs"
  ]
}
```

## Bats 테스팅

로컬 테스트 실행:

```shell
./scripts/test.bash
```

테스트 작성 전 **반드시 읽기**:

- `test/`에 존재하는 테스트들
- [bats-core 문서](https://bats-core.readthedocs.io/en/stable/index.html)
- `scripts/test.bash`에 존재하는 Bats 설정들

### Bats 팁

Bats 디버깅은 때에 따라 어려울 수 있습니다. 디버깅 단순화를 위해, `-t` flag로 TAP output을 사용하여 테스트 실행 중 결과물 출력을 위한 특별한 파일 디스크립터 `>&3`를 사용할 수 있습니다. 예시:

```shell
# test/some_tests.bats

printf "%s\n" "Will not be printed during bats test/some_tests.bats"
printf "%s\n" "Will be printed during bats -t test/some_tests.bats" >&3
```

bats-core의 더 자세한 문서 [Printing to the Terminal](https://bats-core.readthedocs.io/en/stable/writing-tests.html#printing-to-the-terminal).

## 풀 리퀘스트, 릴리스 & 관습적 커밋

`asdf`는 자동화 배포 툴 [Release Please](https://github.com/googleapis/release-please)를 사용하여 자동으로 [SemVer](https://semver.org/) 버전을 올리고 [변동사항](https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md)을 작성합니다. 이 정보들은 지난 배포들로부터 커밋 history를 읽음으로써 결정됩니다.

[유의적 커밋 메세지](https://www.conventionalcommits.org/)는 기본 브랜치의 커밋 메세지 형식이 되는 풀 리퀘스트 제목의 형식을 정의합니다. 이것은 GitHub Action에서 강제됩니다 [`amannn/action-semantic-pull-request`](https://github.com/amannn/action-semantic-pull-request).

관습적인 커밋 다음 형식을 따릅니다:

```
<type>[optional scope][optional !]: <description>

<!-- examples -->
fix: some fix
feat: a new feature
docs: some documentation update
docs(website): some change for the website
feat!: feature with breaking change
```

`<types>`의 모든 목록: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

- `!`:  주요한(breaking) 변화들을 나타냅니다
- `fix`: 새로운 SemVer `patch`을 만듭니다
- `feat`: 새로운 SemVer `minor`을 만듭니다
- `<type>!`: 새로운 SemVer `major`을 만듭니다

풀 리퀘스트 제목은 반드시 이 형식을 따라야 합니다.

::: tip

풀 리퀘스트 제목을 관습적 커밋 메세지 형식을 사용하세요.

:::

## Docker 이미지

[asdf-alpine](https://github.com/vic/asdf-alpine)와 [asdf-ubuntu](https://github.com/vic/asdf-ubuntu) 프로젝트들은 asdf 툴들의 Dockerized 이미지들을 제공하기 위해 진행되고있습니다. 개발 서버의 베이스 혹은 프로덕션 앱들을 위해 docker 이미지들을 사용할 수 있습니다.

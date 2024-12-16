# 소개

`asdf`는 툴 버전 매니저입니다. 모든 툴 버전 정의들은 당신의 팀들과 공유되는 프로젝트의 Git 리포지토리에서 확인할 수 있는 하나의 (`.tool-versions`) 파일에 있으며, 모든 사람들이 **정확히** 같은 버전의 툴들을 사용하게 합니다.

기존의 작업 방식은 여러 CLI 버전 매니저들, 각각의 고유한 API, 설정 파일들 그리고 구현이 필요했었습니다 (e.g. `$PATH` 조정, shims, 환경 변수 등...). `asdf`는 개발 워크플로우 단순화를 위해 단 하나의 인터페이스와 설정파일을 제공하고 단순한 플러그인 인터페이스를 통해 모든 툴과 런타임들 확장가능합니다.

## 작동방식

`asdf` 코어가 셸 설정과 함께 설치되면, 플러그인들이 특정 툴들을 관리하기 위해 설치됩니다. 플러그인에 의해 한가지 툴이 설치되면, [shims](<https://en.wikipedia.org/wiki/Shim_(computing)>)들을 가진 실행파일들이 각각의 툴들을 위해 생성됩니다. 실행파일들을 실행하려 할 때, `.tool-versions`에 설정된 툴의 버전을 통해 `asdf`가 어떤 버전을 실행시킬 지 결정하고 해당 shim이 대신 실행됩니다.

## 관련된 프로젝트

### nvm / n / rbenv 등

[nvm](https://github.com/nvm-sh/nvm), [n](https://github.com/tj/n) 그리고 [rbenv](https://github.com/rbenv/rbenv)과 같은 툴들은 설치된 실행파일을 위한 shim들을 만드는 셸 스크립트들로 작성되어 있습니다.

`asdf`는 매우 비슷하고 툴/런타임 버전 관리의 영역에서 경쟁하기 위해 만들어졌습니다. `asdf`의 차별화 요소는 플러그인 시스템이 툴/런타임 별 매니저의 필요성, 각기 다른 명령어들, 그리고 리포지토리에 각각 `*-version` 파일들을 제거하였다는 것입니다.

<!-- ### pyenv

TODO: someone with Python background expand on this

`asdf` has some similarities to `pyenv` but is missing some key features. The `asdf` team is looking at introducing some of these `pyenv` specific features, though no roadmap or timeline is available. -->

### direnv

> 현재 디렉토리에 따라 환경 변수들을 load와 unload 할 수 있는 새로운 기능을 기존의 셸에 추가합니다.

`asdf`는 환경 변수들을 관리하지 않습니다만, [`asdf-direnv`](https://github.com/asdf-community/asdf-direnv) 플러그인을 통해 direnv 동작를 `asdf`에 통합할 수 있습니다.

[direnv 문서](https://direnv.net/)에서 더보기.

### Homebrew

> macOS (혹은 Linux)에서의 패키지 매니저 부재

Homebrew는 패키지들과 upstream dependencies들을 관리합니다. `asdf`는 upstream dependencies들을 관리하지 않고, 패키지 매니저가 아니고, 우리가 dependency 목록들을 작게 유지하므로, 사용자가 직접 관리해야합니다.

[Homebrew 문서](https://brew.sh/)에서 더보기.

### NixOS

> Nix는 패키지 관리와 시스템 설정에 창의적으로 접근하는 툴입니다.

NixOS는, `asdf`가 제공하지 않는, 각 툴의 전체 dependency tree를 통해 패키지들의 정확한 버전들을 관리함으로써 재현가능한 환경 구축을 목표로 합니다. NixOS는 자신만의 프로그래밍 언어, 많은 CLI 툴들, 그리고 6000개가 넘는 패키지 컬렉션을 통해 해당 기능을 제공합니다.

다시 한번 말씀드리지만, `asdf`는 upstream dependencies들을 관리하지 않으며 패키지 매니저가 아닙니다.

[NixOS 문서](https://nixos.org/guides/how-nix-works.html)에서 더보기.

## 왜 asdf를 사용할까요?

`asdf`는 팀들이 플러그인 시스템을 통해 **다양한** 툴들의 지원 그리고 셸 설정에 포함시킬 하나의 **셸** 스크립트의 _단순함_ 과 _친숙성_ 을 통해 **정확히** 같은 버전의 툴들을 사용하는 것을 보장합니다.

::: tip 노트
`asdf`는 시스템 패키지 매니저가 아닙니다. 이것은 툴 버전 매니저입니다. 단지 어떠한 툴을 위한 플러그인을 생성하고 그것의 버전을 `asdf`로 관리할 수 있다고 해서, 그 특정한 툴을 버전 관리를 위한 최선의 방법을 의미하는 것은 아닙니다.
:::

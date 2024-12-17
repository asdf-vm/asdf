# 자주 묻는 질문

`asdf`에 관련된 공통된 질문들입니다.

## WSL1을 지원하나요?

WSL1 ([Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) 1)는 공식적으로 지원되지 않습니다. 어떤 부분의 `asdf`의 제대로 동작하지 않을 수 있습니다. 우리는 WSL1의 공식 지원을 추가할 계획이 없습니다.

## WSL2을 지원하나요?

WSL2 ([Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux#WSL_2) 2)는 당신이 선택한 WSL distro를 위한 설치 & dependency 설명서를 따르면 작동합니다.

중요한 것은, WSL2는 _오직_ 현재 작업 디렉토리가 Unix 드라이브 그리고 Windows 드라이브에 종속되어 있지 않을때 정상적으로 동작합니다.

우리는 호스트 runner support가 GitHub Actions에서 사용가능할 때 WSL2에서 테스트 suite를 진행할 계획입니다만, 현재는 아직 이용가능하지 않은 것 같습니다.

## 새롭게 설치된 실행파일이 동작하지 않나요?

> 방금 `npm install -g yarn`, 그러나 `yarn`을 실행시킬 수 없습니다. 어떻게 해야하나요?

`asdf`는 [shims](<https://en.wikipedia.org/wiki/Shim_(computing)>)를 사용하여 실행파일들을 관리합니다. 플러그인에 의해서 설치되는 실행파일들은 자동적으로 shim이 생성되지만, `asdf`가 관리하고 있는 툴에 의해서 실행파일이 설치 된 경우는 shim을 생성해야 한다고 하는 것을 `asdf`에 알려줄 필요가 있습니다. 이러한 경우, [Yarn](https://yarnpkg.com/)의 shim을 생성하기 위해 [`asdf reshim` 명령어 문서](/ko-kr/manage/core.md#Shim-재생성)를 참고하세요.

## 셸이 새롭게 설치된 shims들을 감지하지 못하나요?

만약 `asdf reshim`가 문제를 해결하지 못한다면, 대부분의 경우 `asdf.sh` 혹은 `asdf.fish` sourcing이 당신의 셸 설정 파일 (`.bash_profile`, `.zshrc`, `config.fish` etc) **아래쪽에** 있지 _않을_ 가능성이 높습니다. 당신의 `$PATH`가 설정 된 **후에** 그리고 사용중인 프레임워크 (oh-my-zsh etc)가 source 된 **후에** source 되어야 합니다.

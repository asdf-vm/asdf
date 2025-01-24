---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: asdf
  text: 다중 런타임 버전 매니저
  tagline: 한가지 툴로 모든 런타임 버전들을 관리하세요!
  actions:
    - theme: brand
      text: 시작하기
      link: /ko-kr/guide/getting-started
    - theme: alt
      text: asdf이란?
      link: /ko-kr/guide/introduction
    - theme: alt
      text: GitHub에서 보기
      link: https://github.com/asdf-vm/asdf

features:
  - title: "단 한가지 도구"
    details: "각 프로젝트 런타임들을 단 한가지 CLI 툴과 커맨드 인터페이스로 관리."
    icon: 🎉
  - title: "플러그인"
    details: "런타임과 툴들의 거대한 생태계. 당신이 필요한 새로운 툴들을 더해주는 간단한 API!"
    icon: 🔌
  - title: "구버전 호환"
    details: "원활한 마이그레이션을 위해 이미 존재하던 .nvmrc, .node-version, .ruby-version 등의 설정 파일들 지원!"
    icon: ⏮
  - title: "단 하나의 설정 파일"
    details: "단 하나의 공유된 .tool-versions 파일로 모든 툴, 런타임, 그리고 버전들을 관리."
    icon: 📄
  - title: "셸"
    details: "Bash, ZSH, Fish & Elvish 자동완성 기능 지원."
    icon: 🐚
  - title: "GitHub Actions"
    details: "GitHub Action 설치 제공과 .tool-versions 파일을 CI/CD 워크플로우에서 활용."
    icon: 🤖

---

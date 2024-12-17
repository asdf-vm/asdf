# 문서 & 사이트

문서 & 사이트 기여 가이드.

## 초기 세팅

Github의 `asdf` fork 그리고/혹은 기본 브랜치 Git clone:

```shell
# clone your fork
git clone https://github.com/<GITHUB_USER>/asdf.git
# or clone asdf
git clone https://github.com/asdf-vm/asdf.git
```

문서 사이트 개발을 위한 도구들은 `asdf`의 `docs/.tool-versions`에서 관리되고 있습니다. 플러그인들을 추가하기:

```shell
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs
```

툴 버전들을 설치하기:

```shell
asdf install
```

- [Node.js](https://nodejs.org): Chrome의 V8 JavaScript 엔진을 기반으로 구축된 JavaScript 런타임.

`docs/package.json`로부터 Node.js dependencies 설치하기:

```shell
npm install
```

## 개발

[VitePress (v2)](https://vitepress.dev/)는 우리가 asdf 문서 사이트를 빌드하기 위해 사용하는 정적 사이트 생성기(SSG)입니다. 이는 사용자가 JavaScript를 사용중이지 않을때도 HTML 폴백을 지원하고, [Docsify.js](https://docsify.js.org/)와 결과적으로 VuePress를 대체하기 위해 선택되었습니다. 이는 VuePress로부터 대체된 Docsify & VitePress가 아니면 불가능했을 것입니다. 이것을 제외하면, 최소한의 설정과 함께 마크다운 작성에 집중하는 feature-set은 대부분 비슷합니다.

`package.json`은 개발에 필요한 스크립트들을 포함합니다:

@[code json{3-5}](../../package.json)

로컬 개발 서버 시작하기:

```shell
npm run dev
```

커밋 전 코드 형식 맞추기:

```shell
npm run format
```

## 풀 리퀘스트, 릴리스 & 관습적 커밋

`asdf`는 PR 제목들의 관습적인 커밋들에 의존하는 자동화된 배포 pipeline을 사용하고 있습니다. 더 자세한 문서는 [코어 기여 가이드](./core.md)에서 찾을 수 있습니다.

문서 업데이트를 위한 PR을 만드실때는, PR `docs: <description>` 형식인 관습적인 커밋 타입 `docs` 제목을 만들어주세요.

## Vitepress

사이트의 설정은 설정을 대표하는 JS 오브젝트의 TypeScript 파일들로 구성되어 있습니다. 그 파일들은 다음과 같습니다:

- `docs/.vitepress/config.js`: 사이트를 위한 root 설정 파일. [VitePress 문서](https://vitepress.dev/reference/site-config) 참조.

root 설정 단순화를 위해, _navbar_ 와 _sidebar_ 를 대표하는 더 큰 JS 객체가 추출되었고 로케일로 구분되었습니다. 다음을 참조하세요: 

- `docs/.vitepress/navbars.js`
- `docs/.vitepress/sidebars.js`

[기본 테마 참고자료](https://vitepress.dev/reference/default-theme-config)에서 위 설정들의 공식 문서를 보실 수 있습니다.

## I18n

VitePress는 국제화를 공식적으로 지원합니다.
root 설정 `docs/.vitepress/config.js`는 선택 dropdown에서의 지원되는 로케일들의 URL, 제목과 navbar/sidebar의 설정 레퍼런스들을 정의합니다.

navbar/sidebar 설정들은 앞서 언급한 로케일 별로 나누어지고 내보내기된 설정파일들에 의해 결정됩니다.

각 로케일을 위한 Markdown 내용은 반드시 root 설정안에 `locales`의 키들과 같은 이름의 폴더에 위치해야합니다. 다시 말해서: 

```js
// docs/.vitepress/config.js
export default defineConfig({
  ...
  locales: {
    root: {
      label: "English",
        lang: "en-US",
        themeConfig: {
        nav: navbars.en,
          sidebar: sidebars.en,
      },
    },
    "pt-br": {
      label: "Brazilian Portuguese",
        lang: "pr-br",
        themeConfig: {
        nav: navbars.pt_br,
          sidebar: sidebars.pt_br,
      },
    },
    "zh-hans": {
      label: "简体中文",
        lang: "zh-hans",
        themeConfig: {
        nav: navbars.zh_hans,
          sidebar: sidebars.zh_hans,
      },
    },
  },
})
```

`/pt-BR/`는 `docs/pt-BR/`에 위치한 Markdown 파일들의 세트가 똑같이 필요합니다, 예를 들어:

```shell
docs
├─ README.md
├─ foo.md
├─ nested
│  └─ README.md
└─ pt-BR
   ├─ README.md
   ├─ foo.md
   └─ nested
      └─ README.md
```

더 자세한 정보는 [공식 VitePress i18n 문서](https://vitepress.dev/guide/i18n)에서 확인 가능합니다.

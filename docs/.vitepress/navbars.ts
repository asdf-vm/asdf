import path from "path";
import fs from "fs";
import process from "process";

export const getVersion = () => {
  const versionFilepath = path.join(__dirname, "../../version.txt");
  try {
    const version = fs.readFileSync(versionFilepath, "utf8").trim();
    console.log(`Found version ${version} from ${versionFilepath}`);
    return version;
  } catch (error) {
    console.error(`Failed to find version from file ${versionFilepath}`, error);
    process.exit(1);
  }
};

const en = [
  { text: "Guide", link: "/guide/getting-started" },
  {
    text: "Reference",
    link: "/manage/configuration",
  },
  {
    text: getVersion(),
    items: [
      {
        text: "Changelog",
        link: "https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md",
      },
      { text: "Contribute", link: "/contribute/core" },
    ],
  },
];

const ja_jp = [
  { text: "ガイド", link: "/ja-jp/guide/getting-started" },
  {
    text: "リファレンス",
    link: "/ja-jp/manage/configuration",
  },
  {
    text: getVersion(),
    items: [
      {
        text: "変更履歴",
        link: "https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md",
      },
      { text: "コントリビューション", link: "/ja-jp/contribute/core" },
    ],
  },
];

const ko_kr = [
  { text: "가이드", link: "/ko-kr/guide/getting-started" },
  {
    text: "참고자료",
    link: "/ko-kr/manage/configuration",
  },
  {
    text: getVersion(),
    items: [
      {
        text: "변동사항",
        link: "https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md",
      },
      { text: "기여하기", link: "/ko-kr/contribute/core" },
    ],
  },
];

const pt_br = [
  { text: "Guia", link: "/pt-br/guide/getting-started" },
  {
    text: "Referência",
    link: "/pt-br/manage/configuration",
  },
  {
    text: getVersion(),
    items: [
      {
        text: "Changelog",
        link: "https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md",
      },
      { text: "Contribute", link: "/pt-br/contribute/core" },
    ],
  },
];

const zh_hans = [
  { text: "指导", link: "/zh-hans/guide/getting-started" },
  {
    text: "参考",
    link: "/zh-hans/manage/configuration",
  },
  {
    text: getVersion(),
    items: [
      {
        text: "Changelog",
        link: "https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md",
      },
      { text: "如何贡献", link: "/zh-hans/contribute/core" },
    ],
  },
];

export { en, ko_kr, ja_jp, pt_br, zh_hans };

import { defineConfig } from "vitepress";
import { generateSidebar } from "vitepress-sidebar";

export default defineConfig({
  title: "Apiwork",
  description: "The modern API layer for Rails",
  markdown: {
    lineNumbers: false,
    headers: {
      level: [2, 3],
    },
  },
  themeConfig: {
    outline: [2, 3],
    nav: [
      { text: "Guide", link: "/guide/" },
      { text: "Examples", link: "/examples/" },
      { text: "Reference", link: "/reference/" },
    ],
    search: {
      provider: "local",
    },
    socialLinks: [
      { icon: "github", link: "https://github.com/apiwork/apiwork" },
    ],
    editLink: {
      pattern: "https://github.com/apiwork/apiwork/edit/main/docs/:path",
    },
    sidebar: generateSidebar([
      {
        documentRootPath: ".",
        scanStartPath: "guide",
        resolvePath: "/guide/",
        useTitleFromFileHeading: true,
        useFolderTitleFromIndexFile: true,
        sortMenusByFrontmatterOrder: true,
        frontmatterOrderDefaultValue: 999,
        excludeByGlobPattern: ["index.md"],
        collapseDepth: 2,
      },
      {
        documentRootPath: ".",
        scanStartPath: "examples",
        resolvePath: "/examples/",
        useTitleFromFileHeading: true,
        useFolderTitleFromIndexFile: true,
        sortMenusByFrontmatterOrder: true,
        frontmatterOrderDefaultValue: 999,
        collapsed: true,
      },
      {
        documentRootPath: ".",
        scanStartPath: "reference",
        resolvePath: "/reference/",
        useTitleFromFileHeading: true,
        useFolderTitleFromIndexFile: true,
        useFolderLinkFromIndexFile: true,
        sortMenusByFrontmatterOrder: true,
        frontmatterOrderDefaultValue: 999,
        sortFolderTo: "top",
        collapsed: true,
      },
    ]),
  },
});

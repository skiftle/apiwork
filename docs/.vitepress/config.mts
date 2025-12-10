import { defineConfig } from "vitepress";
import { generateSidebar } from "vitepress-sidebar";

export default defineConfig({
  title: "Apiwork",
  description: "The modern API layer for Rails",
  themeConfig: {
    outline: [2, 3],
    nav: [
      { text: "Home", link: "/" },
      {
        text: "Guide",
        link: "/guide/getting-started/introduction",
        activeMatch: "/guide/",
      },
      { text: "Reference", link: "/reference/", activeMatch: "/reference/" },
    ],
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
    socialLinks: [
      { icon: "github", link: "https://github.com/skiftle/apiwork" },
    ],
    footer: {
      message: "Released under the MIT License.",
      copyright: "Copyright © 2025 Skiftle",
    },
  },
});

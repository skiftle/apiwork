import { defineConfig } from "vitepress";
import { generateSidebar } from "vitepress-sidebar";

export default defineConfig({
  title: "Apiwork",
  description: "Ruby API Framework",
  themeConfig: {
    nav: [
      { text: "Home", link: "/" },
      { text: "Guide", link: "/guide/" },
      { text: "Reference", link: "/reference/" },
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
        sortMenusByFrontmatterOrder: true,
        frontmatterOrderDefaultValue: 999,
        excludeByGlobPattern: ["index.md"],
        collapsed: true,
      },
    ]),
    socialLinks: [
      { icon: "github", link: "https://github.com/skiftle/apiwork" },
    ],
  },
});

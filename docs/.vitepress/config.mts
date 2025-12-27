import { defineConfig } from "vitepress";
import { generateSidebar } from "vitepress-sidebar";
import { createCssVariablesTheme } from "shiki";

const cssVariablesTheme = createCssVariablesTheme({
  name: "css-variables",
  variablePrefix: "--shiki-",
  variableDefaults: {},
  fontStyle: true,
});

export default defineConfig({
  title: "Apiwork",
  description: "The modern API layer for Rails",
  markdown: {
    theme: cssVariablesTheme,
    lineNumbers: false,
    headers: {
      level: [2, 3],
    },
  },
  themeConfig: {
    outline: [2, 3],
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
        collapsed: false,
      },
    ]),
  },
});

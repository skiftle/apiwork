import { defineConfig } from "vitepress";
import { generateSidebar } from "vitepress-sidebar";

export default defineConfig({
  title: "Apiwork",
  description: "The modern API layer for Rails",
  cleanUrls: true,
  lastUpdated: true,
  sitemap: {
    hostname: "https://apiwork.dev",
  },
  head: [
    ["link", { rel: "icon", href: "/favicon.ico" }],
    ["meta", { property: "og:type", content: "website" }],
    ["meta", { property: "og:title", content: "Apiwork" }],
    [
      "meta",
      {
        property: "og:description",
        content: "The modern API layer for Rails",
      },
    ],
  ],
  markdown: {
    lineNumbers: false,
    headers: {
      level: [2, 3],
    },
  },
  themeConfig: {
    outline: [2, 3],
    externalLinkIcon: true,
    nav: [
      { text: "Guide", link: "/guide/", activeMatch: "/guide/" },
      { text: "Examples", link: "/examples/", activeMatch: "/examples/" },
      { text: "Reference", link: "/reference/", activeMatch: "/reference/" },
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
    footer: {
      message: "Released under the MIT License.",
      copyright: "Copyright 2024-present Apiwork contributors",
    },
    lastUpdated: {
      text: "Last updated",
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

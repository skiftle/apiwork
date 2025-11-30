import { defineConfig } from 'vitepress'
import { generateSidebar } from 'vitepress-sidebar'

export default defineConfig({
  title: "Apiwork",
  description: "Ruby API Framework",
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Docs', link: '/getting-started/introduction' }
    ],
    sidebar: generateSidebar({
      documentRootPath: '.',
      useTitleFromFileHeading: true,
      useFolderTitleFromIndexFile: true,
      sortMenusByFrontmatterOrder: true,
      frontmatterOrderDefaultValue: 999,
      excludeByGlobPattern: ['index.md', 'node_modules/**', '.vitepress/**', 'examples/**', 'app/**', 'api-examples.md', 'markdown-examples.md'],
      collapsed: false
    }),
    socialLinks: [
      { icon: 'github', link: 'https://github.com/skiftle/apiwork' }
    ]
  }
})

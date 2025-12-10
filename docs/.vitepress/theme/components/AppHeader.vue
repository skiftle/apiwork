<script setup lang="ts">
import { useData } from 'vitepress'

const { site, theme } = useData()

// TODO: Get nav from themeConfig or define here
const navItems = [
  { text: 'Home', link: '/' },
  { text: 'Guide', link: '/guide/getting-started/introduction' },
  { text: 'Reference', link: '/reference/' },
  { text: 'Blog', link: '/blog/' },
]
</script>

<template>
  <header class="app-header">
    <div class="header-container">
      <a href="/" class="logo">
        <span class="logo-text">{{ site.title }}</span>
      </a>

      <nav class="nav">
        <a
          v-for="item in navItems"
          :key="item.link"
          :href="item.link"
          class="nav-link"
        >
          {{ item.text }}
        </a>
      </nav>

      <div class="header-actions">
        <!-- TODO: Add GitHub link, search, theme toggle -->
        <a
          href="https://github.com/skiftle/apiwork"
          class="github-link"
          target="_blank"
          rel="noopener"
        >
          GitHub
        </a>
      </div>
    </div>
  </header>
</template>

<style scoped>
.app-header {
  position: sticky;
  top: 0;
  z-index: 100;
  height: var(--header-height);
  background: var(--color-bg);
  border-bottom: 1px solid var(--color-border);
}

.header-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1400px;
  height: 100%;
  margin: 0 auto;
  padding: 0 var(--space-6);
}

.logo {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-weight: 600;
  font-size: var(--font-size-lg);
  color: var(--color-text);
  text-decoration: none;
}

.logo:hover {
  color: var(--color-brand);
  text-decoration: none;
}

.nav {
  display: flex;
  gap: var(--space-6);
}

.nav-link {
  font-size: var(--font-size-sm);
  font-weight: 500;
  color: var(--color-text-muted);
  text-decoration: none;
  transition: color var(--transition-fast);
}

.nav-link:hover {
  color: var(--color-text);
  text-decoration: none;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}

.github-link {
  font-size: var(--font-size-sm);
  font-weight: 500;
  color: var(--color-text-muted);
  text-decoration: none;
}

.github-link:hover {
  color: var(--color-text);
  text-decoration: none;
}

/* TODO: Add responsive styles */
</style>

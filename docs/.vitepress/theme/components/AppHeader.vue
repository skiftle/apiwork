<script setup lang="ts">
import { useData, useRoute } from 'vitepress'
import ThemeSwitch from './ThemeSwitch.vue'

const { site } = useData()
const route = useRoute()

const navItems = [
  { text: 'Home', link: '/', match: /^\/$/ },
  { text: 'Guide', link: '/guide/getting-started/introduction', match: /^\/guide\// },
  { text: 'Reference', link: '/reference/', match: /^\/reference\// },
  { text: 'Blog', link: '/blog/', match: /^\/blog\// },
]

function isActive(item: typeof navItems[0]) {
  return item.match.test(route.path)
}
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
          class="nav-pill"
          :class="{ active: isActive(item) }"
        >
          {{ item.text }}
        </a>
      </nav>

      <div class="header-actions">
        <ThemeSwitch />
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
  gap: var(--space-2);
}

.nav-pill {
  font-size: var(--font-size-sm);
  font-weight: 500;
  color: var(--color-text-muted);
  text-decoration: none;
  padding: var(--space-2) var(--space-4);
  border-radius: 9999px;
  transition: all var(--transition-fast);
}

.nav-pill:hover {
  color: var(--color-text);
  background: var(--color-bg-soft);
  text-decoration: none;
}

.nav-pill.active {
  color: var(--color-brand);
  background: var(--color-bg-muted);
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

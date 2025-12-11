<script setup lang="ts">
import { useData, useRoute } from "vitepress";
import ThemeSwitch from "./ThemeSwitch.vue";

const { site } = useData();
const route = useRoute();

const navItems = [
  { text: "Home", link: "/", match: /^\/$/, badge: null },
  {
    text: "Guide",
    link: "/guide/getting-started/introduction",
    match: /^\/guide\//,
    badge: null,
  },
  {
    text: "Reference",
    link: "/reference/",
    match: /^\/reference\//,
    badge: null,
  },
  { text: "Blog", link: "/blog/", match: /^\/blog\//, badge: "NEW" },
];

function isActive(item: (typeof navItems)[0]) {
  return item.match.test(route.path);
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
          <span v-if="item.badge" class="nav-badge">{{ item.badge }}</span>
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
  background: transparent;
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
  position: relative;
  font-size: var(--font-size-md);
  font-weight: 500;
  color: #353535;
  text-decoration: none;
  padding: var(--space-1) var(--space-6);
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
  background: var(--color-bg-soft);
}

.nav-badge {
  position: absolute;
  top: -6px;
  right: -8px;
  font-size: 9px;
  font-weight: 600;
  padding: 2px 5px;
  background: #f97316;
  color: white;
  border-radius: 4px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
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

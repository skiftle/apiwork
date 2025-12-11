<script setup lang="ts">
import { useData, useRoute } from "vitepress";
import ThemeSwitch from "./ThemeSwitch.vue";

const { site } = useData();
const route = useRoute();

</script>

<template>
  <header class="app-header">
    <div class="header-container">
      <a href="/" class="logo">
        <span class="logo-text">{{ site.title }}</span>
      </a>

      <nav class="nav">
        <a href="/" class="nav-pill" :class="{ active: route.path === '/' }">Home</a>
        <a href="/guide/getting-started/introduction" class="nav-pill" :class="{ active: /^\/guide\//.test(route.path) }">Guide</a>
        <a href="/reference/" class="nav-pill" :class="{ active: /^\/reference\//.test(route.path) }">Reference</a>
        <a href="/blog/" class="nav-pill" :class="{ active: /^\/blog\//.test(route.path) }">Blog</a>
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
  font-size: var(--font-size-md);
  font-weight: 500;
  color: #353535;
  text-decoration: none;
  padding: var(--space-1) var(--space-6);
  border-radius: 9999px;
  transition: background-color 300ms, color 300ms;
}

.nav-pill:hover {
  color: var(--color-text);
  background-color: rgba(0, 0, 0, 0.07);
  text-decoration: none;
}

.nav-pill.active {
  color: var(--color-brand);
  background-color: rgba(104, 98, 98, 0.062);
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

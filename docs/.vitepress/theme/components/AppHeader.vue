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
        <svg class="logo-icon" viewBox="0 0 24 24" fill="none">
          <defs>
            <linearGradient id="grad-top" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="var(--color-brand-light)" />
              <stop offset="100%" stop-color="var(--color-brand-dark)" />
            </linearGradient>
            <linearGradient id="grad-mid" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="#9ca3af" />
              <stop offset="100%" stop-color="#6b7280" />
            </linearGradient>
            <linearGradient id="grad-bottom" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="#d1d5db" />
              <stop offset="100%" stop-color="#9ca3af" />
            </linearGradient>
          </defs>
          <path class="layer-bottom" d="M12 22 Q8.5 18.5 5 15 Q8.5 11.5 12 8 Q15.5 11.5 19 15 Q15.5 18.5 12 22 Z" />
          <path class="layer-mid" d="M12 16 Q8.5 12.5 5 9 Q8.5 5.5 12 2 Q15.5 5.5 19 9 Q15.5 12.5 12 16 Z" />
          <path class="layer-top" d="M12 10 Q9.5 7.5 7 5 Q9.5 2.5 12 0 Q14.5 2.5 17 5 Q14.5 7.5 12 10 Z" transform="translate(0, 2)" />
        </svg>
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

.logo-icon {
  width: 22px;
  height: 22px;
  flex-shrink: 0;
}

.layer-top {
  fill: url(#grad-top);
}

.layer-mid {
  fill: url(#grad-mid);
}

.layer-bottom {
  fill: url(#grad-bottom);
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

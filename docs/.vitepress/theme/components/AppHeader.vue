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
            <linearGradient
              id="grad-bottom"
              x1="0%"
              y1="0%"
              x2="100%"
              y2="100%"
            >
              <stop offset="0%" stop-color="#d1d5db" />
              <stop offset="100%" stop-color="#9ca3af" />
            </linearGradient>
          </defs>
          <path
            class="layer-bottom"
            d="M12 22 Q8.5 18.5 5 15 Q8.5 11.5 12 8 Q15.5 11.5 19 15 Q15.5 18.5 12 22 Z"
          />
          <path
            class="layer-mid"
            d="M12 16 Q8.5 12.5 5 9 Q8.5 5.5 12 2 Q15.5 5.5 19 9 Q15.5 12.5 12 16 Z"
          />
          <path
            class="layer-top"
            d="M12 10 Q9.5 7.5 7 5 Q9.5 2.5 12 0 Q14.5 2.5 17 5 Q14.5 7.5 12 10 Z"
            transform="translate(0, 2)"
          />
        </svg>
        <span class="logo-text">{{ site.title }}</span>
      </a>

      <nav class="nav">
        <a href="/" class="nav-pill" :class="{ active: route.path === '/' }"
          >Home</a
        >
        <a
          href="/guide/getting-started/introduction"
          class="nav-pill"
          :class="{ active: /^\/guide\//.test(route.path) }"
          >Guide</a
        >
        <a
          href="/reference/"
          class="nav-pill"
          :class="{ active: /^\/reference\//.test(route.path) }"
          >Reference</a
        >
        <a
          href="/blog/"
          class="nav-pill"
          :class="{ active: /^\/blog\//.test(route.path) }"
          >Blog</a
        >
      </nav>

      <div class="header-actions">
        <ThemeSwitch />
        <a
          href="https://github.com/skiftle/apiwork"
          class="github-link"
          target="_blank"
          rel="noopener"
          aria-label="GitHub"
        >
          <svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor">
            <path
              d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"
            />
          </svg>
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
  gap: var(--space-1);
}

.nav-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;

  min-width: 100px;
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
  background-color: rgba(0, 0, 0, 0.07);
}

.header-actions {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}

.github-link {
  display: flex;
  align-items: center;
  color: var(--color-text-muted);
  transition: color 200ms;
}

.github-link:hover {
  color: var(--color-text);
}

/* TODO: Add responsive styles */
</style>

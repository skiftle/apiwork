<script setup lang="ts">
import { useData, useRoute } from "vitepress";
import ThemeSwitch from "./ThemeSwitch.vue";

const { site } = useData();
const route = useRoute();
</script>

<template>
  <header class="app-header">
    <div class="container">
      <a href="/" class="logo">
        <svg
          width="46px"
          height="32px"
          viewBox="0 0 46 32"
          version="1.1"
          xmlns="http://www.w3.org/2000/svg"
          xmlns:xlink="http://www.w3.org/1999/xlink"
        >
          <g
            id="Page-1"
            stroke="none"
            stroke-width="1"
            fill="none"
            fill-rule="evenodd"
          >
            <g id="Desktop-HD" transform="translate(-21.000000, -21.000000)">
              <path
                class="logo-shadow"
                d="M36.4142136,35.5857864 L49.5857864,22.4142136 C50.366835,21.633165 51.633165,21.633165 52.4142136,22.4142136 L65.5857864,35.5857864 C66.366835,36.366835 66.366835,37.633165 65.5857864,38.4142136 L52.4142136,51.5857864 C51.633165,52.366835 50.366835,52.366835 49.5857864,51.5857864 L36.4142136,38.4142136 C35.633165,37.633165 35.633165,36.366835 36.4142136,35.5857864 Z"
              ></path>
              <path
                class="logo-primary"
                d="M22.4142136,35.5857864 L35.5857864,22.4142136 C36.366835,21.633165 37.633165,21.633165 38.4142136,22.4142136 L51.5857864,35.5857864 C52.366835,36.366835 52.366835,37.633165 51.5857864,38.4142136 L38.4142136,51.5857864 C37.633165,52.366835 36.366835,52.366835 35.5857864,51.5857864 L22.4142136,38.4142136 C21.633165,37.633165 21.633165,36.366835 22.4142136,35.5857864 Z"
              ></path>
            </g>
          </g>
        </svg>
        <span class="text">{{ site.title }}</span>
      </a>

      <nav class="nav">
        <a href="/" class="link" :class="{ active: route.path === '/' }">
          Home
          <span class="indicator"></span>
        </a>
        <a
          href="/guide/getting-started/introduction"
          class="link"
          :class="{ active: /^\/guide\//.test(route.path) }"
        >
          Guide
          <span class="indicator"></span>
        </a>
        <a
          href="/reference/"
          class="link"
          :class="{ active: /^\/reference\//.test(route.path) }"
        >
          Reference
          <span class="indicator"></span>
        </a>
        <a
          href="/blog/"
          class="link"
          :class="{ active: /^\/blog\//.test(route.path) }"
        >
          Blog
          <span class="indicator"></span>
        </a>
      </nav>

      <div class="actions">
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
  background: color-mix(in srgb, var(--color-bg) 85%, transparent);
  backdrop-filter: blur(18px) saturate(180%);
  -webkit-backdrop-filter: blur(18px) saturate(180%);
  .container {
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

    &:hover {
      color: var(--color-brand-70);
      text-decoration: none;
    }

    .logo-shadow {
      fill: var(--color-logo-shadow);
    }

    .logo-primary {
      fill: var(--color-brand-70);
    }
  }

  .nav {
    display: flex;
    gap: var(--space-8);

    .link {
      font-size: var(--font-size-base);
      font-weight: 600;
      color: var(--color-text);
      text-decoration: none;

      &:hover {
        text-decoration: none;
      }

      &.active {
        color: var(--color-brand-70);
      }
    }
  }

  .actions {
    display: flex;
    align-items: center;
    gap: var(--space-4);
  }

  .github-link {
    display: flex;
    align-items: center;
    color: var(--color-text-muted);
    transition: color 200ms;

    &:hover {
      color: var(--color-text);
    }
  }
}
</style>

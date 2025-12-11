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
        <svg
          width="140px"
          height="32px"
          viewBox="0 0 140 32"
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
            <g id="Desktop-HD" transform="translate(-21.000000, -35.000000)">
              <text
                id="Apiwork"
                font-family="SFUIDisplay-Medium, SF UI Display"
                font-size="26"
                font-weight="400"
                letter-spacing="-0.288888889"
              >
                <tspan x="70.3319119" y="60" fill="#353535">Api</tspan>
                <tspan
                  x="106.751378"
                  y="60"
                  fill="#E30F0F"
                  fill-opacity="0.803378018"
                >
                  work
                </tspan>
              </text>
              <path
                d="M36.4142136,49.5857864 L49.5857864,36.4142136 C50.366835,35.633165 51.633165,35.633165 52.4142136,36.4142136 L65.5857864,49.5857864 C66.366835,50.366835 66.366835,51.633165 65.5857864,52.4142136 L52.4142136,65.5857864 C51.633165,66.366835 50.366835,66.366835 49.5857864,65.5857864 L36.4142136,52.4142136 C35.633165,51.633165 35.633165,50.366835 36.4142136,49.5857864 Z"
                id="Path-3"
                fill-opacity="0.501927516"
                fill="#000000"
                opacity="0.386736189"
              ></path>
              <path
                d="M22.4142136,49.5857864 L35.5857864,36.4142136 C36.366835,35.633165 37.633165,35.633165 38.4142136,36.4142136 L51.5857864,49.5857864 C52.366835,50.366835 52.366835,51.633165 51.5857864,52.4142136 L38.4142136,65.5857864 C37.633165,66.366835 36.366835,66.366835 35.5857864,65.5857864 L22.4142136,52.4142136 C21.633165,51.633165 21.633165,50.366835 22.4142136,49.5857864 Z"
                id="Path-3"
                fill="#E30F0F"
                opacity="0.795767648"
              ></path>
            </g>
          </g>
        </svg>
      </a>

      <nav class="nav">
        <a href="/" class="nav-link" :class="{ active: route.path === '/' }">
          Home
          <span class="indicator"></span>
        </a>
        <a
          href="/guide/getting-started/introduction"
          class="nav-link"
          :class="{ active: /^\/guide\//.test(route.path) }"
        >
          Guide
          <span class="indicator"></span>
        </a>
        <a
          href="/reference/"
          class="nav-link"
          :class="{ active: /^\/reference\//.test(route.path) }"
        >
          Reference
          <span class="indicator"></span>
        </a>
        <a
          href="/blog/"
          class="nav-link"
          :class="{ active: /^\/blog\//.test(route.path) }"
        >
          Blog
          <span class="indicator"></span>
        </a>
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
  border-bottom: solid 1px rgba(0, 0, 0, 0.04);
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
  gap: var(--space-8);
}

.nav-link {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-size: var(--font-size-base);
  font-weight: 500;
  color: var(--color-text);
  text-decoration: none;
  transition: color 200ms;
}

.nav-link:hover {
  color: color-mix(in srgb, var(--color-brand) 80%, transparent);
  text-decoration: none;
}

.nav-link.active {
  color: color-mix(in srgb, var(--color-brand) 80%, transparent);
}

.indicator {
  display: block;
  width: 100%;
  height: 2px;
  margin-top: 4px;
  background: transparent;
  border-radius: 2px;
  transition: background 200ms;
}

.nav-link.active .indicator {
  background: color-mix(in srgb, var(--color-brand) 80%, transparent);
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

<script setup lang="ts">
import { computed } from 'vue'
import { useData, useRoute } from 'vitepress'
import AppHeader from './components/AppHeader.vue'
import AppFooter from './components/AppFooter.vue'
import HomeLayout from './components/HomeLayout.vue'
import GuideLayout from './components/GuideLayout.vue'
import ReferenceLayout from './components/ReferenceLayout.vue'
import BlogLayout from './components/BlogLayout.vue'
import NotFound from './components/NotFound.vue'

const { page, frontmatter } = useData()
const route = useRoute()

const layoutType = computed(() => {
  if (page.value.isNotFound) return 'not-found'
  if (frontmatter.value.layout === 'home') return 'home'
  if (route.path.startsWith('/guide/')) return 'guide'
  if (route.path.startsWith('/reference/')) return 'reference'
  if (route.path.startsWith('/blog/')) return 'blog'
  return 'guide'
})
</script>

<template>
  <div class="app" :class="{ 'app--home': layoutType === 'home' }">
    <div v-if="layoutType === 'home'" class="home-bg-wrapper">
      <svg class="home-bg" viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true">
        <defs>
          <!-- Bakgrunds-gradient: mjuk rose toning -->
          <radialGradient id="bg-gradient" cx="20%" cy="80%" r="80%">
            <stop offset="0%" class="stop-rose" stop-opacity="0.18" />
            <stop offset="40%" class="stop-rose" stop-opacity="0.08" />
            <stop offset="100%" class="stop-rose" stop-opacity="0" />
          </radialGradient>
        </defs>
        <!-- Bakgrund: mjuk gradient -->
        <rect x="0" y="0" width="100" height="100" fill="url(#bg-gradient)" />
        <!-- Mjukare cirklar ovanpå -->
        <!-- Rose: vänster-nedre -->
        <g transform="rotate(-8, 15, 120)" class="solid-rose">
          <ellipse cx="15" cy="120" rx="130" ry="80" fill-opacity="0.02" />
          <ellipse cx="15" cy="120" rx="105" ry="65" fill-opacity="0.03" />
          <ellipse cx="15" cy="120" rx="82" ry="51" fill-opacity="0.04" />
          <ellipse cx="15" cy="120" rx="60" ry="38" fill-opacity="0.05" />
          <ellipse cx="15" cy="120" rx="40" ry="25" fill-opacity="0.07" />
          <ellipse cx="15" cy="120" rx="22" ry="14" fill-opacity="0.09" />
        </g>
        <!-- Coral: höger-övre -->
        <g transform="rotate(12, 100, -15)" class="solid-coral">
          <ellipse cx="100" cy="-15" rx="95" ry="60" fill-opacity="0.02" />
          <ellipse cx="100" cy="-15" rx="72" ry="45" fill-opacity="0.04" />
          <ellipse cx="100" cy="-15" rx="50" ry="32" fill-opacity="0.06" />
          <ellipse cx="100" cy="-15" rx="30" ry="19" fill-opacity="0.08" />
        </g>
        <!-- Magenta: mitten-höger -->
        <g transform="rotate(-6, 115, 55)" class="solid-magenta">
          <ellipse cx="115" cy="55" rx="75" ry="48" fill-opacity="0.015" />
          <ellipse cx="115" cy="55" rx="52" ry="33" fill-opacity="0.03" />
          <ellipse cx="115" cy="55" rx="32" ry="20" fill-opacity="0.05" />
        </g>
        <!-- Pink: topp-vänster -->
        <g transform="rotate(8, 0, 5)" class="solid-pink">
          <ellipse cx="0" cy="5" rx="50" ry="38" fill-opacity="0.02" />
          <ellipse cx="0" cy="5" rx="30" ry="23" fill-opacity="0.04" />
        </g>
      </svg>
    </div>
    <AppHeader />
    <main>
      <NotFound v-if="layoutType === 'not-found'" />
      <HomeLayout v-else-if="layoutType === 'home'" />
      <GuideLayout v-else-if="layoutType === 'guide'" />
      <ReferenceLayout v-else-if="layoutType === 'reference'" />
      <BlogLayout v-else-if="layoutType === 'blog'" />
    </main>
    <AppFooter />
  </div>
</template>

<style>
.app--home {
  position: relative;
  background: var(--color-bg);
}

.home-bg-wrapper {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 650px;
  overflow: hidden;
  z-index: 0;
  pointer-events: none;
}

.home-bg {
  width: 100%;
  height: 100%;
}

.app--home > :not(.home-bg-wrapper) {
  position: relative;
  z-index: 1;
}

/* P3 wide-gamut colors */
/* Gradient stop (bakgrund) */
.stop-rose { stop-color: #e11d48; }

/* Solida fills (skarpa cirklar) */
.solid-rose { fill: #e11d48; }
.solid-coral { fill: #ff6b4a; }
.solid-magenta { fill: #c026d3; }
.solid-pink { fill: #ec4899; }

@supports (color: color(display-p3 1 0 0)) {
  .stop-rose { stop-color: color(display-p3 0.92 0.12 0.32); }
  .solid-rose { fill: color(display-p3 0.92 0.12 0.32); }
  .solid-coral { fill: color(display-p3 1 0.45 0.30); }
  .solid-magenta { fill: color(display-p3 0.80 0.15 0.85); }
  .solid-pink { fill: color(display-p3 0.95 0.30 0.62); }
}
</style>

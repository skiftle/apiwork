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
        <!-- Primary: Vivid rose från vänster-nedre -->
        <g transform="rotate(-8, 15, 120)" class="gradient-rose">
          <ellipse cx="15" cy="120" rx="130" ry="80" fill-opacity="0.02" />
          <ellipse cx="15" cy="120" rx="105" ry="65" fill-opacity="0.03" />
          <ellipse cx="15" cy="120" rx="82" ry="51" fill-opacity="0.04" />
          <ellipse cx="15" cy="120" rx="60" ry="38" fill-opacity="0.05" />
          <ellipse cx="15" cy="120" rx="40" ry="25" fill-opacity="0.06" />
          <ellipse cx="15" cy="120" rx="22" ry="14" fill-opacity="0.075" />
        </g>
        <!-- Secondary: Electric coral från höger-övre -->
        <g transform="rotate(12, 100, -15)" class="gradient-coral">
          <ellipse cx="100" cy="-15" rx="95" ry="60" fill-opacity="0.018" />
          <ellipse cx="100" cy="-15" rx="72" ry="45" fill-opacity="0.028" />
          <ellipse cx="100" cy="-15" rx="50" ry="32" fill-opacity="0.038" />
          <ellipse cx="100" cy="-15" rx="30" ry="19" fill-opacity="0.05" />
        </g>
        <!-- Tertiary: Ultra violet från mitten-höger -->
        <g transform="rotate(-6, 115, 55)" class="gradient-violet">
          <ellipse cx="115" cy="55" rx="75" ry="48" fill-opacity="0.015" />
          <ellipse cx="115" cy="55" rx="52" ry="33" fill-opacity="0.025" />
          <ellipse cx="115" cy="55" rx="32" ry="20" fill-opacity="0.035" />
        </g>
        <!-- Accent: Cyan glow top-left -->
        <g transform="rotate(8, 0, 5)" class="gradient-cyan">
          <ellipse cx="0" cy="5" rx="50" ry="38" fill-opacity="0.015" />
          <ellipse cx="0" cy="5" rx="30" ry="23" fill-opacity="0.025" />
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

/* P3 wide-gamut gradient colors - Rails Ruby palette */
.gradient-rose { fill: #cc0f35; }
.gradient-coral { fill: #ea580c; }
.gradient-violet { fill: #9f1239; }
.gradient-cyan { fill: #ca8a04; }

@supports (color: color(display-p3 1 0 0)) {
  .gradient-rose { fill: color(display-p3 0.85 0.05 0.25); }
  .gradient-coral { fill: color(display-p3 0.95 0.35 0.08); }
  .gradient-violet { fill: color(display-p3 0.7 0.08 0.28); }
  .gradient-cyan { fill: color(display-p3 0.85 0.58 0.05); }
}
</style>

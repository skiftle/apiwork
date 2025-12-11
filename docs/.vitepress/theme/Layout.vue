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
        <!-- Primary: Rosa/röd från vänster-nedre -->
        <g transform="rotate(-8, 15, 120)">
          <ellipse cx="15" cy="120" rx="120" ry="75" fill="#e11d48" fill-opacity="0.025" />
          <ellipse cx="15" cy="120" rx="100" ry="62" fill="#e11d48" fill-opacity="0.035" />
          <ellipse cx="15" cy="120" rx="80" ry="50" fill="#e11d48" fill-opacity="0.045" />
          <ellipse cx="15" cy="120" rx="60" ry="38" fill="#e11d48" fill-opacity="0.055" />
          <ellipse cx="15" cy="120" rx="40" ry="25" fill="#e11d48" fill-opacity="0.065" />
          <ellipse cx="15" cy="120" rx="22" ry="14" fill="#e11d48" fill-opacity="0.08" />
        </g>
        <!-- Secondary: Orange/peach från höger-övre -->
        <g transform="rotate(15, 95, -10)">
          <ellipse cx="95" cy="-10" rx="90" ry="55" fill="#f97316" fill-opacity="0.02" />
          <ellipse cx="95" cy="-10" rx="70" ry="42" fill="#f97316" fill-opacity="0.03" />
          <ellipse cx="95" cy="-10" rx="50" ry="30" fill="#f97316" fill-opacity="0.04" />
          <ellipse cx="95" cy="-10" rx="30" ry="18" fill="#f97316" fill-opacity="0.05" />
        </g>
        <!-- Tertiary: Lila accent från mitten-höger -->
        <g transform="rotate(-5, 110, 60)">
          <ellipse cx="110" cy="60" rx="70" ry="45" fill="#8b5cf6" fill-opacity="0.015" />
          <ellipse cx="110" cy="60" rx="50" ry="32" fill="#8b5cf6" fill-opacity="0.025" />
          <ellipse cx="110" cy="60" rx="30" ry="20" fill="#8b5cf6" fill-opacity="0.035" />
        </g>
        <!-- Subtle blue glow top-left -->
        <ellipse cx="5" cy="10" rx="45" ry="35" fill="#3b82f6" fill-opacity="0.02" />
        <ellipse cx="5" cy="10" rx="25" ry="20" fill="#3b82f6" fill-opacity="0.03" />
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
</style>

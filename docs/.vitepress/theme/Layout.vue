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
        <!-- Premium koncentriska bågar - fyllda -->
        <g transform="rotate(-12, 20, 110)">
          <ellipse cx="20" cy="110" rx="110" ry="70" fill="var(--color-brand)" fill-opacity="0.02" />
          <ellipse cx="20" cy="110" rx="95" ry="60" fill="var(--color-brand)" fill-opacity="0.03" />
          <ellipse cx="20" cy="110" rx="80" ry="50" fill="var(--color-brand)" fill-opacity="0.04" />
          <ellipse cx="20" cy="110" rx="65" ry="40" fill="var(--color-brand)" fill-opacity="0.05" />
          <ellipse cx="20" cy="110" rx="50" ry="31" fill="var(--color-brand)" fill-opacity="0.06" />
          <ellipse cx="20" cy="110" rx="35" ry="22" fill="var(--color-brand)" fill-opacity="0.07" />
          <ellipse cx="20" cy="110" rx="20" ry="13" fill="var(--color-brand)" fill-opacity="0.08" />
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
</style>

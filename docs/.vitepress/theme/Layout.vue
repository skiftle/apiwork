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
      <svg class="home-bg" viewBox="0 0 1440 600" preserveAspectRatio="xMidYMin slice" aria-hidden="true">
        <!-- Koncentriska bågar med twist -->
        <g transform="rotate(-8, 400, 550)">
          <ellipse cx="400" cy="550" rx="900" ry="600" fill="var(--color-brand)" fill-opacity="0.03" />
          <ellipse cx="400" cy="550" rx="700" ry="470" fill="var(--color-brand)" fill-opacity="0.05" />
          <ellipse cx="400" cy="550" rx="520" ry="350" fill="var(--color-brand)" fill-opacity="0.07" />
          <ellipse cx="400" cy="550" rx="360" ry="250" fill="var(--color-brand)" fill-opacity="0.09" />
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
  background:
    linear-gradient(
      to bottom,
      var(--color-bg) 0%,
      var(--color-bg) 600px,
      var(--color-hero-gradient-start) 600px,
      var(--color-bg) 100%
    );
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

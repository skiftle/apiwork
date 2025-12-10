<script setup lang="ts">
import { Content } from 'vitepress'
import AppSidebar from './AppSidebar.vue'
</script>

<template>
  <div class="guide-layout">
    <AppSidebar />
    <article class="guide-content">
      <div class="guide-content-container">
        <Content />
      </div>
    </article>
  </div>
</template>

<style scoped>
.guide-layout {
  display: flex;
  max-width: 1400px;
  margin: 0 auto;
}

.guide-content {
  flex: 1;
  min-width: 0;
  padding: var(--space-8) var(--space-8) var(--space-16);
}

.guide-content-container {
  max-width: var(--content-max-width);
  margin: 0 auto;
}

/* TODO: Add outline/TOC sidebar on the right */
/* TODO: Add responsive styles */
</style>

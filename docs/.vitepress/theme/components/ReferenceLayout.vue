<script setup lang="ts">
import { Content } from "vitepress";
import AppSidebar from "./AppSidebar.vue";
import PageOutline from "./PageOutline.vue";
</script>

<template>
  <div class="reference-layout">
    <AppSidebar />
    <article class="reference-content">
      <div class="reference-content-container">
        <Content />
      </div>
    </article>
    <PageOutline />
  </div>
</template>

<style scoped>
.reference-layout {
  display: flex;
  max-width: 1400px;
  margin: 0 auto;
}

.reference-content {
  flex: 1;
  min-width: 0;
  padding: var(--space-8) var(--space-8) var(--space-16);
}

.reference-content-container {
  max-width: var(--content-max-width);
  margin: 0 auto;
}
</style>

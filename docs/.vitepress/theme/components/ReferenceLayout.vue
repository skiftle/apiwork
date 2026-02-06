<script setup lang="ts">
import { Content } from "vitepress";
import AppSidebar from "./AppSidebar.vue";
import PageOutline from "./PageOutline.vue";
import ReferenceBreadcrumb from "./ReferenceBreadcrumb.vue";
</script>

<template>
  <div class="reference-layout">
    <AppSidebar />
    <article class="reference-content">
      <div class="reference-content-container">
        <ReferenceBreadcrumb />
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
  padding: var(--space-8) var(--space-12) 100px;
}

.reference-content-container {
  max-width: var(--content-max-width);
  margin: 0 auto;
}

/* Hide the first h1 since breadcrumb serves as the page title */
.reference-content-container :deep(h1:first-of-type) {
  display: none;
}
</style>

<script setup lang="ts"></script>

<template>
  <div class="code-window">
    <div class="body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.code-window {
  position: relative;
  border-radius: 12px;
  overflow: hidden;

  .body {
    padding: var(--space-4);
    background: var(--shiki-background);
    border: 1px solid rgba(255, 255, 255, 0.06);
    border-radius: 12px;
  }
}

.code-window .body :deep(pre) {
  margin: 0;
  background: transparent;
  border: none;
  padding: 0;
}

.code-window .body :deep(code) {
  font-family: var(--font-mono);
  font-size: 0.875rem;
  line-height: 1.7;
  color: var(--shiki-foreground);
  background: transparent;
  padding: 0;
}

@media (max-width: 768px) {
  .code-window .body :deep(code) {
    font-size: 0.8rem;
  }
}
</style>

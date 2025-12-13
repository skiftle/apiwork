<script setup lang="ts">
defineProps<{
  filename: string;
}>();
</script>

<template>
  <div class="code-window">
    <span class="filename">{{ filename }}</span>
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

  .filename {
    position: absolute;
    top: var(--space-2);
    right: var(--space-3);
    z-index: 2;
    font-size: 10px;
    font-weight: 500;
    color: rgba(255, 255, 255, 0.5);
    letter-spacing: 0.05em;
    padding: var(--space-1) var(--space-2);
    background: rgba(255, 255, 255, 0.06);
    border-radius: 4px;
    font-family: var(--font-mono);
  }

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

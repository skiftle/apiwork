<script setup lang="ts">
defineProps<{
  filename: string;
}>();
</script>

<template>
  <div class="code-window">
    <div class="code-window-header">
      <span class="code-window-dot code-window-dot--red"></span>
      <span class="code-window-dot code-window-dot--yellow"></span>
      <span class="code-window-dot code-window-dot--green"></span>
      <span class="code-window-filename">{{ filename }}</span>
    </div>
    <div class="code-window-body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.code-window {
  border-radius: 12px;
  overflow: hidden;
  background: color-mix(in srgb, var(--color-code-bg), transparent 10%);
  -webkit-backdrop-filter: blur(12px);
  backdrop-filter: blur(12px);
  border: 1px solid var(--color-code-border);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.04), 0 12px 28px rgba(0, 0, 0, 0.06),
    0 20px 48px rgba(0, 0, 0, 0.04), 0 0 80px var(--color-brand-6);
  transition: transform 400ms cubic-bezier(0.16, 1, 0.3, 1),
    box-shadow 400ms cubic-bezier(0.16, 1, 0.3, 1);
}

.dark .code-window {
  border-color: transparent;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.15), 0 12px 28px rgba(0, 0, 0, 0.2),
    0 20px 48px rgba(0, 0, 0, 0.15), 0 0 80px var(--color-brand-6);
}

.code-window:hover {
  transform: translateY(-6px) scale(1.005);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.06), 0 24px 48px rgba(0, 0, 0, 0.08),
    0 32px 64px rgba(0, 0, 0, 0.06), 0 0 100px var(--color-brand-10);
}

.dark .code-window:hover {
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2), 0 24px 48px rgba(0, 0, 0, 0.25),
    0 32px 64px rgba(0, 0, 0, 0.2), 0 0 100px var(--color-brand-10);
}

.code-window-header {
  background: var(--color-code-header);
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 8px;
  border-bottom: 1px solid var(--color-code-header-border);
}

.code-window-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.code-window-dot--red {
  background: #ff5f57;
}

.code-window-dot--yellow {
  background: #febc2e;
}

.code-window-dot--green {
  background: #28c840;
}

.code-window-filename {
  margin-left: auto;
  font-size: 0.75rem;
  color: var(--color-code-filename);
  font-family: var(--font-mono);
}

.code-window-body {
  padding: 20px 24px;
}

.code-window-body :deep(pre) {
  margin: 0;
  background: transparent;
  border: none;
  padding: 0;
}

.code-window-body :deep(code) {
  font-family: var(--font-mono);
  font-size: 0.875rem;
  line-height: 1.7;
  color: var(--color-syntax-text);
}

@media (max-width: 768px) {
  .code-window-body {
    padding: 16px;
  }

  .code-window-body :deep(code) {
    font-size: 0.8rem;
  }
}
</style>

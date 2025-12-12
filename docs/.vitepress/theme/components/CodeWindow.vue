<script setup lang="ts">
defineProps<{
  filename: string;
}>();
</script>

<template>
  <div class="code-window">
    <div class="header">
      <span class="dot red"></span>
      <span class="dot yellow"></span>
      <span class="dot green"></span>
      <span class="filename">{{ filename }}</span>
    </div>
    <div class="body">
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

  box-shadow: 0 0 0 1px var(--color-code-border), 0 1px 0 var(--color-overlay-6),
    0 4px 6px var(--color-overlay-4), 0 12px 28px var(--color-overlay-6),
    0 20px 48px var(--color-overlay-4), 0 0 80px var(--color-brand-6);

  transition: transform 400ms cubic-bezier(0.16, 1, 0.3, 1),
    box-shadow 400ms cubic-bezier(0.16, 1, 0.3, 1);

  .dark & {
    border-color: transparent;
    box-shadow: 0 4px 6px var(--color-overlay-15), 0 12px 28px var(--color-overlay-20),
      0 20px 48px var(--color-overlay-15), 0 0 80px var(--color-brand-6);
  }

  &:hover {
    transform: translateY(-6px) scale(1.005);
    box-shadow: 0 8px 16px var(--color-overlay-6), 0 24px 48px var(--color-overlay-8),
      0 32px 64px var(--color-overlay-6), 0 0 100px var(--color-brand-10);

    .dark & {
      box-shadow: 0 8px 16px var(--color-overlay-20), 0 24px 48px var(--color-overlay-25),
        0 32px 64px var(--color-overlay-20), 0 0 100px var(--color-brand-10);
    }
  }

  .header {
    background: var(--color-code-header);
    padding: 12px 16px;
    display: flex;
    align-items: center;
    gap: 8px;
    border-bottom: 1px solid var(--color-code-header-border);
  }

  .dot {
    width: 12px;
    height: 12px;
    border-radius: 50%;

    &.red {
      background: #ff5f57;
    }

    &.yellow {
      background: #febc2e;
    }

    &.green {
      background: #28c840;
    }
  }

  .filename {
    margin-left: auto;
    font-size: 0.75rem;
    color: var(--color-code-filename);
    font-family: var(--font-mono);
  }

  .body {
    padding: 20px 24px;

    @media (max-width: 768px) {
      padding: 16px;
    }
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

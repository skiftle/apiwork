<script setup lang="ts">
defineProps<{
  name: string;
  description: string;
}>();
</script>

<template>
  <div class="feature-card">
    <svg
      class="icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
    >
      <slot name="icon" />
    </svg>
    <h3 class="name">{{ name }}</h3>
    <p class="desc">{{ description }}</p>
  </div>
</template>

<style scoped>
.feature-card {
  background: transparent;
  padding: 28px 24px;
  transition: background 300ms ease;
  border-right: 1px solid var(--color-dark-border-subtle);
  border-bottom: 1px solid var(--color-dark-border-subtle);

  &:nth-child(4n) {
    border-right: none;
  }

  &:nth-last-child(-n + 4) {
    border-bottom: none;
  }

  &:hover {
    background: var(--color-dark-bg-hover);
  }

  .icon {
    width: 20px;
    height: 20px;
    color: var(--color-brand-60);
    margin-bottom: 12px;
    stroke-width: 1.5;
  }

  .name {
    font-size: 0.9375rem;
    font-weight: 600;
    margin-bottom: 10px;
    color: var(--color-dark-text-primary);
  }

  .desc {
    font-size: 0.8125rem;
    color: var(--color-dark-text-muted);
    line-height: 1.6;
    margin: 0;
  }

  @media (max-width: 900px) {
    padding: 24px 20px;

    &:nth-child(4n) {
      border-right: 1px solid var(--color-dark-border-subtle);
    }

    &:nth-child(2n) {
      border-right: none;
    }

    &:nth-last-child(-n + 4) {
      border-bottom: 1px solid var(--color-dark-border-subtle);
    }

    &:nth-last-child(-n + 2) {
      border-bottom: none;
    }
  }

  @media (max-width: 600px) {
    &:nth-child(2n),
    &:nth-child(4n) {
      border-right: none;
    }

    &:nth-last-child(-n + 2),
    &:nth-last-child(-n + 4) {
      border-bottom: 1px solid var(--color-dark-border-subtle);
    }

    &:last-child {
      border-bottom: none;
    }
  }
}
</style>

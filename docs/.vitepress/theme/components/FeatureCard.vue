<script setup lang="ts">
defineProps<{
  name: string;
  description: string;
}>();
</script>

<template>
  <div class="feature-card">
    <svg
      class="feature-card-icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
    >
      <slot name="icon" />
    </svg>
    <h3 class="feature-card-name">{{ name }}</h3>
    <p class="feature-card-desc">{{ description }}</p>
  </div>
</template>

<style scoped>
.feature-card {
  background: transparent;
  padding: 28px 24px;
  transition: background 300ms ease;
  border-right: 1px solid rgba(255, 255, 255, 0.02);
  border-bottom: 1px solid rgba(255, 255, 255, 0.02);
}

.feature-card:nth-child(4n) {
  border-right: none;
}

.feature-card:nth-last-child(-n + 4) {
  border-bottom: none;
}

.feature-card:hover {
  background: rgba(255, 255, 255, 0.03);
}

.feature-card-icon {
  width: 20px;
  height: 20px;
  color: var(--color-brand-60);
  margin-bottom: 12px;
  stroke-width: 1.5;
}

.feature-card-name {
  font-size: 0.9375rem;
  font-weight: 600;
  margin-bottom: 10px;
  background: linear-gradient(
    135deg,
    rgba(255, 255, 255, 0.95) 0%,
    rgba(170, 175, 185, 0.85) 25%,
    rgba(255, 255, 255, 1) 50%,
    rgba(170, 175, 185, 0.85) 75%,
    rgba(255, 255, 255, 0.95) 100%
  );
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

.feature-card-desc {
  font-size: 0.8125rem;
  color: rgba(255, 255, 255, 0.4);
  line-height: 1.6;
  margin: 0;
}

@media (max-width: 900px) {
  .feature-card:nth-child(4n) {
    border-right: 1px solid rgba(255, 255, 255, 0.02);
  }

  .feature-card:nth-child(2n) {
    border-right: none;
  }

  .feature-card:nth-last-child(-n + 4) {
    border-bottom: 1px solid rgba(255, 255, 255, 0.02);
  }

  .feature-card:nth-last-child(-n + 2) {
    border-bottom: none;
  }

  .feature-card {
    padding: 24px 20px;
  }
}

@media (max-width: 600px) {
  .feature-card:nth-child(2n),
  .feature-card:nth-child(4n) {
    border-right: none;
  }

  .feature-card:nth-last-child(-n + 2),
  .feature-card:nth-last-child(-n + 4) {
    border-bottom: 1px solid rgba(255, 255, 255, 0.02);
  }

  .feature-card:last-child {
    border-bottom: none;
  }
}
</style>

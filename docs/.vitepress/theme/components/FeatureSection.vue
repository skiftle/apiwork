<script setup lang="ts">
defineProps<{
  step: string;
  description: string;
  alt?: boolean;
  wide?: boolean;
  blobVariant?: 1 | 2 | 3 | 4;
}>();
</script>

<template>
  <section class="feature" :class="{ 'feature--alt': alt }">
    <div
      class="feature-container"
      :class="{ 'feature-container--wide': wide }"
    >
      <div
        class="feature-content"
        :class="{ 'feature-content--centered': wide }"
      >
        <div class="feature-blob" :class="`feature-blob--${blobVariant || 1}`"></div>
        <span class="feature-step">{{ step }}</span>
        <h2 class="feature-title">
          <slot name="icon" />
          <slot name="title" />
        </h2>
        <p class="feature-description">{{ description }}</p>
      </div>
      <div v-if="wide" class="output-grid">
        <slot name="code" />
      </div>
      <div v-else class="feature-code">
        <slot name="code" />
      </div>
    </div>
  </section>
</template>

<style scoped>
.feature {
  padding: 100px 24px;
  position: relative;
}

.feature--alt {
  background: linear-gradient(
    180deg,
    transparent 0%,
    rgba(254, 242, 242, 0.4) 50%,
    transparent 100%
  );
}

.dark .feature--alt {
  background: linear-gradient(
    180deg,
    transparent 0%,
    rgba(30, 20, 22, 0.5) 50%,
    transparent 100%
  );
}

.feature-container {
  display: grid;
  grid-template-columns: 1fr 1.3fr;
  gap: 64px;
  max-width: 1200px;
  margin: 0 auto;
  align-items: center;
}

.feature--alt .feature-container {
  direction: rtl;
}

.feature--alt .feature-container > * {
  direction: ltr;
}

.feature-container--wide {
  grid-template-columns: 1fr;
  max-width: 1000px;
}

.feature-container--wide .feature-content {
  text-align: center;
  margin-bottom: 48px;
}

.feature-content--centered {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.feature-content--centered .feature-description {
  text-align: center;
}

.feature-blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(60px);
  opacity: 0.5;
  pointer-events: none;
  z-index: 0;
}

.feature-blob--1 {
  width: 200px;
  height: 200px;
  background: radial-gradient(circle, var(--color-brand-35) 0%, transparent 70%);
  top: -40px;
  left: -60px;
}

.feature-blob--2 {
  width: 180px;
  height: 180px;
  background: radial-gradient(circle, var(--color-brand-30) 0%, transparent 70%);
  top: -30px;
  left: -40px;
}

.feature-blob--3 {
  width: 220px;
  height: 220px;
  background: radial-gradient(circle, var(--color-brand-35) 0%, transparent 70%);
  top: -50px;
  left: -70px;
}

.feature-blob--4 {
  width: 160px;
  height: 160px;
  background: radial-gradient(circle, var(--color-brand-30) 0%, transparent 70%);
  top: -20px;
  left: 50%;
  transform: translateX(-50%);
}

.dark .feature-blob {
  opacity: 0.3;
}

.feature-content {
  position: relative;
}

.feature-step {
  display: inline-block;
  font-size: 4rem;
  font-weight: 800;
  letter-spacing: -0.05em;
  background: linear-gradient(135deg, var(--color-brand-15) 0%, var(--color-brand-5) 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 16px;
  line-height: 1;
}

.feature-title {
  font-size: 2.25rem;
  font-weight: 700;
  color: var(--color-text);
  line-height: 1.15;
  letter-spacing: -0.03em;
  margin-top: 0;
  margin-bottom: 20px;
}

.feature-title :deep(.accent) {
  color: var(--color-brand-70);
}

.feature-title :deep(.feature-icon) {
  width: 32px;
  height: 32px;
  color: var(--color-brand-70);
  margin-right: 12px;
  vertical-align: middle;
  margin-top: -4px;
}

.feature-description {
  font-size: 1.1rem;
  color: var(--color-text-muted);
  line-height: 1.7;
  max-width: 480px;
}

.feature-code {
  position: relative;
}

.feature-code::before {
  content: "";
  position: absolute;
  top: 20%;
  left: -10%;
  width: 50%;
  height: 60%;
  background: radial-gradient(ellipse, var(--color-brand-15) 0%, transparent 70%);
  filter: blur(40px);
  pointer-events: none;
  z-index: -1;
}

.feature-code::after {
  content: "";
  position: absolute;
  bottom: 10%;
  right: -5%;
  width: 40%;
  height: 50%;
  background: radial-gradient(ellipse, var(--color-brand-10) 0%, transparent 70%);
  filter: blur(50px);
  pointer-events: none;
  z-index: -1;
}

.dark .feature-code::before,
.dark .feature-code::after {
  opacity: 0.5;
}

.output-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

@media (max-width: 900px) {
  .feature {
    padding: 64px 20px;
  }

  .feature-container {
    grid-template-columns: 1fr;
    gap: 40px;
  }

  .feature--alt .feature-container {
    direction: ltr;
  }

  .feature-title {
    font-size: 1.75rem;
  }

  .feature-description {
    font-size: 1rem;
  }

  .output-grid {
    grid-template-columns: 1fr;
  }
}
</style>

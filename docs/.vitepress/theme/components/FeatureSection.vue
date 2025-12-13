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
  <section class="feature" :class="{ alt }">
    <div class="container" :class="{ wide }">
      <div class="content" :class="{ centered: wide }">
        <div class="blob" :class="`v${blobVariant || 1}`"></div>
        <div class="step"><span>{{ step }}</span></div>
        <h2 class="title">
          <slot name="icon" />
          <slot name="title" />
        </h2>
        <p class="description">{{ description }}</p>
      </div>
      <div v-if="wide" class="output-grid">
        <slot name="code" />
      </div>
      <div v-else class="code">
        <slot name="code" />
      </div>
    </div>
  </section>
</template>

<style scoped>
.feature {
  padding: 100px 24px;
  position: relative;

  &.alt {
    background: linear-gradient(
      180deg,
      transparent 0%,
      var(--color-section-alt) 50%,
      transparent 100%
    );

    .container {
      direction: rtl;

      > * {
        direction: ltr;
      }
    }
  }

  .container {
    display: grid;
    grid-template-columns: 1fr 1.3fr;
    gap: 64px;
    max-width: 1200px;
    margin: 0 auto;
    align-items: center;

    &.wide {
      grid-template-columns: 1fr;
      max-width: 1000px;

      .content {
        text-align: center;
        margin-bottom: 48px;
      }
    }
  }

  .content {
    position: relative;

    &.centered {
      display: flex;
      flex-direction: column;
      align-items: center;

      .description {
        text-align: center;
      }
    }
  }

  .blob {
    position: absolute;
    border-radius: 50%;
    filter: blur(60px);
    opacity: 0.5;
    pointer-events: none;
    z-index: 0;

    .dark & {
      opacity: 0.3;
    }

    &.v1 {
      width: 200px;
      height: 200px;
      background: radial-gradient(
        circle,
        var(--color-brand-35) 0%,
        transparent 70%
      );
      top: -40px;
      left: -60px;
    }

    &.v2 {
      width: 180px;
      height: 180px;
      background: radial-gradient(
        circle,
        var(--color-brand-30) 0%,
        transparent 70%
      );
      top: -30px;
      left: -40px;
    }

    &.v3 {
      width: 220px;
      height: 220px;
      background: radial-gradient(
        circle,
        var(--color-brand-35) 0%,
        transparent 70%
      );
      top: -50px;
      left: -70px;
    }

    &.v4 {
      width: 160px;
      height: 160px;
      background: radial-gradient(
        circle,
        var(--color-brand-30) 0%,
        transparent 70%
      );
      top: -20px;
      left: 50%;
      transform: translateX(-50%);
    }
  }

  .step {
    /* Diamond shape */
    width: 64px;
    height: 64px;
    transform: rotate(45deg);
    border-radius: 12px;
    margin-bottom: 24px;
    position: relative;
    z-index: 1;

    /* Glassmorphism */
    background: rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border: 1px solid rgba(255, 255, 255, 0.3);
    box-shadow:
      0 8px 32px rgba(0, 0, 0, 0.06),
      0 2px 8px rgba(0, 0, 0, 0.03),
      inset 0 1px 0 rgba(255, 255, 255, 0.4);

    /* Center the number */
    display: flex;
    align-items: center;
    justify-content: center;

    span {
      transform: rotate(-45deg);
      font-size: 1.25rem;
      font-weight: 700;
      letter-spacing: -0.02em;
      color: var(--color-brand-80);
    }

    .dark & {
      background: rgba(255, 255, 255, 0.1);
      border-color: rgba(255, 255, 255, 0.15);
      box-shadow:
        0 8px 32px rgba(0, 0, 0, 0.3),
        0 2px 8px rgba(0, 0, 0, 0.2),
        inset 0 1px 0 rgba(255, 255, 255, 0.15);
    }
  }

  .title {
    font-size: 2.25rem;
    font-weight: 700;
    color: var(--color-text);
    line-height: 1.15;
    letter-spacing: -0.03em;
    margin-top: 0;
    margin-bottom: 20px;
  }

  .description {
    font-size: 1.1rem;
    color: var(--color-text-muted);
    line-height: 1.7;
    max-width: 480px;
    font-weight: 500;
  }

  .code {
    position: relative;

    &::before {
      content: "";
      position: absolute;
      top: 20%;
      left: -10%;
      width: 50%;
      height: 60%;
      background: radial-gradient(
        ellipse,
        var(--color-brand-15) 0%,
        transparent 70%
      );
      filter: blur(40px);
      pointer-events: none;
      z-index: -1;
    }

    &::after {
      content: "";
      position: absolute;
      bottom: 10%;
      right: -5%;
      width: 40%;
      height: 50%;
      background: radial-gradient(
        ellipse,
        var(--color-brand-10) 0%,
        transparent 70%
      );
      filter: blur(50px);
      pointer-events: none;
      z-index: -1;
    }

    .dark &::before,
    .dark &::after {
      opacity: 0.5;
    }
  }

  .output-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
  }

  @media (max-width: 900px) {
    padding: 64px 20px;

    &.alt .container {
      direction: ltr;
    }

    .container {
      grid-template-columns: 1fr;
      gap: 40px;
    }

    .title {
      font-size: 1.75rem;
    }

    .description {
      font-size: 1rem;
    }

    .output-grid {
      grid-template-columns: 1fr;
    }
  }
}

.feature .title :deep(.accent) {
  color: var(--color-brand-80);
}

.feature .title :deep(.feature-icon) {
  width: 32px;
  height: 32px;
  color: var(--color-brand-80);
  margin-right: 12px;
  vertical-align: middle;
  margin-top: -4px;
}
</style>

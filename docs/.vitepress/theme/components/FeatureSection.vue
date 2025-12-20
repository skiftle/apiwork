<script setup lang="ts">
import type { HighlightedFeature } from "../../data/homepage.data";
import { icons } from "../../data/icons";
import CodeWindow from "./CodeWindow.vue";

defineProps<{
  feature: HighlightedFeature;
}>();
</script>

<template>
  <section class="feature" :class="{ alt: feature.alt }">
    <div class="container" :class="{ wide: feature.wide }">
      <div class="content" :class="{ centered: feature.wide }">
        <div class="blob" :class="`v${feature.blobVariant || 1}`"></div>
        <h2 class="title">
          <svg
            class="feature-icon"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            v-html="icons[feature.icon]"
          />
          {{ feature.title }}
          <span class="accent">{{ feature.titleAccent }}</span>
        </h2>
        <p class="description">{{ feature.description }}</p>
      </div>
      <div v-if="feature.wide" class="output-grid">
        <CodeWindow
          v-for="(html, index) in feature.highlightedBlocks"
          :key="index"
        >
          <div v-html="html" />
        </CodeWindow>
      </div>
      <div v-else class="code">
        <div v-if="feature.highlightedBlocks.length > 1" class="code-stack">
          <CodeWindow
            v-for="(html, index) in feature.highlightedBlocks"
            :key="index"
          >
            <div v-html="html" />
          </CodeWindow>
        </div>
        <CodeWindow v-else>
          <div v-html="feature.highlightedBlocks[0]" />
        </CodeWindow>
      </div>
    </div>
  </section>
</template>

<style scoped>
.feature {
  padding: 100px 24px;
  position: relative;

  &.alt {
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

  .code-stack {
    display: flex;
    flex-direction: column;
    gap: 32px;
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

.feature .title .accent {
  color: var(--color-brand-80);
}

.feature .title .feature-icon {
  width: 32px;
  height: 32px;
  color: var(--color-brand-80);
  margin-right: 12px;
  vertical-align: middle;
  margin-top: -4px;
}
</style>

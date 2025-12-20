<script setup lang="ts">
import { moreFeatures } from "../../data/homepage";
import FeatureCard from "./FeatureCard.vue";
</script>

<template>
  <section class="more-features">
    <div class="container">
      <div class="header">
        <h2 class="title">And so much more</h2>
        <p class="subtitle">
          Everything you need to build production-ready APIs
        </p>
      </div>
      <div class="grid">
        <FeatureCard
          v-for="feature in moreFeatures"
          :key="feature.name"
          :feature="feature"
        />
      </div>
    </div>
  </section>
</template>

<style scoped>
.more-features {
  position: relative;
  padding: 120px 24px;
  overflow: hidden;
  background: var(--color-bg-dark-section);
  border-bottom: 1px solid var(--color-dark-border-subtle);

  .container {
    position: relative;
    z-index: 1;
    max-width: 1100px;
    margin: 0 auto;
  }

  .header {
    text-align: center;
    margin-bottom: 64px;
  }

  .title {
    font-size: 2.5rem;
    font-weight: 700;
    letter-spacing: -0.03em;
    margin-bottom: 16px;
    color: var(--color-dark-text-primary);
  }

  .subtitle {
    font-size: 1.125rem;
    color: var(--color-dark-text-secondary);
    max-width: 500px;
    margin: 0 auto;
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
  }

  @media (max-width: 900px) {
    padding: 80px 20px;

    .header {
      margin-bottom: 48px;
    }

    .grid {
      grid-template-columns: repeat(2, 1fr);
    }

    .title {
      font-size: 2rem;
    }
  }

  @media (max-width: 600px) {
    .grid {
      grid-template-columns: 1fr;
    }
  }
}
</style>

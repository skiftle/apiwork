<script setup lang="ts">
import { useData } from 'vitepress'

const { frontmatter } = useData()

// Read hero and features from frontmatter
const hero = frontmatter.value.hero
const features = frontmatter.value.features
</script>

<template>
  <div class="home-layout">
    <!-- Hero Section -->
    <section v-if="hero" class="hero">
      <div class="hero-container">
        <h1 class="hero-name">{{ hero.name }}</h1>
        <p class="hero-text">{{ hero.text }}</p>
        <p v-if="hero.tagline" class="hero-tagline">{{ hero.tagline }}</p>

        <div v-if="hero.actions" class="hero-actions">
          <a
            v-for="action in hero.actions"
            :key="action.link"
            :href="action.link"
            class="hero-action"
            :class="action.theme"
          >
            {{ action.text }}
          </a>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section v-if="features && features.length" class="features">
      <div class="features-container">
        <div class="features-grid">
          <div v-for="feature in features" :key="feature.title" class="feature">
            <span v-if="feature.icon" class="feature-icon">{{ feature.icon }}</span>
            <h3 class="feature-title">{{ feature.title }}</h3>
            <p class="feature-details">{{ feature.details }}</p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.home-layout {
  max-width: 1200px;
  margin: 0 auto;
  padding: var(--space-16) var(--space-6);
}

/* Hero */
.hero {
  text-align: center;
  padding: var(--space-16) 0;
}

.hero-container {
  max-width: 800px;
  margin: 0 auto;
}

.hero-name {
  font-size: var(--font-size-4xl);
  font-weight: 700;
  color: var(--color-brand);
  margin-bottom: var(--space-4);
}

.hero-text {
  font-size: var(--font-size-2xl);
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: var(--space-4);
}

.hero-tagline {
  font-size: var(--font-size-lg);
  color: var(--color-text-muted);
  margin-bottom: var(--space-8);
}

.hero-actions {
  display: flex;
  justify-content: center;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.hero-action {
  display: inline-block;
  padding: var(--space-3) var(--space-6);
  font-size: var(--font-size-base);
  font-weight: 500;
  text-decoration: none;
  border-radius: var(--border-radius-lg);
  transition: all var(--transition-fast);
}

.hero-action.brand {
  background: var(--color-brand);
  color: white;
}

.hero-action.brand:hover {
  background: var(--color-brand-dark);
  text-decoration: none;
}

.hero-action.alt {
  background: var(--color-bg-soft);
  color: var(--color-text);
  border: 1px solid var(--color-border);
}

.hero-action.alt:hover {
  background: var(--color-bg-muted);
  text-decoration: none;
}

/* Features */
.features {
  padding: var(--space-16) 0;
}

.features-container {
  max-width: 1100px;
  margin: 0 auto;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--space-8);
}

.feature {
  padding: var(--space-6);
  background: var(--color-bg-soft);
  border-radius: var(--border-radius-lg);
  border: 1px solid var(--color-border-light);
}

.feature-icon {
  font-size: var(--font-size-2xl);
  margin-bottom: var(--space-3);
  display: block;
}

.feature-title {
  font-size: var(--font-size-lg);
  font-weight: 600;
  color: var(--color-text);
  margin-top: 0;
  margin-bottom: var(--space-2);
}

.feature-details {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  line-height: 1.6;
  margin-bottom: 0;
}

/* TODO: Add responsive breakpoints */
/* TODO: Add animations */
</style>

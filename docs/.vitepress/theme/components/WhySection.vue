<script setup lang="ts">
import { whyPoints } from "../../data/homepage";
import { icons } from "../../data/icons";
</script>

<template>
  <section class="why-section">
    <div class="container">
      <div class="points-grid">
        <div v-for="point in whyPoints" :key="point.title" class="point">
          <div class="icon">
            <svg
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              v-html="icons[point.icon]"
            />
          </div>
          <h3>{{ point.title }}</h3>
          <p>{{ point.description }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.why-section {
  padding: 40px 24px 100px;
  position: relative;
}

.container {
  max-width: 1100px;
  margin: 0 auto;
}

.section-title {
  text-align: center;
  font-size: 1.75rem;
  font-weight: 500;
  letter-spacing: -0.01em;
  margin-bottom: 56px;

  .accent {
    color: var(--color-brand-80);
  }
}

.points-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 40px 64px;
}

.point {
  position: relative;
}

.point .icon {
  width: 40px;
  height: 40px;
  margin-bottom: 16px;
  color: var(--color-brand-80);
}

.point .icon svg {
  width: 100%;
  height: 100%;
}

.point h3 {
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 10px;
  line-height: 1.35;
}

.point p {
  font-size: 0.95rem;
  color: var(--color-text-muted);
  line-height: 1.65;
  margin: 0;
}

@media (max-width: 768px) {
  .why-section {
    padding: 60px 20px 80px;
  }

  .section-title {
    font-size: 1.375rem;
    margin-bottom: 40px;
  }

  .points-grid {
    grid-template-columns: 1fr;
    gap: 32px;
  }
}

@media (max-width: 480px) {
  .section-title {
    font-size: 1.25rem;
  }

  .point .icon {
    width: 32px;
    height: 32px;
  }
}
</style>

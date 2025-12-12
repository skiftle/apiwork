<script setup lang="ts">
import FeatureCard from "./FeatureCard.vue";
</script>

<template>
  <div class="section-curve-wrapper">
    <svg
      class="section-curve"
      viewBox="0 0 1440 120"
      preserveAspectRatio="none"
    >
      <path
        d="M0,120 C480,20 960,20 1440,120 L1440,120 L0,120 Z"
        fill="currentColor"
      />
    </svg>
  </div>

  <section class="more-features">
    <div class="more-features-container">
      <div class="more-features-header">
        <h2 class="more-features-title">And so much more</h2>
        <p class="more-features-subtitle">
          Everything you need to build production-ready APIs
        </p>
      </div>
      <div class="more-features-grid">
        <FeatureCard
          name="Rich Filtering"
          description="Filter by any attribute with operators like eq, gt, lt, contains, between, and more."
        >
          <template #icon>
            <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3" />
          </template>
        </FeatureCard>
        <FeatureCard
          name="Multi-field Sorting"
          description="Sort by multiple fields with priority ordering and nested association support."
        >
          <template #icon>
            <line x1="12" y1="5" x2="12" y2="19" />
            <polyline points="19 12 12 19 5 12" />
          </template>
        </FeatureCard>
        <FeatureCard
          name="Offset Pagination"
          description="Traditional page-based pagination with total counts and page metadata."
        >
          <template #icon>
            <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
            <line x1="3" y1="9" x2="21" y2="9" />
            <line x1="3" y1="15" x2="21" y2="15" />
          </template>
        </FeatureCard>
        <FeatureCard
          name="Cursor Pagination"
          description="Efficient cursor-based pagination for large datasets without total counts."
        >
          <template #icon>
            <line x1="5" y1="12" x2="19" y2="12" />
            <polyline points="12 5 19 12 12 19" />
          </template>
        </FeatureCard>
        <FeatureCard
          name="Eager Loading"
          description="Automatic N+1 query prevention with smart association preloading."
        >
          <template #icon>
            <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
          </template>
        </FeatureCard>
        <FeatureCard
          name="STI Support"
          description="Single Table Inheritance with automatic type inference and discriminated unions."
        >
          <template #icon>
            <line x1="6" y1="3" x2="6" y2="15" />
            <circle cx="18" cy="6" r="3" />
            <circle cx="6" cy="18" r="3" />
            <path d="M18 9a9 9 0 0 1-9 9" />
          </template>
        </FeatureCard>
        <FeatureCard
          name="Polymorphic"
          description="Full polymorphic association support with discriminated union type generation."
        >
          <template #icon>
            <rect x="3" y="3" width="7" height="7" />
            <rect x="14" y="3" width="7" height="7" />
            <rect x="14" y="14" width="7" height="7" />
            <rect x="3" y="14" width="7" height="7" />
          </template>
        </FeatureCard>
        <FeatureCard
          name="Nested Resources"
          description="Deep association traversal with circular reference prevention."
        >
          <template #icon>
            <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
            <line x1="12" y1="11" x2="12" y2="17" />
            <line x1="9" y1="14" x2="15" y2="14" />
          </template>
        </FeatureCard>
        <FeatureCard
          name="i18n Ready"
          description="Localized error messages, descriptions, and multi-language documentation."
        >
          <template #icon>
            <circle cx="12" cy="12" r="10" />
            <line x1="2" y1="12" x2="22" y2="12" />
            <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
          </template>
        </FeatureCard>
        <FeatureCard
          name="Error Handling"
          description="Structured, machine-readable errors with codes, paths, and detailed messages."
        >
          <template #icon>
            <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
            <line x1="12" y1="9" x2="12" y2="13" />
            <line x1="12" y1="17" x2="12.01" y2="17" />
          </template>
        </FeatureCard>
        <FeatureCard
          name="Key Transform"
          description="Automatic key case conversion between camelCase and snake_case."
        >
          <template #icon>
            <polyline points="23 4 23 10 17 10" />
            <polyline points="1 20 1 14 7 14" />
            <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" />
          </template>
        </FeatureCard>
        <FeatureCard
          name="Partial Updates"
          description="PATCH operations with automatically generated partial types for updates."
        >
          <template #icon>
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
          </template>
        </FeatureCard>
      </div>
    </div>
  </section>
</template>

<style scoped>
.section-curve-wrapper {
  color: var(--color-bg-dark-section);
}

.section-curve {
  display: block;
  width: 100%;
  height: 120px;
  margin-bottom: -1px;
}

.more-features {
  position: relative;
  padding: 120px 24px;
  overflow: hidden;
  background: var(--color-bg-dark-section);
  border-bottom: 1px solid rgba(255, 255, 255, 0.02);
}

.more-features-container {
  position: relative;
  z-index: 1;
  max-width: 1100px;
  margin: 0 auto;
}

.more-features-header {
  text-align: center;
  margin-bottom: 64px;
}

.more-features-title {
  font-size: 2.5rem;
  font-weight: 700;
  letter-spacing: -0.03em;
  margin-bottom: 16px;
  background: linear-gradient(
    90deg,
    rgba(255, 255, 255, 0.7) 0%,
    rgba(170, 175, 185, 0.6) 20%,
    rgba(255, 255, 255, 1) 40%,
    rgba(170, 175, 185, 0.6) 60%,
    rgba(255, 255, 255, 0.7) 80%,
    rgba(170, 175, 185, 0.6) 100%
  );
  background-size: 200% 100%;
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  animation: shimmer 8s ease-in-out infinite;
}

@keyframes shimmer {
  0%,
  90%,
  100% {
    background-position: 100% 0;
  }
  45%,
  55% {
    background-position: 0% 0;
  }
}

.more-features-subtitle {
  font-size: 1.125rem;
  color: rgba(255, 255, 255, 0.5);
  max-width: 500px;
  margin: 0 auto;
}

.more-features-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
}

@media (max-width: 900px) {
  .more-features {
    padding: 80px 20px;
  }

  .more-features-header {
    margin-bottom: 48px;
  }

  .more-features-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .more-features-title {
    font-size: 2rem;
  }
}

@media (max-width: 600px) {
  .more-features-grid {
    grid-template-columns: 1fr;
  }
}
</style>

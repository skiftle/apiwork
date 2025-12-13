<script setup lang="ts"></script>

<template>
  <section class="why-section">
    <div class="container">
      <h2 class="section-title">Why <span class="accent">Apiwork</span></h2>
      <div class="points-grid">
        <div class="point">
          <div class="icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <ellipse cx="12" cy="5" rx="9" ry="3" />
              <path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3" />
              <path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5" />
            </svg>
          </div>
          <h3>Your database stays the source of truth</h3>
          <p>Apiwork reads directly from ActiveRecord and the database, so you don't repeat field definitions, enums, or nullability.</p>
        </div>

        <div class="point">
          <div class="icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
              <line x1="3" y1="9" x2="21" y2="9" />
              <line x1="9" y1="21" x2="9" y2="9" />
            </svg>
          </div>
          <h3>Your API behavior is explicit by default</h3>
          <p>Requests, responses, errors, filtering, and pagination are defined in one place — not implied across controllers.</p>
        </div>

        <div class="point">
          <div class="icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
              <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
              <line x1="12" y1="22.08" x2="12" y2="12" />
            </svg>
          </div>
          <h3>No drift between backend and clients</h3>
          <p>Documentation, types, and validation are generated from the same contracts that run in production.</p>
        </div>

        <div class="point">
          <div class="icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="16 18 22 12 16 6" />
              <polyline points="8 6 2 12 8 18" />
            </svg>
          </div>
          <h3>Controllers focus on business logic</h3>
          <p>Unknown input never reaches your code. Controllers stay boring, predictable, and easy to reason about.</p>
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

<template>
  <section class="hero">
    <div class="hero-container">
      <h1 class="hero-title">
        The modern API layer for <span class="highlight">Rails</span>
      </h1>
      <p class="hero-tagline">
        Define your API <em>once</em> — consistency and type-safety everywhere
      </p>
      <div class="hero-actions">
        <a href="/guide/examples" class="btn btn-outline">Examples</a>
        <a href="/guide/getting-started/introduction" class="btn btn-primary">
          Getting Started
          <svg class="btn-icon" viewBox="0 0 20 20" fill="currentColor">
            <path
              fill-rule="evenodd"
              d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z"
              clip-rule="evenodd"
            />
          </svg>
        </a>
      </div>
    </div>
  </section>
</template>

<style scoped>
.hero {
  text-align: center;
  padding: var(--space-16) var(--space-6);
}

.hero-container {
  max-width: 800px;
  margin: 0 auto;
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 600;
  color: rgba(17, 24, 39, 0.94);
  line-height: 1.08;
  margin-bottom: var(--space-6);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.04), 0 4px 16px var(--color-brand-8),
    0 8px 40px rgba(252, 208, 208, 0.4);
}

.dark .hero-title {
  color: var(--color-text);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2), 0 4px 16px rgba(239, 68, 68, 0.12),
    0 8px 40px rgba(61, 32, 32, 0.5);
}

.hero-title .highlight {
  color: var(--color-brand-70);
}

.hero-tagline {
  font-size: 1.35rem;
  font-weight: 500;
  color: rgba(17, 24, 39, 0.75);
  letter-spacing: -0.01em;
  margin-bottom: var(--space-10);
}

.dark .hero-tagline {
  color: var(--color-text-muted);
}

.hero-tagline em {
  font-style: normal;
  color: var(--color-brand-70);
  font-weight: 600;
}

.hero-actions {
  display: flex;
  justify-content: center;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-6);
  font-size: var(--font-size-base);
  font-weight: 500;
  text-decoration: none;
  border-radius: 9999px;
  transition: all 200ms;
  cursor: pointer;
  user-select: none;
  min-width: 160px;
}

.btn-icon {
  width: 0.85em;
  height: 0.85em;
  transition: transform 200ms;
}

.btn:hover .btn-icon {
  transform: translateX(2px);
}

.btn-outline {
  background: rgba(255, 255, 255, 0.8);
  color: var(--color-text);
  box-shadow: 0 8px 18px 0 rgba(0, 0, 0, 0.06);
  border-radius: 20.5px;
}

.btn-outline:hover {
  background: rgba(255, 255, 255, 0.9);
  text-decoration: none;
  box-shadow: 0 12px 22px 0 rgba(0, 0, 0, 0.06);
  transform: translateY(-1px);
}

.btn-outline:active {
  transform: translateY(1px);
  box-shadow: 0 1px 1px rgba(0, 0, 0, 0.04);
}

.dark .btn-outline {
  background: rgba(255, 255, 255, 0.05);
  color: var(--color-text);
  border: 1px solid var(--color-border);
  box-shadow: 0 8px 18px 0 rgba(0, 0, 0, 0.2);
}

.dark .btn-outline:hover {
  background: rgba(255, 255, 255, 0.08);
  box-shadow: 0 12px 22px 0 rgba(0, 0, 0, 0.25);
}

.btn-primary {
  color: rgba(255, 255, 255, 0.9);
  background-color: var(--color-brand-70);
  box-shadow: 0 8px 18px 0 var(--color-brand-10);
  border-radius: 9999px;
}

.btn-primary:hover {
  text-decoration: none;
  box-shadow: 0 1px 2px var(--color-brand-10),
    0 4px 10px -2px var(--color-brand-18);
  transform: translateY(-1px);
}

.btn-primary:active {
  transform: translateY(1px);
  box-shadow: 0 1px 1px var(--color-brand-10);
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 2rem;
  }
}
</style>

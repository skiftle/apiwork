<template>
  <section class="hero">
    <div class="container">
      <h1 class="title">
        The modern API layer for <span class="highlight">Rails</span>
      </h1>
      <p class="tagline">
        Define your API <em>once</em> — consistency and type-safety everywhere
      </p>
      <div class="actions">
        <a href="/guide/examples" class="btn outline">Examples</a>
        <a href="/guide/getting-started/introduction" class="btn primary">
          Getting Started
          <svg class="icon" viewBox="0 0 20 20" fill="currentColor">
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

  .container {
    max-width: 800px;
    margin: 0 auto;
  }

  .title {
    font-size: 3.5rem;
    font-weight: 600;
    color: var(--color-text-strong);
    line-height: 1.08;
    margin-bottom: var(--space-6);
    text-shadow: 0 1px 2px var(--color-overlay-4), 0 4px 16px var(--color-brand-8),
      0 8px 40px var(--color-brand-15);
    animation: hero-fade-in 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;

    .dark & {
      color: var(--color-text);
      text-shadow: 0 1px 2px var(--color-overlay-20), 0 4px 16px var(--color-brand-10),
        0 8px 40px var(--color-brand-15);
    }

    .highlight {
      color: var(--color-brand-70);
    }

    @media (max-width: 768px) {
      font-size: 2rem;
    }
  }

  .tagline {
    font-size: 1.35rem;
    font-weight: 500;
    color: var(--color-text-body);
    letter-spacing: -0.01em;
    margin-bottom: var(--space-10);
    opacity: 0;
    animation: hero-fade-in 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.1s forwards;

    .dark & {
      color: var(--color-text-muted);
    }

    em {
      font-style: normal;
      color: var(--color-brand-70);
      font-weight: 600;
    }
  }

  .actions {
    display: flex;
    justify-content: center;
    gap: var(--space-4);
    flex-wrap: wrap;
    opacity: 0;
    animation: hero-fade-in 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.2s forwards;
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

    .icon {
      width: 0.85em;
      height: 0.85em;
      transition: transform 200ms;
    }

    &:hover .icon {
      transform: translateX(2px);
    }

    &.outline {
      background: rgba(255, 255, 255, 0.8);
      color: var(--color-text);
      box-shadow: 0 8px 18px 0 var(--color-overlay-6);
      border-radius: 20.5px;
      -webkit-backdrop-filter: blur(12px);
      backdrop-filter: blur(12px);

      &:hover {
        background: rgba(255, 255, 255, 0.9);
        text-decoration: none;
        box-shadow: 0 12px 22px 0 var(--color-overlay-6);
        transform: translateY(-1px);
      }

      &:active {
        transform: translateY(1px);
        box-shadow: 0 1px 1px var(--color-overlay-4);
      }

      .dark & {
        background: var(--color-dark-bg-subtle);
        color: var(--color-text);
        border: 1px solid var(--color-dark-border-subtle);
        box-shadow: 0 8px 18px 0 var(--color-overlay-20);

        &:hover {
          background: var(--color-dark-bg-elevated);
          box-shadow: 0 12px 22px 0 var(--color-overlay-25);
        }
      }
    }

    &.primary {
      color: var(--color-dark-text-primary);
      background-color: var(--color-brand-70);
      box-shadow: 0 8px 18px 0 var(--color-brand-10);
      -webkit-backdrop-filter: blur(12px);
      backdrop-filter: blur(12px);

      &:hover {
        text-decoration: none;
        box-shadow: 0 1px 2px var(--color-brand-10),
          0 4px 10px -2px var(--color-brand-18);
        transform: translateY(-1px);
      }

      &:active {
        transform: translateY(1px);
        box-shadow: 0 1px 1px var(--color-brand-10);
      }
    }
  }
}

@keyframes hero-fade-in {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>

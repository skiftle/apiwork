<script setup lang="ts">
// 404 Not Found page
</script>

<template>
  <div class="not-found">
    <div class="not-found-container">
      <h1 class="not-found-code">404</h1>
      <p class="not-found-title">Page Not Found</p>
      <p class="not-found-message">
        The page you're looking for doesn't exist or has been moved.
      </p>
      <a href="/" class="not-found-link">Go to Homepage</a>
    </div>
  </div>
</template>

<style scoped>
.not-found {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  text-align: center;
  padding: var(--space-8);
}

.not-found-container {
  max-width: 400px;
}

.not-found-code {
  font-size: 6rem;
  font-weight: 700;
  color: var(--color-text-light);
  margin-bottom: var(--space-4);
  line-height: 1;
}

.not-found-title {
  font-size: var(--font-size-2xl);
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: var(--space-2);
}

.not-found-message {
  font-size: var(--font-size-base);
  color: var(--color-text-muted);
  margin-bottom: var(--space-6);
}

.not-found-link {
  display: inline-block;
  padding: var(--space-3) var(--space-6);
  background: var(--color-brand-70);
  color: white;
  font-weight: 500;
  text-decoration: none;
  border-radius: var(--border-radius-lg);
  transition: background var(--transition-fast);
}

.not-found-link:hover {
  background: var(--color-brand-dark);
  text-decoration: none;
}
</style>

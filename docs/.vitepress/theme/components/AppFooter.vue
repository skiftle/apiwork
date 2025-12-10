<script setup lang="ts">
// TODO: Get footer config from themeConfig if needed
</script>

<template>
  <footer class="app-footer">
    <div class="footer-container">
      <p class="footer-message">Released under the MIT License.</p>
      <p class="footer-copyright">Copyright &copy; 2025 Skiftle</p>
    </div>
  </footer>
</template>

<style scoped>
.app-footer {
  border-top: 1px solid var(--color-border);
  background: var(--color-bg-soft);
}

.footer-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: var(--space-8) var(--space-6);
  text-align: center;
}

.footer-message {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  margin-bottom: var(--space-2);
}

.footer-copyright {
  font-size: var(--font-size-sm);
  color: var(--color-text-light);
  margin-bottom: 0;
}
</style>

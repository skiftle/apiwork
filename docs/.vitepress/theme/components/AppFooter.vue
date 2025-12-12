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
  background: var(--color-bg-dark-section);
}

.footer-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: var(--space-8) var(--space-6);
  text-align: center;
}

.footer-message {
  font-size: var(--font-size-sm);
  color: rgba(255, 255, 255, 0.7);
  margin-bottom: var(--space-2);
}

.footer-copyright {
  font-size: var(--font-size-sm);
  color: rgba(255, 255, 255, 0.5);
  margin-bottom: 0;
}
</style>

<script setup lang="ts">
</script>

<template>
  <footer class="app-footer">
    <div class="container">
      <p class="message">Released under the MIT License.</p>
      <p class="copyright">Copyright &copy; 2025 Skiftle</p>
    </div>
  </footer>
</template>

<style scoped>
.app-footer {
  background: var(--color-bg-dark-section);

  .container {
    max-width: 1400px;
    margin: 0 auto;
    padding: var(--space-8) var(--space-6);
    text-align: center;
  }

  .message {
    font-size: var(--font-size-sm);
    color: rgba(255, 255, 255, 0.7);
    margin-bottom: var(--space-2);
  }

  .copyright {
    font-size: var(--font-size-sm);
    color: rgba(255, 255, 255, 0.5);
    margin-bottom: 0;
  }
}
</style>

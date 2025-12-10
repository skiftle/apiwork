<script setup lang="ts">
import { useData } from 'vitepress'

const { isDark } = useData()

function toggle() {
  isDark.value = !isDark.value
}
</script>

<template>
  <button
    class="theme-switch"
    type="button"
    role="switch"
    :aria-checked="isDark"
    :title="isDark ? 'Switch to light theme' : 'Switch to dark theme'"
    @click="toggle"
  >
    <span class="switch-track">
      <span class="switch-thumb">
        <svg v-if="isDark" class="icon" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
        </svg>
        <svg v-else class="icon" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="5" />
          <line x1="12" y1="1" x2="12" y2="3" />
          <line x1="12" y1="21" x2="12" y2="23" />
          <line x1="4.22" y1="4.22" x2="5.64" y2="5.64" />
          <line x1="18.36" y1="18.36" x2="19.78" y2="19.78" />
          <line x1="1" y1="12" x2="3" y2="12" />
          <line x1="21" y1="12" x2="23" y2="12" />
          <line x1="4.22" y1="19.78" x2="5.64" y2="18.36" />
          <line x1="18.36" y1="5.64" x2="19.78" y2="4.22" />
        </svg>
      </span>
    </span>
  </button>
</template>

<style scoped>
.theme-switch {
  position: relative;
  display: flex;
  align-items: center;
  width: 40px;
  height: 22px;
  padding: 0;
  border: 1px solid var(--color-border);
  border-radius: 11px;
  background: var(--color-bg-soft);
  cursor: pointer;
  transition: border-color var(--transition-fast), background var(--transition-fast);
}

.theme-switch:hover {
  border-color: var(--color-brand);
}

.theme-switch:focus-visible {
  outline: 2px solid var(--color-brand);
  outline-offset: 2px;
}

.switch-track {
  position: relative;
  width: 100%;
  height: 100%;
}

.switch-thumb {
  position: absolute;
  top: 1px;
  left: 1px;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: var(--color-bg);
  box-shadow: var(--shadow-sm);
  transition: transform 0.25s ease;
}

.dark .switch-thumb {
  transform: translateX(18px);
}

.icon {
  color: var(--color-text-muted);
}
</style>

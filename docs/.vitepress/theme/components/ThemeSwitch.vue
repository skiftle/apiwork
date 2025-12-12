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
        <svg v-if="isDark" class="icon" viewBox="0 0 24 24" fill="currentColor">
          <path d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z" />
        </svg>
        <svg v-else class="icon" viewBox="0 0 24 24" fill="currentColor">
          <circle cx="12" cy="12" r="4" />
          <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41" stroke="currentColor" stroke-width="2" stroke-linecap="round" fill="none" />
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
  width: 52px;
  height: 28px;
  padding: 3px;
  border: none;
  border-radius: 14px;
  background: rgba(0, 0, 0, 0.12);
  cursor: pointer;
  transition: background 200ms;

  .dark & {
    background: rgba(255, 255, 255, 0.1);
  }

  &:hover {
    background: rgba(0, 0, 0, 0.16);

    .dark & {
      background: rgba(255, 255, 255, 0.14);
    }
  }

  &:focus-visible {
    outline: 2px solid var(--color-brand-70);
    outline-offset: 2px;
  }
}

.switch-track {
  position: relative;
  width: 100%;
  height: 100%;
}

.switch-thumb {
  position: absolute;
  top: 0;
  left: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
  transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1);

  .dark & {
    transform: translateX(24px);
  }
}

.icon {
  color: var(--color-text-muted);
  width: 14px;
  height: 14px;
}
</style>

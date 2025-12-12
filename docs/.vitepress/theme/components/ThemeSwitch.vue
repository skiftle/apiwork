<script setup lang="ts">
import { useData } from "vitepress";

const { isDark } = useData();

function toggle() {
  isDark.value = !isDark.value;
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
          <path
            d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z"
          />
        </svg>
        <svg v-else class="icon" viewBox="0 0 24 24" fill="currentColor">
          <circle cx="12" cy="12" r="5.5" />
          <rect x="10.75" y="1" width="2.5" height="4" rx="1.25" />
          <rect x="10.75" y="19" width="2.5" height="4" rx="1.25" />
          <rect x="1" y="10.75" width="4" height="2.5" rx="1.25" />
          <rect x="19" y="10.75" width="4" height="2.5" rx="1.25" />
          <rect
            x="17.5"
            y="4"
            width="2.5"
            height="4"
            rx="1.25"
            transform="rotate(45 18.75 6)"
          />
          <rect
            x="4"
            y="17.5"
            width="2.5"
            height="4"
            rx="1.25"
            transform="rotate(45 5.25 19.5)"
          />
          <rect
            x="17.5"
            y="17.5"
            width="2.5"
            height="4"
            rx="1.25"
            transform="rotate(-45 18.75 19.5)"
          />
          <rect
            x="4"
            y="4"
            width="2.5"
            height="4"
            rx="1.25"
            transform="rotate(-45 5.25 6)"
          />
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
  width: 44px;
  height: 24px;
  padding: 2px;
  border: none;
  border-radius: 12px;
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
    outline: 2px solid var(--color-brand-80);
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
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
  transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1);

  .dark & {
    transform: translateX(20px);
  }
}

.icon {
  color: #374151;
  width: 12px;
  height: 12px;
}
</style>

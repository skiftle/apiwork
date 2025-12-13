<script setup>
import { ref, onMounted, onUnmounted, nextTick } from "vue";

const props = defineProps({
  colors: {
    type: Array,
    default: null,
  },
  amplitude: {
    type: Number,
    default: 200,
  },
  speed: {
    type: Number,
    default: 1.0,
  },
});

const canvas = ref(null);
let gradient = null;
let themeObserver = null;

function getColors() {
  if (props.colors && props.colors.length >= 4) {
    return props.colors;
  }
  const style = getComputedStyle(document.documentElement);
  return [
    style.getPropertyValue("--gradient-color-1").trim() || "#fef7f7",
    style.getPropertyValue("--gradient-color-2").trim() || "#fde8e8",
    style.getPropertyValue("--gradient-color-3").trim() || "#fcd4d4",
    style.getPropertyValue("--gradient-color-4").trim() || "#fab5b5",
  ];
}

function handleThemeChange() {
  if (gradient && !props.colors) {
    gradient.updateColors(getColors());
  }
}

onMounted(async () => {
  // Wait for DOM to be ready
  await nextTick();

  // Only run on client (not SSR)
  if (typeof window === "undefined") return;

  // Dynamic import to avoid SSR issues
  const { Gradient } = await import("../lib/gradient");

  gradient = new Gradient({
    colors: getColors(),
    amplitude: props.amplitude,
    speed: props.speed,
  });

  // Small delay to ensure canvas has dimensions
  requestAnimationFrame(() => {
    gradient.initGradient(canvas.value);
  });

  // Watch for theme changes (VitePress toggles .dark class on html)
  themeObserver = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      if (mutation.attributeName === "class") {
        handleThemeChange();
      }
    }
  });
  themeObserver.observe(document.documentElement, { attributes: true });
});

onUnmounted(() => {
  gradient?.disconnect();
  themeObserver?.disconnect();
});
</script>

<template>
  <canvas ref="canvas" class="mesh-gradient" />
</template>

<style scoped>
.mesh-gradient {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  min-width: 1600px;
  height: 100%;
}
</style>

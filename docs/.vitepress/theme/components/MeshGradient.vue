<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'

const props = defineProps({
  colors: {
    type: Array,
    default: () => [
      '#fdf2f8', // very light pink (almost white)
      '#fce7f3', // light pink
      '#fbcfe8', // soft pink
      '#f9a8d4'  // medium pink
    ]
  },
  amplitude: {
    type: Number,
    default: 200
  },
  speed: {
    type: Number,
    default: 1.0
  }
})

const canvas = ref(null)
let gradient = null

onMounted(async () => {
  // Wait for DOM to be ready
  await nextTick()

  // Only run on client (not SSR)
  if (typeof window === 'undefined') return

  // Dynamic import to avoid SSR issues
  const { Gradient } = await import('../lib/gradient')

  gradient = new Gradient({
    colors: props.colors,
    amplitude: props.amplitude,
    speed: props.speed
  })

  // Small delay to ensure canvas has dimensions
  requestAnimationFrame(() => {
    gradient.initGradient(canvas.value)
  })
})

onUnmounted(() => {
  gradient?.disconnect()
})
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
  height: 100%;
}
</style>

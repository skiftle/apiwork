<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useData, useRoute } from 'vitepress'
import SidebarItem from './SidebarItem.vue'

interface SidebarItemData {
  text: string
  link?: string
  items?: SidebarItemData[]
  collapsed?: boolean
}

interface SidebarSection {
  base: string
  items: SidebarItemData[]
}

const { theme } = useData()
const route = useRoute()

// State for expanded sections
const expanded = ref<Set<string>>(new Set())

// Get the correct sidebar based on current path
const currentSidebar = computed<SidebarSection>(() => {
  const sidebar = theme.value.sidebar
  if (!sidebar) return { base: '', items: [] }

  for (const path of Object.keys(sidebar)) {
    if (route.path.startsWith(path)) {
      const section = sidebar[path]
      if (section && typeof section === 'object' && 'items' in section) {
        return {
          base: section.base || path,
          items: section.items || []
        }
      }
      if (Array.isArray(section)) {
        return { base: path, items: section }
      }
    }
  }

  return { base: '', items: [] }
})

function normalizeLink(link: string): string {
  let normalized = link.replace(/\.md$/, '')
  normalized = normalized.replace(/\/index$/, '/')
  if (normalized === 'index') normalized = ''
  return normalized
}

function buildLink(link: string | undefined): string {
  if (!link) return ''
  const normalized = normalizeLink(link)
  if (normalized.startsWith('/')) return normalized
  return currentSidebar.value.base + normalized
}

function isActive(link: string | undefined): boolean {
  if (!link) return false
  const fullLink = buildLink(link)
  const currentPath = route.path.replace(/\.html$/, '')
  const targetPath = fullLink.replace(/\.html$/, '')
  return currentPath === targetPath
}

// Check if an item or any of its descendants is active
function hasActiveDescendant(item: SidebarItemData): boolean {
  if (isActive(item.link)) return true
  if (item.items) {
    return item.items.some(child => hasActiveDescendant(child))
  }
  return false
}

// Initialize expanded state based on active page
function initializeExpanded() {
  const newExpanded = new Set<string>()

  function checkItem(item: SidebarItemData, depth: number, ancestors: string[]) {
    const key = `${depth}-${item.text}`

    if (item.items?.length) {
      const isActiveOrHasActive = hasActiveDescendant(item)

      if (isActiveOrHasActive) {
        newExpanded.add(key)
        ancestors.forEach(a => newExpanded.add(a))
      }

      for (const child of item.items) {
        checkItem(child, depth + 1, [...ancestors, key])
      }
    }
  }

  currentSidebar.value.items.forEach(item => checkItem(item, 0, []))
  expanded.value = newExpanded
}

// Toggle a section
function toggleSection(key: string) {
  const newExpanded = new Set(expanded.value)
  if (newExpanded.has(key)) {
    newExpanded.delete(key)
  } else {
    newExpanded.add(key)
  }
  expanded.value = newExpanded
}

// Watch for route changes to auto-expand
watch(() => route.path, initializeExpanded, { immediate: true })
</script>

<template>
  <aside class="sidebar">
    <nav class="sidebar-nav">
      <SidebarItem
        v-for="item in currentSidebar.items"
        :key="item.text"
        :item="item"
        :depth="0"
        :expanded="expanded"
        :build-link="buildLink"
        :is-active="isActive"
        @toggle="toggleSection"
      />
    </nav>
  </aside>
</template>

<style scoped>
.sidebar {
  position: sticky;
  top: var(--header-height);
  width: var(--sidebar-width);
  height: calc(100vh - var(--header-height));
  overflow-y: auto;
  padding: var(--space-6);
  border-right: 1px solid var(--color-border);
  background: var(--color-bg);
  flex-shrink: 0;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}
</style>

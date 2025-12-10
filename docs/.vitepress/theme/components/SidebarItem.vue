<script setup lang="ts">
import { computed } from 'vue'

interface SidebarItemData {
  text: string
  link?: string
  items?: SidebarItemData[]
  collapsed?: boolean
}

const props = defineProps<{
  item: SidebarItemData
  depth: number
  expanded: Set<string>
  buildLink: (link: string | undefined) => string
  isActive: (link: string | undefined) => boolean
}>()

const emit = defineEmits<{
  toggle: [key: string]
}>()

const itemKey = computed(() => `${props.depth}-${props.item.text}`)
const hasChildren = computed(() => props.item.items && props.item.items.length > 0)
const isExpanded = computed(() => props.expanded.has(itemKey.value))
const fullLink = computed(() => props.buildLink(props.item.link))
const isItemActive = computed(() => props.isActive(props.item.link))

function toggle() {
  emit('toggle', itemKey.value)
}

function onToggle(key: string) {
  emit('toggle', key)
}
</script>

<template>
  <div class="sidebar-item" :class="{ 'has-children': hasChildren }">
    <!-- Item with children: toggle bar -->
    <div
      v-if="hasChildren"
      class="sidebar-toggle"
      @click="toggle"
      @keydown.enter.space.prevent="toggle"
      tabindex="0"
      role="button"
      :aria-expanded="isExpanded"
    >
      <a
        v-if="item.link"
        :href="fullLink"
        class="sidebar-link"
        :class="{ active: isItemActive }"
        @click.stop
      >
        {{ item.text }}
      </a>
      <span v-else class="sidebar-heading">{{ item.text }}</span>
      <svg
        class="sidebar-chevron"
        :class="{ expanded: isExpanded }"
        width="16"
        height="16"
        viewBox="0 0 16 16"
        aria-hidden="true"
      >
        <path
          d="M6 4l4 4-4 4"
          fill="none"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
      </svg>
    </div>

    <!-- Item without children: just link -->
    <a
      v-else-if="item.link"
      :href="fullLink"
      class="sidebar-link"
      :class="{ active: isItemActive }"
    >
      {{ item.text }}
    </a>
    <span v-else class="sidebar-heading">{{ item.text }}</span>

    <!-- Children container -->
    <div
      v-if="hasChildren"
      class="sidebar-children"
      :class="isExpanded ? 'expanded' : 'collapsed'"
    >
      <SidebarItem
        v-for="child in item.items"
        :key="child.text"
        :item="child"
        :depth="depth + 1"
        :expanded="expanded"
        :build-link="buildLink"
        :is-active="isActive"
        @toggle="onToggle"
      />
    </div>
  </div>
</template>

<style scoped>
.sidebar-item {
  display: flex;
  flex-direction: column;
}

.sidebar-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
  cursor: pointer;
  user-select: none;
  padding: var(--space-1) var(--space-2);
  border-radius: var(--border-radius);
  transition: background var(--transition-fast);
}

.sidebar-toggle:hover {
  background: var(--color-bg-soft);
}

.sidebar-toggle:focus-visible {
  outline: 2px solid var(--color-brand);
  outline-offset: 2px;
}

.sidebar-chevron {
  flex-shrink: 0;
  color: var(--color-text-light);
  transition: transform 0.2s ease;
}

.sidebar-chevron.expanded {
  transform: rotate(90deg);
}

.sidebar-children {
  display: flex;
  flex-direction: column;
  padding-left: var(--space-4);
  overflow: hidden;
  transition: max-height 0.25s ease-out, opacity 0.2s ease-out;
}

.sidebar-children.collapsed {
  max-height: 0;
  opacity: 0;
  pointer-events: none;
}

.sidebar-children.expanded {
  max-height: 2000px;
  opacity: 1;
}

.sidebar-link {
  display: block;
  flex: 1;
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  text-decoration: none;
  padding: var(--space-1) var(--space-2);
  border-radius: var(--border-radius);
  transition: all var(--transition-fast);
}

.sidebar-toggle .sidebar-link {
  padding: 0;
}

.sidebar-link:hover {
  color: var(--color-text);
  text-decoration: none;
}

.sidebar-item:not(.has-children) .sidebar-link:hover {
  background: var(--color-bg-soft);
}

.sidebar-link.active {
  color: var(--color-brand);
  font-weight: 500;
}

.sidebar-item:not(.has-children) .sidebar-link.active {
  background: var(--color-bg-muted);
}

.sidebar-heading {
  flex: 1;
  font-size: var(--font-size-sm);
  font-weight: 600;
  color: var(--color-text);
}
</style>

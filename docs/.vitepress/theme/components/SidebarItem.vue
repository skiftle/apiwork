<script setup lang="ts">
import { computed } from "vue";
import type { SidebarItem } from "vitepress-sidebar/types";

const props = defineProps<{
  item: SidebarItem;
  depth: number;
  expanded: Set<string>;
  buildLink: (link: string | undefined) => string;
  isActive: (link: string | undefined) => boolean;
}>();

const emit = defineEmits<{
  toggle: [key: string];
}>();

const itemKey = computed(() => `${props.depth}-${props.item.text}`);
const hasChildren = computed(
  () => props.item.items && props.item.items.length > 0
);
const isExpanded = computed(() => props.expanded.has(itemKey.value));
const fullLink = computed(() => props.buildLink(props.item.link));
const isItemActive = computed(() => props.isActive(props.item.link));

function toggle() {
  emit("toggle", itemKey.value);
}

function onToggle(key: string) {
  emit("toggle", key);
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

/* Section heading (top-level groups) */
.sidebar-heading {
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-muted);
  padding: var(--space-3) var(--space-3) var(--space-1);
  margin-top: var(--space-4);
}

.sidebar-item:first-child .sidebar-heading {
  margin-top: 0;
}

/* Toggle row for expandable sections */
.sidebar-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
  cursor: pointer;
  user-select: none;
  padding: var(--space-2) var(--space-3);
  border-radius: var(--border-radius);
  transition: background 150ms;
}

.sidebar-toggle:hover {
  background: var(--color-bg-soft);
}

.sidebar-toggle:focus-visible {
  outline: 2px solid var(--color-brand-80);
  outline-offset: 2px;
}

/* Chevron */
.sidebar-chevron {
  width: 14px;
  height: 14px;
  flex-shrink: 0;
  color: var(--color-text-light);
  transition: transform 200ms cubic-bezier(0.16, 1, 0.3, 1);
}

.sidebar-chevron.expanded {
  transform: rotate(90deg);
}

/* Children container with guide line */
.sidebar-children {
  position: relative;
  display: flex;
  flex-direction: column;
  padding-left: var(--space-4);
  margin-left: var(--space-3);
  overflow: hidden;
  transition: max-height 250ms cubic-bezier(0.16, 1, 0.3, 1), opacity 200ms ease;

  /* Vertical guide line */
  &::before {
    content: "";
    position: absolute;
    left: 0;
    top: 4px;
    bottom: 4px;
    width: 1px;
    background: var(--color-border);
  }
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

/* Links */
.sidebar-link {
  position: relative;
  display: flex;
  align-items: center;
  flex: 1;
  font-size: var(--font-size-sm);
  font-weight: 500;
  color: var(--color-text-muted);
  text-decoration: none;
  padding: var(--space-2) var(--space-3);
  border-radius: var(--border-radius);
  transition: all 150ms;
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

/* Active state with left accent */
.sidebar-link.active {
  color: var(--color-brand-80);
  font-weight: 600;
}

.sidebar-item:not(.has-children) .sidebar-link.active {
  background: var(--color-bg-muted);

  &::before {
    content: "";
    position: absolute;
    left: 0;
    top: 6px;
    bottom: 6px;
    width: 2px;
    background: var(--color-brand-80);
    border-radius: 1px;
  }
}
</style>

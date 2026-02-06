<script setup lang="ts">
import { computed } from "vue";
import type { SidebarItem } from "vitepress-sidebar/types";

const props = defineProps<{
  item: SidebarItem;
  depth: number;
  expanded: Set<string>;
  buildLink: (link: string | undefined) => string;
  isActive: (link: string | undefined) => boolean;
  isReference?: boolean;
}>();

const emit = defineEmits<{
  toggle: [key: string];
}>();

const itemKey = computed(() => `${props.depth}-${props.item.text}`);
const hasChildren = computed(
  () => props.item.items && props.item.items.length > 0
);
const isTopLevel = computed(() => props.depth === 0);
const isExpanded = computed(() => props.expanded.has(itemKey.value));
const fullLink = computed(() => props.buildLink(props.item.link));
const isItemActive = computed(() => props.isActive(props.item.link));

// Check if any descendant is active
const hasActiveDescendant = computed(() => {
  if (!props.item.items?.length) return false;

  function checkItems(items: SidebarItem[]): boolean {
    for (const item of items) {
      if (props.isActive(item.link)) return true;
      if (item.items?.length && checkItems(item.items)) return true;
    }
    return false;
  }

  return checkItems(props.item.items);
});

// Icon mapping for top-level sections (guide only, not reference)
const sectionIcon = computed(() => {
  if (!isTopLevel.value) return null;
  const text = props.item.text?.toLowerCase() || "";
  if (text.includes("getting started")) return "rocket";
  if (text.includes("core")) return "cube";
  if (text.includes("example")) return "code";
  if (text.includes("advanced")) return "sparkles";
  return null;
});

// Recursively find the first leaf (page without children)
function findFirstLeafLink(item: SidebarItem): string | undefined {
  if (!item.items?.length) {
    return item.link;
  }
  return findFirstLeafLink(item.items[0]);
}

// For nested groups without a link, navigate to first leaf (guide only)
const firstChildLink = computed(() => {
  if (props.isReference) return undefined;
  if (props.item.link) return undefined;
  if (!props.item.items?.length) return undefined;

  const leafLink = findFirstLeafLink(props.item.items[0]);
  return leafLink ? props.buildLink(leafLink) : undefined;
});

// In reference, top-level items are collapsible
const isCollapsible = computed(() => !isTopLevel.value || props.isReference);

function toggle() {
  emit("toggle", itemKey.value);
}

function expand() {
  if (!isExpanded.value) {
    emit("toggle", itemKey.value);
  }
}

function onToggle(key: string) {
  emit("toggle", key);
}
</script>

<template>
  <div class="sidebar-item" :class="{ 'has-children': hasChildren, 'is-top-level': isTopLevel, 'has-icon': sectionIcon }">
    <!-- Item with children - collapsible -->
    <template v-if="hasChildren">
      <div
        class="sidebar-toggle"
        :class="{ 'no-toggle': !isCollapsible }"
        @click="isCollapsible && toggle()"
        @keydown.enter.space.prevent="isCollapsible && toggle()"
        :tabindex="isCollapsible ? 0 : -1"
        :role="isCollapsible ? 'button' : undefined"
        :aria-expanded="isCollapsible ? isExpanded : undefined"
      >
        <a
          :href="item.link ? fullLink : firstChildLink"
          class="sidebar-link"
          :class="{ active: isItemActive || hasActiveDescendant, 'sidebar-link-toggle': !item.link && isCollapsible }"
          @click.stop="item.link ? expand() : toggle()"
        >
          <!-- Section icons for top-level guide sections -->
          <svg v-if="sectionIcon === 'rocket'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z"/>
            <path d="m12 15-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z"/>
            <path d="M9 12H4s.55-3.03 2-4c1.62-1.08 5 0 5 0"/>
            <path d="M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5"/>
          </svg>
          <svg v-else-if="sectionIcon === 'cube'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="m21 16-9 5-9-5V8l9-5 9 5v8z"/>
            <path d="m3 8 9 5 9-5"/>
            <path d="M12 13v9"/>
          </svg>
          <svg v-else-if="sectionIcon === 'code'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="16 18 22 12 16 6"/>
            <polyline points="8 6 2 12 8 18"/>
          </svg>
          <svg v-else-if="sectionIcon === 'sparkles'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="m12 3-1.9 5.8a2 2 0 0 1-1.3 1.3L3 12l5.8 1.9a2 2 0 0 1 1.3 1.3L12 21l1.9-5.8a2 2 0 0 1 1.3-1.3L21 12l-5.8-1.9a2 2 0 0 1-1.3-1.3Z"/>
          </svg>
          {{ item.text }}
        </a>
        <svg
          v-if="isCollapsible"
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
      <div class="sidebar-children" :class="!isCollapsible || isExpanded ? 'expanded' : 'collapsed'">
        <SidebarItem
          v-for="child in item.items"
          :key="child.text"
          :item="child"
          :depth="depth + 1"
          :expanded="expanded"
          :build-link="buildLink"
          :is-active="isActive"
          :is-reference="isReference"
          @toggle="onToggle"
        />
      </div>
    </template>

    <!-- Leaf item - just link -->
    <template v-else>
      <a
        v-if="item.link"
        :href="fullLink"
        class="sidebar-link"
        :class="{ active: isItemActive }"
      >
        {{ item.text }}
      </a>
    </template>
  </div>
</template>

<style scoped>
.sidebar-item {
  display: flex;
  flex-direction: column;
}

/* Divider between top-level sections */
.sidebar-item.is-top-level + .sidebar-item.is-top-level {
  margin-top: var(--space-3);
  padding-top: var(--space-3);
  border-top: 1px solid var(--color-border);
}

/* Toggle row for expandable sections */
.sidebar-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
  cursor: pointer;
  user-select: none;
  padding: var(--space-1) 0;
  transition: color 150ms;
}

.sidebar-toggle:hover {
  color: var(--color-text);
}

.sidebar-toggle:focus-visible {
  outline: 2px solid var(--color-brand-80);
  outline-offset: 2px;
}

.sidebar-toggle.no-toggle {
  cursor: default;
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

/* Children container */
.sidebar-children {
  display: flex;
  flex-direction: column;
  padding-left: var(--space-4);
  overflow: hidden;
  transition: max-height 250ms cubic-bezier(0.16, 1, 0.3, 1), opacity 200ms ease;
}

/* Top-level children align with icon text (only when icon present) */
.sidebar-item.is-top-level.has-icon > .sidebar-children {
  padding-left: calc(16px + var(--space-2));
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
  display: flex;
  align-items: center;
  flex: 1;
  font-size: var(--font-size-sm);
  font-weight: 500;
  color: var(--color-text);
  text-decoration: none;
  padding: var(--space-1) 0;
  transition: color 150ms;
}

.sidebar-link:hover {
  color: var(--color-brand-80);
  text-decoration: none;
}

.sidebar-link-toggle {
  cursor: pointer;
}

/* Top-level links are bolder */
.sidebar-item.is-top-level > .sidebar-toggle .sidebar-link {
  font-weight: 600;
}

/* Section icons */
.sidebar-icon {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
  margin-right: var(--space-2);
  color: var(--color-brand-80);
}

/* Active state */
.sidebar-link.active {
  color: var(--color-brand-80);
  font-weight: 600;
}
</style>

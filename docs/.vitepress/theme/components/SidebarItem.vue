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
const isTopLevel = computed(() => props.depth === 0);
const isExpanded = computed(() => props.expanded.has(itemKey.value));
const fullLink = computed(() => props.buildLink(props.item.link));
const isItemActive = computed(() => props.isActive(props.item.link));

// Icon mapping for top-level sections
const sectionIcon = computed(() => {
  if (!isTopLevel.value) return null;
  const text = props.item.text?.toLowerCase() || "";
  if (text.includes("getting started")) return "rocket";
  if (text.includes("core")) return "cube";
  if (text.includes("example")) return "code";
  if (text.includes("advanced")) return "sparkles";
  if (text.includes("api")) return "server";
  if (text.includes("contract")) return "document";
  if (text.includes("schema")) return "grid";
  if (text.includes("adapter")) return "plug";
  if (text.includes("controller")) return "terminal";
  if (text.includes("introspection")) return "eye";
  if (text.includes("spec")) return "beaker";
  if (text.includes("config")) return "cog";
  if (text.includes("error")) return "warning";
  return "folder";
});

// Recursively find the first leaf (page without children)
function findFirstLeafLink(item: SidebarItem): string | undefined {
  if (!item.items?.length) {
    return item.link;
  }
  return findFirstLeafLink(item.items[0]);
}

// For nested groups without a link, navigate to first leaf
const firstChildLink = computed(() => {
  if (props.item.link) return undefined;
  if (!props.item.items?.length) return undefined;

  const leafLink = findFirstLeafLink(props.item.items[0]);
  return leafLink ? props.buildLink(leafLink) : undefined;
});

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
  <div class="sidebar-item" :class="{ 'has-children': hasChildren, 'is-top-level': isTopLevel }">
    <!-- Item with children - collapsible -->
    <template v-if="hasChildren">
      <div
        class="sidebar-toggle"
        @click="toggle"
        @keydown.enter.space.prevent="toggle"
        tabindex="0"
        role="button"
        :aria-expanded="isExpanded"
      >
        <a
          :href="item.link ? fullLink : firstChildLink"
          class="sidebar-link"
          :class="{ active: isItemActive }"
          @click.stop="expand"
        >
          <!-- Section icons for top-level -->
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
          <svg v-else-if="sectionIcon === 'server'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect width="20" height="8" x="2" y="2" rx="2" ry="2"/>
            <rect width="20" height="8" x="2" y="14" rx="2" ry="2"/>
            <line x1="6" x2="6.01" y1="6" y2="6"/>
            <line x1="6" x2="6.01" y1="18" y2="18"/>
          </svg>
          <svg v-else-if="sectionIcon === 'document'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
          </svg>
          <svg v-else-if="sectionIcon === 'grid'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect width="7" height="7" x="3" y="3" rx="1"/>
            <rect width="7" height="7" x="14" y="3" rx="1"/>
            <rect width="7" height="7" x="14" y="14" rx="1"/>
            <rect width="7" height="7" x="3" y="14" rx="1"/>
          </svg>
          <svg v-else-if="sectionIcon === 'plug'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 22v-5"/>
            <path d="M9 8V2"/>
            <path d="M15 8V2"/>
            <path d="M18 8v5a4 4 0 0 1-4 4h-4a4 4 0 0 1-4-4V8Z"/>
          </svg>
          <svg v-else-if="sectionIcon === 'terminal'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="4 17 10 11 4 5"/>
            <line x1="12" x2="20" y1="19" y2="19"/>
          </svg>
          <svg v-else-if="sectionIcon === 'eye'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/>
            <circle cx="12" cy="12" r="3"/>
          </svg>
          <svg v-else-if="sectionIcon === 'beaker'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M4.5 3h15"/>
            <path d="M6 3v16a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V3"/>
            <path d="M6 14h12"/>
          </svg>
          <svg v-else-if="sectionIcon === 'cog'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/>
            <circle cx="12" cy="12" r="3"/>
          </svg>
          <svg v-else-if="sectionIcon === 'warning'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/>
            <path d="M12 9v4"/>
            <path d="M12 17h.01"/>
          </svg>
          <svg v-else-if="sectionIcon === 'folder'" class="sidebar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"/>
          </svg>
          {{ item.text }}
        </a>
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
      <div class="sidebar-children" :class="isExpanded ? 'expanded' : 'collapsed'">
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

/* Top-level children align with icon text */
.sidebar-item.is-top-level > .sidebar-children {
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

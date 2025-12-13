<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { useData, useRoute } from "vitepress";
import type { SidebarItem, SidebarMultiItem } from "vitepress-sidebar/types";
import SidebarItemComponent from "./SidebarItem.vue";

const { theme } = useData();
const route = useRoute();

// State for expanded sections
const expanded = ref<Set<string>>(new Set());

// Get the correct sidebar based on current path
const currentSidebar = computed<SidebarMultiItem>(() => {
  const sidebar = theme.value.sidebar;
  if (!sidebar) return { base: "", items: [] };

  for (const path of Object.keys(sidebar)) {
    if (route.path.startsWith(path)) {
      const section = sidebar[path];
      if (section && typeof section === "object" && "items" in section) {
        return {
          base: section.base || path,
          items: section.items || [],
        };
      }
      if (Array.isArray(section)) {
        return { base: path, items: section };
      }
    }
  }

  return { base: "", items: [] };
});

function normalizeLink(link: string): string {
  let normalized = link.replace(/\.md$/, "");
  normalized = normalized.replace(/\/index$/, "/");
  if (normalized === "index") normalized = "";
  return normalized;
}

function buildLink(link: string | undefined): string {
  if (!link) return "";
  const normalized = normalizeLink(link);
  if (normalized.startsWith("/")) return normalized;
  return currentSidebar.value.base + normalized;
}

function isActive(link: string | undefined): boolean {
  if (!link) return false;
  const fullLink = buildLink(link);
  const currentPath = route.path.replace(/\.html$/, "");
  const targetPath = fullLink.replace(/\.html$/, "");
  return currentPath === targetPath;
}

// Check if an item or any of its descendants is active
function hasActiveDescendant(item: SidebarItem): boolean {
  if (isActive(item.link)) return true;
  if (item.items) {
    return item.items.some((child) => hasActiveDescendant(child));
  }
  return false;
}

// Initialize expanded state based on active page
function initializeExpanded() {
  const newExpanded = new Set<string>();

  function checkItem(item: SidebarItem, depth: number, ancestors: string[]) {
    const key = `${depth}-${item.text}`;

    if (item.items?.length) {
      const isActiveOrHasActive = hasActiveDescendant(item);

      if (isActiveOrHasActive) {
        newExpanded.add(key);
        ancestors.forEach((a) => newExpanded.add(a));
      }

      for (const child of item.items) {
        checkItem(child, depth + 1, [...ancestors, key]);
      }
    }
  }

  currentSidebar.value.items.forEach((item) => checkItem(item, 0, []));
  expanded.value = newExpanded;
}

// Toggle a section
function toggleSection(key: string) {
  const newExpanded = new Set(expanded.value);
  if (newExpanded.has(key)) {
    newExpanded.delete(key);
  } else {
    newExpanded.add(key);
  }
  expanded.value = newExpanded;
}

// Watch for route changes to auto-expand
watch(() => route.path, initializeExpanded, { immediate: true });
</script>

<template>
  <aside class="sidebar">
    <nav class="sidebar-nav">
      <SidebarItemComponent
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
  align-self: flex-start;
  width: var(--sidebar-width);
  height: calc(100vh - var(--header-height));
  overflow-y: auto;
  padding: var(--space-6) var(--space-4);
  background: var(--color-bg);
  flex-shrink: 0;
  box-shadow: 1px 0 0 var(--color-border);

  /* Custom scrollbar */
  &::-webkit-scrollbar {
    width: 6px;
  }

  &::-webkit-scrollbar-track {
    background: transparent;
  }

  &::-webkit-scrollbar-thumb {
    background: transparent;
    border-radius: 3px;
    transition: background 200ms;
  }

  &:hover::-webkit-scrollbar-thumb {
    background: var(--color-border);
  }

  &::-webkit-scrollbar-thumb:hover {
    background: var(--color-text-light);
  }
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}
</style>

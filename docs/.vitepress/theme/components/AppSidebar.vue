<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { useData, useRoute } from "vitepress";
import type { SidebarItem, SidebarMultiItem } from "vitepress-sidebar/types";
import SidebarItemComponent from "./SidebarItem.vue";

const { theme } = useData();
const route = useRoute();

// State for expanded sections
const expanded = ref<Set<string>>(new Set());
const initializedFromConfig = ref(false);

// Detect if we're in the reference section
const isReference = computed(() => route.path.startsWith("/reference"));

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

// Find keys that should be expanded for current active page
function findActiveKeys(): string[] {
  const keys: string[] = [];

  function checkItem(item: SidebarItem, depth: number, ancestors: string[]) {
    const key = `${depth}-${item.text}`;

    if (item.items?.length) {
      if (hasActiveDescendant(item)) {
        keys.push(key, ...ancestors);
      }

      for (const child of item.items) {
        checkItem(child, depth + 1, [...ancestors, key]);
      }
    }
  }

  currentSidebar.value.items.forEach((item) => checkItem(item, 0, []));
  return keys;
}

// Find keys that should be expanded based on collapsed config
function findExpandedFromConfig(): string[] {
  const keys: string[] = [];

  function checkItem(item: SidebarItem, depth: number) {
    const key = `${depth}-${item.text}`;

    if (item.items?.length) {
      // If collapsed is explicitly false, expand it
      if (item.collapsed === false) {
        keys.push(key);
      }

      for (const child of item.items) {
        checkItem(child, depth + 1);
      }
    }
  }

  currentSidebar.value.items.forEach((item) => checkItem(item, 0));
  return keys;
}

// Toggle a section
function toggleSection(key: string) {
  if (expanded.value.has(key)) {
    expanded.value.delete(key);
  } else {
    expanded.value.add(key);
  }
}

// Watch for sidebar changes to initialize from config
watch(
  currentSidebar,
  () => {
    if (!initializedFromConfig.value && currentSidebar.value.items.length > 0) {
      const configKeys = findExpandedFromConfig();
      configKeys.forEach((key) => expanded.value.add(key));
      initializedFromConfig.value = true;
    }
  },
  { immediate: true }
);

// Watch for route changes - expand active sections
watch(
  () => route.path,
  () => {
    const activeKeys = findActiveKeys();
    activeKeys.forEach((key) => expanded.value.add(key));
  },
  { immediate: true }
);
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
        :is-reference="isReference"
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
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}
</style>

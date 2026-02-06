<script setup lang="ts">
import { computed } from "vue";
import { useData, useRoute } from "vitepress";
import type { SidebarItem } from "vitepress-sidebar/types";

const { theme } = useData();
const route = useRoute();

interface BreadcrumbSegment {
  name: string;
  path: string;
  isLast: boolean;
}

function normalizeLink(link: string): string {
  return link
    .replace(/\.md$/, "")
    .replace(/\/index$/, "/")
    .replace(/\.html$/, "");
}

function buildFullLink(link: string, base: string): string {
  const normalized = normalizeLink(link);
  if (normalized.startsWith("/")) return normalized;
  return base + normalized;
}

// Find the path from root to current page in sidebar tree
function findBreadcrumbPath(
  items: SidebarItem[],
  targetPath: string,
  base: string,
  ancestors: BreadcrumbSegment[] = []
): BreadcrumbSegment[] | null {
  for (const item of items) {
    const itemPath = item.link ? buildFullLink(item.link, base) : null;
    const normalizedTarget = targetPath.replace(/\/$/, "");
    const normalizedItemPath = itemPath?.replace(/\/$/, "");

    // Check if this item matches
    if (normalizedItemPath === normalizedTarget) {
      return [
        ...ancestors,
        {
          name: item.text || "",
          path: itemPath || "",
          isLast: true,
        },
      ];
    }

    // Check children
    if (item.items?.length) {
      const currentSegment: BreadcrumbSegment = {
        name: item.text || "",
        path: itemPath || "",
        isLast: false,
      };

      const result = findBreadcrumbPath(
        item.items,
        targetPath,
        base,
        [...ancestors, currentSegment]
      );

      if (result) return result;
    }
  }

  return null;
}

const segments = computed<BreadcrumbSegment[]>(() => {
  const sidebar = theme.value.sidebar;
  if (!sidebar) return [];

  // Get reference sidebar
  const referenceSidebar = sidebar["/reference/"];
  if (!referenceSidebar) return [];

  const items = Array.isArray(referenceSidebar)
    ? referenceSidebar
    : referenceSidebar.items || [];

  const base = Array.isArray(referenceSidebar)
    ? "/reference/"
    : referenceSidebar.base || "/reference/";

  const currentPath = route.path.replace(/\.html$/, "");

  const path = findBreadcrumbPath(items, currentPath, base);
  return path || [];
});

const hasSegments = computed(() => segments.value.length > 0);
</script>

<template>
  <nav v-if="hasSegments" class="breadcrumb" aria-label="Module path">
    <ol class="breadcrumb-list">
      <template v-for="(segment, index) in segments" :key="segment.path">
        <li class="breadcrumb-item">
          <a
            v-if="!segment.isLast"
            :href="segment.path"
            class="breadcrumb-link"
          >
            {{ segment.name }}
          </a>
          <span v-else class="breadcrumb-current" aria-current="page">
            {{ segment.name }}
          </span>
        </li>
        <li v-if="!segment.isLast" class="breadcrumb-separator" aria-hidden="true">
          <svg class="separator-icon" viewBox="0 0 16 16" aria-hidden="true">
            <path d="M6 4l4 4-4 4" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
        </li>
      </template>
    </ol>
  </nav>
</template>

<style scoped>
.breadcrumb {
  margin-bottom: var(--space-4);
}

.breadcrumb-list {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 0;
  list-style: none;
  margin: 0;
  padding: 0;
  font-size: var(--font-size-xl);
  line-height: 1.4;
}

.breadcrumb-item {
  display: inline-flex;
  align-items: baseline;
}

.breadcrumb-separator {
  display: inline-flex;
  align-items: baseline;
}

.separator-icon {
  width: 14px;
  height: 14px;
  color: var(--color-text-light);
  margin: 0 var(--space-1);
  opacity: 0.5;
}

.breadcrumb-link {
  color: var(--color-brand-80);
  text-decoration: none;
}

.breadcrumb-link:hover {
  text-decoration: underline;
}

.breadcrumb-current {
  color: var(--color-text);
  font-weight: 500;
}
</style>

<script setup lang="ts">
import { computed } from "vue";
import { useData, useRoute } from "vitepress";
import type { SidebarItem } from "vitepress-sidebar/types";

interface FlatPage {
  title: string;
  link: string;
  section: string;
  subsection: string | null;
}

const { theme } = useData();
const route = useRoute();

const currentSidebar = computed(() => {
  const sidebar = theme.value.sidebar;
  if (!sidebar) return { base: "", items: [] };

  for (const path of Object.keys(sidebar)) {
    if (route.path.startsWith(path)) {
      const section = sidebar[path];
      if (section && typeof section === "object" && "items" in section) {
        return { base: section.base || path, items: section.items || [] };
      }
      if (Array.isArray(section)) {
        return { base: path, items: section };
      }
    }
  }
  return { base: "", items: [] };
});

function buildLink(link: string): string {
  let normalized = link.replace(/\.md$/, "").replace(/\/index$/, "/");
  if (normalized === "index") normalized = "";
  if (normalized.startsWith("/")) return normalized;
  return currentSidebar.value.base + normalized;
}

const flatPages = computed<FlatPage[]>(() => {
  const pages: FlatPage[] = [];

  function flatten(items: SidebarItem[], sectionName: string, subsectionName: string | null) {
    for (const item of items) {
      if (item.link) {
        pages.push({
          title: item.text || "",
          link: buildLink(item.link),
          section: sectionName,
          subsection: subsectionName,
        });
      }
      if (item.items?.length) {
        // This item becomes the subsection for its children
        flatten(item.items, sectionName, item.text || null);
      }
    }
  }

  for (const topLevel of currentSidebar.value.items) {
    if (topLevel.items?.length) {
      // Second level items are subsections
      for (const secondLevel of topLevel.items) {
        if (secondLevel.link) {
          pages.push({
            title: secondLevel.text || "",
            link: buildLink(secondLevel.link),
            section: topLevel.text || "",
            subsection: null,
          });
        }
        if (secondLevel.items?.length) {
          flatten(secondLevel.items, topLevel.text || "", secondLevel.text || null);
        }
      }
    }
  }

  return pages;
});

const currentIndex = computed(() => {
  const currentPath = route.path.replace(/\.html$/, "");
  return flatPages.value.findIndex((p) => p.link === currentPath);
});

const prev = computed(() => {
  if (currentIndex.value <= 0) return null;
  return flatPages.value[currentIndex.value - 1];
});

const next = computed(() => {
  if (currentIndex.value < 0 || currentIndex.value >= flatPages.value.length - 1) return null;
  return flatPages.value[currentIndex.value + 1];
});

const current = computed(() => {
  if (currentIndex.value < 0) return null;
  return flatPages.value[currentIndex.value];
});
</script>

<template>
  <nav v-if="prev || next" class="page-nav">
    <a v-if="prev" :href="prev.link" class="page-nav-link prev">
      <span class="page-nav-label">Previous</span>
      <span class="page-nav-section">
        {{ prev.section }}<template v-if="prev.subsection"> · {{ prev.subsection }}</template>
      </span>
      <span class="page-nav-title">
        <svg class="page-nav-arrow" width="16" height="16" viewBox="0 0 24 24">
          <path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        </svg>
        {{ prev.title }}
      </span>
    </a>
    <div v-else class="page-nav-spacer"></div>
    <a v-if="next" :href="next.link" class="page-nav-link next">
      <span class="page-nav-label">Next</span>
      <span class="page-nav-section">
        {{ next.section }}<template v-if="next.subsection"> · {{ next.subsection }}</template>
      </span>
      <span class="page-nav-title">
        {{ next.title }}
        <svg class="page-nav-arrow" width="16" height="16" viewBox="0 0 24 24">
          <path d="M9 6l6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        </svg>
      </span>
    </a>
  </nav>
</template>

<style scoped>
.page-nav {
  display: flex;
  justify-content: space-between;
  gap: var(--space-4);
  margin-top: var(--space-12);
  padding-top: var(--space-6);
  border-top: 1px solid var(--color-border);
}

.page-nav-spacer {
  flex: 1;
}

.page-nav-link {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
  padding: var(--space-3) var(--space-4);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  text-decoration: none;
  transition: border-color 150ms, background-color 150ms;
  max-width: 50%;
}

.page-nav-link:hover {
  border-color: var(--color-brand-80);
  background: var(--color-bg-soft);
}

.page-nav-link.prev {
  align-items: flex-start;
}

.page-nav-link.next {
  align-items: flex-end;
  margin-left: auto;
}

.page-nav-label {
  font-size: var(--font-size-xs);
  font-weight: 500;
  color: var(--color-text-light);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.page-nav-section {
  font-size: var(--font-size-xs);
  color: var(--color-brand-80);
  font-weight: 500;
}

.page-nav-title {
  display: flex;
  align-items: center;
  gap: var(--space-1);
  font-size: var(--font-size-sm);
  font-weight: 600;
  color: var(--color-text);
}

.page-nav-arrow {
  flex-shrink: 0;
  color: var(--color-text-light);
}

.page-nav-link:hover .page-nav-arrow {
  color: var(--color-brand-80);
}
</style>

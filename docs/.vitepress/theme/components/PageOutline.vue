<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from "vue";
import { useData, useRoute } from "vitepress";

const { page } = useData();
const route = useRoute();

const headers = computed(() => page.value.headers || []);
const hasOutline = computed(() => headers.value.length > 0);
const activeId = ref("");
const listWrapperRef = ref<HTMLElement | null>(null);

const indicatorStyle = ref({
  top: "0px",
  height: "0px",
  opacity: 0,
});

function getFirstHeaderId() {
  const first = headers.value[0];
  if (first?.link) return first.link.slice(1);
  return "";
}

function getLastHeaderId() {
  const flat: string[] = [];
  for (const h of headers.value) {
    if (h.link) flat.push(h.link.slice(1));
    if (h.children) {
      for (const c of h.children) {
        if (c.link) flat.push(c.link.slice(1));
      }
    }
  }
  return flat[flat.length - 1] || "";
}

function onScroll() {
  const scrollHeight = document.documentElement.scrollHeight;
  const scrollTop = window.scrollY;
  const clientHeight = window.innerHeight;

  // If near bottom of page, activate last header
  if (scrollTop + clientHeight >= scrollHeight - 50) {
    const lastId = getLastHeaderId();
    if (lastId && activeId.value !== lastId) {
      activeId.value = lastId;
    }
  }
}

function updateIndicator() {
  nextTick(() => {
    if (!listWrapperRef.value || !activeId.value) {
      indicatorStyle.value.opacity = 0;
      return;
    }

    const activeLink = listWrapperRef.value.querySelector(
      `a[href="#${activeId.value}"]`
    );
    if (!activeLink) {
      indicatorStyle.value.opacity = 0;
      return;
    }

    const wrapperRect = listWrapperRef.value.getBoundingClientRect();
    const linkRect = activeLink.getBoundingClientRect();

    indicatorStyle.value = {
      top: `${linkRect.top - wrapperRect.top}px`,
      height: `${linkRect.height}px`,
      opacity: 1,
    };
  });
}

let observer: IntersectionObserver | null = null;

function setupObserver() {
  observer?.disconnect();

  const headings = document.querySelectorAll("h2[id], h3[id]");
  if (!headings.length) return;

  // Set initial active to first header
  if (!activeId.value) {
    activeId.value = getFirstHeaderId();
    updateIndicator();
  }

  observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          activeId.value = entry.target.id;
          break;
        }
      }
    },
    { rootMargin: "-80px 0px -80% 0px" }
  );

  headings.forEach((h) => observer?.observe(h));
}

onMounted(() => {
  setupObserver();
  window.addEventListener("scroll", onScroll, { passive: true });
});

onUnmounted(() => {
  observer?.disconnect();
  window.removeEventListener("scroll", onScroll);
});

watch(activeId, updateIndicator);

watch(
  () => route.path,
  () => {
    activeId.value = "";
    indicatorStyle.value.opacity = 0;
    setTimeout(() => {
      activeId.value = getFirstHeaderId();
      setupObserver();
    }, 100);
  }
);

watch(headers, () => {
  if (headers.value.length && !activeId.value) {
    activeId.value = getFirstHeaderId();
    updateIndicator();
  }
});
</script>

<template>
  <aside v-if="hasOutline" class="page-outline">
    <nav>
      <h2 class="outline-title">On this page</h2>
      <div ref="listWrapperRef" class="outline-list-wrapper">
        <div
          class="outline-indicator"
          :style="{
            transform: `translateY(${indicatorStyle.top})`,
            height: indicatorStyle.height,
            opacity: indicatorStyle.opacity,
          }"
        />
        <ul class="outline-list">
          <li v-for="h in headers" :key="h.link">
            <a
              :href="h.link"
              class="outline-link"
              :class="{
                nested: h.level > 2,
                active: h.link === '#' + activeId,
              }"
            >
              {{ h.title }}
            </a>
            <ul v-if="h.children?.length" class="outline-children">
              <li v-for="child in h.children" :key="child.link">
                <a
                  :href="child.link"
                  class="outline-link nested"
                  :class="{ active: child.link === '#' + activeId }"
                >
                  {{ child.title }}
                </a>
              </li>
            </ul>
          </li>
        </ul>
      </div>
    </nav>
  </aside>
</template>

<style scoped>
.page-outline {
  position: sticky;
  top: calc(var(--header-height) + var(--space-6));
  width: 220px;
  max-height: calc(100vh - var(--header-height) - var(--space-12));
  overflow-y: auto;
  padding-left: var(--space-6);
  flex-shrink: 0;

  /* Custom scrollbar */
  &::-webkit-scrollbar {
    width: 4px;
  }

  &::-webkit-scrollbar-thumb {
    background: transparent;
    border-radius: 2px;
  }

  &:hover::-webkit-scrollbar-thumb {
    background: var(--color-border);
  }
}

.outline-title {
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-muted);
  margin-bottom: var(--space-3);
}

.outline-list-wrapper {
  position: relative;
}

.outline-indicator {
  position: absolute;
  left: 0;
  width: 2px;
  background: var(--color-brand-80);
  border-radius: 1px;
  transition: transform 200ms cubic-bezier(0.16, 1, 0.3, 1),
    height 200ms cubic-bezier(0.16, 1, 0.3, 1), opacity 150ms ease;
  z-index: 1;
}

.outline-list {
  position: relative;
  list-style: none;
  padding: 0;
  margin: 0;
  border-left: 1px solid var(--color-border);
}

.outline-children {
  list-style: none;
  padding: 0;
  margin: 0;
}

.outline-link {
  display: block;
  font-size: var(--font-size-sm);
  font-weight: 500;
  color: var(--color-text-muted);
  padding: var(--space-1) var(--space-4);
  text-decoration: none;
  transition: color 150ms;

  &:hover {
    color: var(--color-text);
    text-decoration: none;
  }

  &.nested {
    padding-left: var(--space-6);
    font-size: 0.8125rem;
  }

  &.active {
    color: var(--color-brand-80);
  }
}
</style>

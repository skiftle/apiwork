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

const HEADER_OFFSET = 100;

interface HeadingPosition {
  id: string;
  top: number;
}

const headingPositions = ref<HeadingPosition[]>([]);

function getFirstHeaderId() {
  const first = headers.value[0];
  if (first?.link) return first.link.slice(1);
  return "";
}

function getAbsoluteTop(element: HTMLElement): number {
  let top = 0;
  let el: HTMLElement | null = element;
  while (el) {
    top += el.offsetTop;
    el = el.offsetParent as HTMLElement | null;
  }
  return top;
}

function updateHeadingPositions() {
  const headings = document.querySelectorAll<HTMLElement>("h2[id], h3[id]");
  headingPositions.value = Array.from(headings).map((h) => ({
    id: h.id,
    top: getAbsoluteTop(h),
  }));
}

function onScroll() {
  const scrollTop = window.scrollY;
  const scrollHeight = document.documentElement.scrollHeight;
  const clientHeight = window.innerHeight;
  const positions = headingPositions.value;

  if (!positions.length) return;

  // Find heading closest to scroll position + offset
  let currentId = positions[0].id;
  for (const { id, top } of positions) {
    if (top <= scrollTop + HEADER_OFFSET) {
      currentId = id;
    } else {
      break;
    }
  }

  // At absolute bottom: activate last heading if not already reached naturally
  const isAtBottom = scrollTop + clientHeight >= scrollHeight - 10;
  if (isAtBottom) {
    const lastPosition = positions[positions.length - 1];
    if (lastPosition && lastPosition.top > scrollTop + HEADER_OFFSET) {
      currentId = lastPosition.id;
    }
  }

  activeId.value = currentId;
}

let scrollTimeout: number | null = null;
let clickedId: string | null = null;

function throttledScroll() {
  if (scrollTimeout) return;
  scrollTimeout = window.setTimeout(() => {
    // Skip scroll calculation if user just clicked a link
    if (clickedId) {
      activeId.value = clickedId;
      clickedId = null;
    } else {
      onScroll();
    }
    scrollTimeout = null;
  }, 50);
}

function onLinkClick(id: string) {
  clickedId = id;
  activeId.value = id;
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

onMounted(() => {
  updateHeadingPositions();
  window.addEventListener("scroll", throttledScroll, { passive: true });
  window.addEventListener("resize", updateHeadingPositions, { passive: true });
  onScroll();
});

onUnmounted(() => {
  window.removeEventListener("scroll", throttledScroll);
  window.removeEventListener("resize", updateHeadingPositions);
  if (scrollTimeout) clearTimeout(scrollTimeout);
});

watch(activeId, updateIndicator);

watch(
  () => route.path,
  () => {
    activeId.value = "";
    indicatorStyle.value.opacity = 0;
    setTimeout(() => {
      updateHeadingPositions();
      activeId.value = getFirstHeaderId();
      onScroll();
    }, 100);
  }
);

watch(headers, () => {
  if (headers.value.length && !activeId.value) {
    updateHeadingPositions();
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
              @click="onLinkClick(h.link.slice(1))"
            >
              {{ h.title }}
            </a>
            <ul v-if="h.children?.length" class="outline-children">
              <li v-for="child in h.children" :key="child.link">
                <a
                  :href="child.link"
                  class="outline-link nested"
                  :class="{ active: child.link === '#' + activeId }"
                  @click="onLinkClick(child.link.slice(1))"
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

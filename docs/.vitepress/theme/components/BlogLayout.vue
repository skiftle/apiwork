<script setup lang="ts">
import { Content, useData } from 'vitepress'

const { frontmatter } = useData()
</script>

<template>
  <div class="blog-layout">
    <article class="blog-content">
      <header v-if="frontmatter.title" class="blog-header">
        <h1 class="blog-title">{{ frontmatter.title }}</h1>
        <div v-if="frontmatter.date" class="blog-meta">
          <time :datetime="frontmatter.date">{{ frontmatter.date }}</time>
          <span v-if="frontmatter.author"> &middot; {{ frontmatter.author }}</span>
        </div>
      </header>

      <div class="blog-body">
        <Content />
      </div>
    </article>
  </div>
</template>

<style scoped>
.blog-layout {
  max-width: 800px;
  margin: 0 auto;
  padding: var(--space-8) var(--space-6) var(--space-16);
}

.blog-content {
  /* TODO: Style blog posts */
}

.blog-header {
  margin-bottom: var(--space-8);
  padding-bottom: var(--space-6);
  border-bottom: 1px solid var(--color-border);
}

.blog-title {
  font-size: var(--font-size-3xl);
  font-weight: 700;
  margin-bottom: var(--space-3);
}

.blog-meta {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
}

.blog-body {
  /* Prose styles applied via base.css */
}

/* TODO: Add blog post list view */
/* TODO: Add tags/categories */
</style>

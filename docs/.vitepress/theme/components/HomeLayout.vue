<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue'

let observer: IntersectionObserver | null = null

onMounted(() => {
  observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible')
        }
      })
    },
    { threshold: 0.1, rootMargin: '0px 0px -50px 0px' }
  )

  document.querySelectorAll('.animate-on-scroll').forEach((el) => {
    observer?.observe(el)
  })
})

onUnmounted(() => {
  observer?.disconnect()
})
</script>

<template>
  <div class="home-layout">
    <!-- Hero Section -->
    <section class="hero">
      <div class="hero-container">
        <h1 class="hero-title">
          The modern API layer for <span class="highlight">Rails</span>
        </h1>
        <p class="hero-tagline">
          Define your API <em>once</em> — consistency and type-safety everywhere
        </p>
        <div class="hero-actions">
          <a href="/guide/examples" class="btn btn-outline">Examples</a>
          <a href="/guide/getting-started/introduction" class="btn btn-primary"
            >Getting Started
            <svg class="btn-icon" viewBox="0 0 20 20" fill="currentColor">
              <path
                fill-rule="evenodd"
                d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z"
                clip-rule="evenodd"
              /></svg
          ></a>
        </div>
      </div>
    </section>

    <!-- Generators Section -->
    <section class="generators">
      <p class="generators-text">
        Built-in generators for
        <strong>OpenAPI</strong>, <strong>TypeScript</strong>, and
        <strong>Zod</strong>
      </p>
      <div class="generators-logos">
        <div class="logo-item">
          <svg viewBox="0 0 24 24" width="48" height="48" fill="#6BA539">
            <path
              d="M12 0C5.373 0 0 5.373 0 12s5.373 12 12 12 12-5.373 12-12S18.627 0 12 0zm-.281 4.323c.281-.052.52.152.52.434v14.487c0 .282-.239.486-.52.434-3.098-.576-5.453-3.318-5.453-6.619v-2.118c0-3.301 2.355-6.043 5.453-6.618zm1.062 0c3.098.575 5.453 3.317 5.453 6.618v2.118c0 3.301-2.355 6.043-5.453 6.619-.281.052-.52-.152-.52-.434V4.757c0-.282.239-.486.52-.434z"
            />
          </svg>
        </div>
        <div class="logo-item">
          <svg viewBox="0 0 24 24" width="48" height="48" fill="#3178C6">
            <path
              d="M1.125 0C.502 0 0 .502 0 1.125v21.75C0 23.498.502 24 1.125 24h21.75c.623 0 1.125-.502 1.125-1.125V1.125C24 .502 23.498 0 22.875 0zm17.363 9.75c.612 0 1.154.037 1.627.111a6.38 6.38 0 0 1 1.306.34v2.458a3.95 3.95 0 0 0-.643-.361 5.093 5.093 0 0 0-.717-.26 5.453 5.453 0 0 0-1.426-.2c-.3 0-.573.028-.819.086a2.1 2.1 0 0 0-.623.242c-.17.104-.3.229-.393.374a.888.888 0 0 0-.14.49c0 .196.053.373.156.529.104.156.252.304.443.444s.423.276.696.41c.273.135.582.274.926.416.47.197.892.407 1.266.628.374.222.695.473.963.753.268.279.472.598.614.957.142.359.214.776.214 1.253 0 .657-.125 1.21-.373 1.656a3.033 3.033 0 0 1-1.012 1.085 4.38 4.38 0 0 1-1.487.596c-.566.12-1.163.18-1.79.18a9.916 9.916 0 0 1-1.84-.164 5.544 5.544 0 0 1-1.512-.493v-2.63a5.033 5.033 0 0 0 3.237 1.2c.333 0 .624-.03.872-.09.249-.06.456-.144.623-.25.166-.108.29-.234.373-.38a1.023 1.023 0 0 0-.074-1.089 2.12 2.12 0 0 0-.537-.5 5.597 5.597 0 0 0-.807-.444 27.72 27.72 0 0 0-1.007-.436c-.918-.383-1.602-.852-2.053-1.405-.45-.553-.676-1.222-.676-2.005 0-.614.123-1.141.369-1.582.246-.441.58-.804 1.004-1.089a4.494 4.494 0 0 1 1.47-.629 7.536 7.536 0 0 1 1.77-.201zm-15.113.188h9.563v2.166H9.506v9.646H6.789v-9.646H3.375z"
            />
          </svg>
        </div>
        <div class="logo-item">
          <svg viewBox="0 0 24 24" width="48" height="48" fill="#3E67B1">
            <path
              d="M2.584 3.582a2.247 2.247 0 0 1 2.112-1.479h14.617c.948 0 1.794.595 2.115 1.487l2.44 6.777a2.248 2.248 0 0 1-.624 2.443l-9.61 8.52a2.247 2.247 0 0 1-2.963.018L.776 12.773a2.248 2.248 0 0 1-.64-2.467Zm12.038 4.887-9.11 5.537 5.74 5.007c.456.399 1.139.396 1.593-.006l5.643-5.001H14.4l6.239-3.957c.488-.328.69-.947.491-1.5l-1.24-3.446a1.535 1.535 0 0 0-1.456-1.015H5.545a1.535 1.535 0 0 0-1.431 1.01l-1.228 3.37z"
            />
          </svg>
        </div>
      </div>
    </section>

    <!-- Feature 1: Describe it once -->
    <section class="feature animate-on-scroll">
      <div class="feature-container">
        <div class="feature-content">
          <div class="feature-blob feature-blob--1"></div>
          <span class="feature-step">01</span>
          <h2 class="feature-title">
            <svg class="feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
              <polyline points="14 2 14 8 20 8"/>
              <line x1="16" y1="13" x2="8" y2="13"/>
              <line x1="16" y1="17" x2="8" y2="17"/>
              <polyline points="10 9 9 9 8 9"/>
            </svg>
            Describe it <span class="accent">once</span>
          </h2>
          <p class="feature-description">
            Apiwork starts with contracts. They let you describe the shapes,
            types, enums and structures your API uses in a clear and explicit
            way — all in one place.
          </p>
        </div>
        <div class="feature-code">
          <div class="code-window">
            <div class="code-window-header">
              <span class="code-window-dot code-window-dot--red"></span>
              <span class="code-window-dot code-window-dot--yellow"></span>
              <span class="code-window-dot code-window-dot--green"></span>
              <span class="code-window-filename">config/apis/invoices.rb</span>
            </div>
            <div class="code-window-body">
              <pre><code><span class="code-class">Apiwork</span>::<span class="code-class">API</span>.<span class="code-method">draw</span> <span class="code-string">'/api/v1'</span> <span class="code-keyword">do</span>
  key_format <span class="code-symbol">:camel</span>

  resources <span class="code-symbol">:invoices</span> <span class="code-keyword">do</span>
    member <span class="code-keyword">do</span>
      patch <span class="code-symbol">:archive</span>
    <span class="code-keyword">end</span>
  <span class="code-keyword">end</span>
<span class="code-keyword">end</span></code></pre>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Feature 2: Define your contract -->
    <section class="feature feature--alt animate-on-scroll">
      <div class="feature-container">
        <div class="feature-content">
          <div class="feature-blob feature-blob--2"></div>
          <span class="feature-step">02</span>
          <h2 class="feature-title">
            <svg class="feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
              <line x1="3" y1="9" x2="21" y2="9"/>
              <line x1="9" y1="21" x2="9" y2="9"/>
            </svg>
            Define your <span class="accent">contract</span>
          </h2>
          <p class="feature-description">
            Contracts describe your API's data structures with types,
            validations, and enums. They become the single source of truth for
            serialization, validation, and documentation.
          </p>
        </div>
        <div class="feature-code">
          <div class="code-window">
            <div class="code-window-header">
              <span class="code-window-dot code-window-dot--red"></span>
              <span class="code-window-dot code-window-dot--yellow"></span>
              <span class="code-window-dot code-window-dot--green"></span>
              <span class="code-window-filename"
                >app/contracts/invoice_contract.rb</span
              >
            </div>
            <div class="code-window-body">
              <pre><code><span class="code-keyword">class</span> <span class="code-class">InvoiceContract</span> < <span class="code-class">Apiwork</span>::<span class="code-class">Contract</span>
  attribute <span class="code-symbol">:id</span>, <span class="code-class">Integer</span>
  attribute <span class="code-symbol">:number</span>, <span class="code-class">String</span>
  attribute <span class="code-symbol">:amount</span>, <span class="code-class">BigDecimal</span>
  attribute <span class="code-symbol">:status</span>, <span class="code-class">String</span>, enum: <span class="code-symbol">%w[draft sent paid]</span>
  attribute <span class="code-symbol">:due_date</span>, <span class="code-class">Date</span>
<span class="code-keyword">end</span></code></pre>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Feature 3: Use it in your controller -->
    <section class="feature animate-on-scroll">
      <div class="feature-container">
        <div class="feature-content">
          <div class="feature-blob feature-blob--3"></div>
          <span class="feature-step">03</span>
          <h2 class="feature-title">
            <svg class="feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="16 18 22 12 16 6"/>
              <polyline points="8 6 2 12 8 18"/>
            </svg>
            Use it in your <span class="accent">controller</span>
          </h2>
          <p class="feature-description">
            Your controllers stay clean and focused. Apiwork handles
            serialization automatically based on your contract, transforming
            keys, formatting dates, and validating data.
          </p>
        </div>
        <div class="feature-code">
          <div class="code-window">
            <div class="code-window-header">
              <span class="code-window-dot code-window-dot--red"></span>
              <span class="code-window-dot code-window-dot--yellow"></span>
              <span class="code-window-dot code-window-dot--green"></span>
              <span class="code-window-filename"
                >app/controllers/invoices_controller.rb</span
              >
            </div>
            <div class="code-window-body">
              <pre><code><span class="code-keyword">class</span> <span class="code-class">InvoicesController</span> < <span class="code-class">ApplicationController</span>
  <span class="code-keyword">def</span> <span class="code-method">show</span>
    invoice = <span class="code-class">Invoice</span>.find(params[<span class="code-symbol">:id</span>])
    render_resource invoice
  <span class="code-keyword">end</span>

  <span class="code-keyword">def</span> <span class="code-method">create</span>
    invoice = <span class="code-class">Invoice</span>.create!(resource_params)
    render_resource invoice, status: <span class="code-symbol">:created</span>
  <span class="code-keyword">end</span>
<span class="code-keyword">end</span></code></pre>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Feature 4: Get consistent output -->
    <section class="feature feature--alt animate-on-scroll">
      <div class="feature-container feature-container--wide">
        <div class="feature-content feature-content--centered">
          <div class="feature-blob feature-blob--4"></div>
          <span class="feature-step">04</span>
          <h2 class="feature-title">
            <svg class="feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
              <polyline points="3.27 6.96 12 12.01 20.73 6.96"/>
              <line x1="12" y1="22.08" x2="12" y2="12"/>
            </svg>
            Get consistent <span class="accent">output</span> everywhere
          </h2>
          <p class="feature-description">
            From a single contract, Apiwork generates OpenAPI documentation,
            TypeScript types, and Zod schemas. Your frontend and backend always
            stay in sync.
          </p>
        </div>
        <div class="output-grid">
          <div class="code-window">
            <div class="code-window-header">
              <span class="code-window-dot code-window-dot--red"></span>
              <span class="code-window-dot code-window-dot--yellow"></span>
              <span class="code-window-dot code-window-dot--green"></span>
              <span class="code-window-filename">types.ts</span>
            </div>
            <div class="code-window-body">
              <pre><code><span class="code-keyword">interface</span> <span class="code-class">Invoice</span> {
  id: <span class="code-type">number</span>;
  number: <span class="code-type">string</span>;
  amount: <span class="code-type">string</span>;
  status: <span class="code-string">'draft'</span> | <span class="code-string">'sent'</span> | <span class="code-string">'paid'</span>;
  dueDate: <span class="code-type">string</span>;
}</code></pre>
            </div>
          </div>
          <div class="code-window">
            <div class="code-window-header">
              <span class="code-window-dot code-window-dot--red"></span>
              <span class="code-window-dot code-window-dot--yellow"></span>
              <span class="code-window-dot code-window-dot--green"></span>
              <span class="code-window-filename">schemas.ts</span>
            </div>
            <div class="code-window-body">
              <pre><code><span class="code-keyword">const</span> InvoiceSchema = z.object({
  id: z.number(),
  number: z.string(),
  amount: z.string(),
  status: z.enum([<span class="code-string">'draft'</span>, <span class="code-string">'sent'</span>, <span class="code-string">'paid'</span>]),
  dueDate: z.string(),
});</code></pre>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Transition to dark -->
    <div class="section-curve-wrapper">
      <svg class="section-curve" viewBox="0 0 1440 120" preserveAspectRatio="none">
        <path d="M0,120 C480,20 960,20 1440,120 L1440,120 L0,120 Z" fill="currentColor"/>
      </svg>
    </div>

    <!-- More Features Section -->
    <section class="more-features">
      <div class="more-features-container animate-on-scroll">
        <div class="more-features-header">
          <h2 class="more-features-title">And so much more</h2>
          <p class="more-features-subtitle">
            Everything you need to build production-ready APIs
          </p>
        </div>
        <div class="more-features-grid">
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/>
            </svg>
            <h3 class="more-feature-name">Rich Filtering</h3>
            <p class="more-feature-desc">
              Filter by any attribute with operators like eq, gt, lt, contains,
              between, and more.
            </p>
          </div>
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="12" y1="5" x2="12" y2="19"/>
              <polyline points="19 12 12 19 5 12"/>
            </svg>
            <h3 class="more-feature-name">Multi-field Sorting</h3>
            <p class="more-feature-desc">
              Sort by multiple fields with priority ordering and nested
              association support.
            </p>
          </div>
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
              <line x1="3" y1="9" x2="21" y2="9"/>
              <line x1="3" y1="15" x2="21" y2="15"/>
            </svg>
            <h3 class="more-feature-name">Offset Pagination</h3>
            <p class="more-feature-desc">
              Traditional page-based pagination with total counts and page
              metadata.
            </p>
          </div>
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="5" y1="12" x2="19" y2="12"/>
              <polyline points="12 5 19 12 12 19"/>
            </svg>
            <h3 class="more-feature-name">Cursor Pagination</h3>
            <p class="more-feature-desc">
              Efficient cursor-based pagination for large datasets without total
              counts.
            </p>
          </div>
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
            </svg>
            <h3 class="more-feature-name">Eager Loading</h3>
            <p class="more-feature-desc">
              Automatic N+1 query prevention with smart association preloading.
            </p>
          </div>
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="6" y1="3" x2="6" y2="15"/>
              <circle cx="18" cy="6" r="3"/>
              <circle cx="6" cy="18" r="3"/>
              <path d="M18 9a9 9 0 0 1-9 9"/>
            </svg>
            <h3 class="more-feature-name">STI Support</h3>
            <p class="more-feature-desc">
              Single Table Inheritance with automatic type inference and
              discriminated unions.
            </p>
          </div>
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="3" width="7" height="7"/>
              <rect x="14" y="3" width="7" height="7"/>
              <rect x="14" y="14" width="7" height="7"/>
              <rect x="3" y="14" width="7" height="7"/>
            </svg>
            <h3 class="more-feature-name">Polymorphic</h3>
            <p class="more-feature-desc">
              Full polymorphic association support with discriminated union type
              generation.
            </p>
          </div>
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/>
              <line x1="12" y1="11" x2="12" y2="17"/>
              <line x1="9" y1="14" x2="15" y2="14"/>
            </svg>
            <h3 class="more-feature-name">Nested Resources</h3>
            <p class="more-feature-desc">
              Deep association traversal with circular reference prevention.
            </p>
          </div>
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <line x1="2" y1="12" x2="22" y2="12"/>
              <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
            </svg>
            <h3 class="more-feature-name">i18n Ready</h3>
            <p class="more-feature-desc">
              Localized error messages, descriptions, and multi-language
              documentation.
            </p>
          </div>
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
              <line x1="12" y1="9" x2="12" y2="13"/>
              <line x1="12" y1="17" x2="12.01" y2="17"/>
            </svg>
            <h3 class="more-feature-name">Error Handling</h3>
            <p class="more-feature-desc">
              Structured, machine-readable errors with codes, paths, and
              detailed messages.
            </p>
          </div>
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="23 4 23 10 17 10"/>
              <polyline points="1 20 1 14 7 14"/>
              <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/>
            </svg>
            <h3 class="more-feature-name">Key Transform</h3>
            <p class="more-feature-desc">
              Automatic key case conversion between camelCase and snake_case.
            </p>
          </div>
          <div class="more-feature-card">
            <svg class="more-feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
              <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
            </svg>
            <h3 class="more-feature-name">Partial Updates</h3>
            <p class="more-feature-desc">
              PATCH operations with automatically generated partial types for
              updates.
            </p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.home-layout {
  min-height: calc(100vh - var(--header-height));
}

/* Hero Section */
.hero {
  text-align: center;
  padding: var(--space-16) var(--space-6);
}

.hero-container {
  max-width: 800px;
  margin: 0 auto;
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 600;
  color: rgba(17, 24, 39, 0.94);
  line-height: 1.08;
  margin-bottom: var(--space-6);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.04), 0 4px 16px var(--color-brand-8),
    0 8px 40px rgba(252, 208, 208, 0.4);
}

.dark .hero-title {
  color: rgba(248, 250, 252, 0.96);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2), 0 4px 16px rgba(239, 68, 68, 0.12),
    0 8px 40px rgba(61, 32, 32, 0.5);
}

.hero-title .highlight {
  color: var(--color-brand-70);
}

.hero-tagline {
  font-size: 1.35rem;
  font-weight: 500;
  color: rgba(17, 24, 39, 0.75);
  letter-spacing: -0.01em;
  margin-bottom: var(--space-10);
}

.dark .hero-tagline {
  color: rgba(248, 250, 252, 0.7);
}

.hero-tagline em {
  font-style: normal;
  color: var(--color-brand-70);
  font-weight: 600;
}

.hero-actions {
  display: flex;
  justify-content: center;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-6);
  font-size: var(--font-size-base);
  font-weight: 500;
  text-decoration: none;
  border-radius: 9999px;
  transition: all 200ms;
  cursor: pointer;
  user-select: none;
  min-width: 160px;
}

.btn-icon {
  width: 0.85em;
  height: 0.85em;
  transition: transform 200ms;
}

.btn:hover .btn-icon {
  transform: translateX(2px);
}

.btn-outline {
  background: rgba(255, 255, 255, 0.8);
  color: var(--color-text);
  background: rgba(255, 255, 255, 0.8);
  box-shadow: 0 8px 18px 0 rgba(0, 0, 0, 0.06);
  border-radius: 20.5px;
}

.btn-outline:hover {
  background: rgba(255, 255, 255, 0.9);
  text-decoration: none;
  box-shadow: 0 12px 22px 0 rgba(0, 0, 0, 0.06);
  transform: translateY(-1px);
}

.btn-outline:active {
  transform: translateY(1px);
  box-shadow: 0 1px 1px rgba(0, 0, 0, 0.04);
}

.dark .btn-outline {
  background: rgba(255, 255, 255, 0.05);
  color: var(--color-text);
  border: 1px solid var(--color-border);
  box-shadow: 0 8px 18px 0 rgba(0, 0, 0, 0.2);
}

.dark .btn-outline:hover {
  background: rgba(255, 255, 255, 0.08);
  box-shadow: 0 12px 22px 0 rgba(0, 0, 0, 0.25);
}

.btn-primary {
  color: rgba(255, 255, 255, 0.9);
  background-color: var(--color-brand-70);
  box-shadow: 0 8px 18px 0 var(--color-brand-10);
  border-radius: 9999px;
}

.btn-primary:hover {
  text-decoration: none;
  box-shadow: 0 1px 2px var(--color-brand-10),
    0 4px 10px -2px var(--color-brand-18);
  transform: translateY(-1px);
}

.btn-primary:active {
  transform: translateY(1px);
  box-shadow: 0 1px 1px var(--color-brand-10);
}

/* Generators Section */
.generators {
  text-align: center;
  padding: var(--space-8) var(--space-6) var(--space-16);
}

.generators-text {
  font-size: var(--font-size-xl);
  font-weight: 500;
  color: var(--color-text);
  margin-bottom: var(--space-10);
}

.generators-text strong {
  font-weight: 600;
  color: var(--color-brand-70);
}

.generators-logos {
  display: flex;
  justify-content: center;
  gap: var(--space-12);
  flex-wrap: wrap;
}

.logo-item {
  display: flex;
  align-items: center;
  transition: transform 200ms;
}

.logo-item:hover {
  transform: scale(1.1);
}

/* Feature Sections */
.feature {
  padding: 100px 24px;
  position: relative;
}

.feature--alt {
  background: linear-gradient(
    180deg,
    transparent 0%,
    rgba(254, 242, 242, 0.4) 50%,
    transparent 100%
  );
}

.dark .feature--alt {
  background: linear-gradient(
    180deg,
    transparent 0%,
    rgba(30, 20, 22, 0.5) 50%,
    transparent 100%
  );
}

.feature-container {
  display: grid;
  grid-template-columns: 1fr 1.3fr;
  gap: 64px;
  max-width: 1200px;
  margin: 0 auto;
  align-items: center;
}

.feature--alt .feature-container {
  direction: rtl;
}

.feature--alt .feature-container > * {
  direction: ltr;
}

.feature-container--wide {
  grid-template-columns: 1fr;
  max-width: 1000px;
}

.feature-container--wide .feature-content {
  text-align: center;
  margin-bottom: 48px;
}

.feature-content--centered {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.feature-content--centered .feature-description {
  text-align: center;
}

/* Decorative blobs */
.feature-blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(60px);
  opacity: 0.5;
  pointer-events: none;
  z-index: 0;
}

.feature-blob--1 {
  width: 200px;
  height: 200px;
  background: radial-gradient(circle, var(--color-brand-35) 0%, transparent 70%);
  top: -40px;
  left: -60px;
}

.feature-blob--2 {
  width: 180px;
  height: 180px;
  background: radial-gradient(circle, var(--color-brand-30) 0%, transparent 70%);
  top: -30px;
  left: -40px;
}

.feature-blob--3 {
  width: 220px;
  height: 220px;
  background: radial-gradient(circle, var(--color-brand-35) 0%, transparent 70%);
  top: -50px;
  left: -70px;
}

.feature-blob--4 {
  width: 160px;
  height: 160px;
  background: radial-gradient(circle, var(--color-brand-30) 0%, transparent 70%);
  top: -20px;
  left: 50%;
  transform: translateX(-50%);
}

/* Subtler decorative elements in dark mode */
.dark .feature-blob {
  opacity: 0.3;
}

.dark .feature-code::before,
.dark .feature-code::after {
  opacity: 0.5;
}

.feature-content {
  position: relative;
}

.feature-step {
  display: inline-block;
  font-size: 4rem;
  font-weight: 800;
  letter-spacing: -0.05em;
  background: linear-gradient(
    135deg,
    var(--color-brand-15) 0%,
    var(--color-brand-5) 100%
  );
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 16px;
  line-height: 1;
}

.feature-title {
  font-size: 2.25rem;
  font-weight: 700;
  color: var(--color-text);
  line-height: 1.15;
  letter-spacing: -0.03em;
  margin-top: 0;
  margin-bottom: 20px;
}

.feature-title .accent {
  color: var(--color-brand-70);
}

.feature-icon {
  width: 32px;
  height: 32px;
  color: var(--color-brand-70);
  margin-right: 12px;
  vertical-align: middle;
  margin-top: -4px;
}

.feature-description {
  font-size: 1.1rem;
  color: var(--color-text-muted);
  line-height: 1.7;
  max-width: 480px;
}

/* Code Window */
.feature-code {
  position: relative;
}

.feature-code::before {
  content: '';
  position: absolute;
  top: 20%;
  left: -10%;
  width: 50%;
  height: 60%;
  background: radial-gradient(ellipse, var(--color-brand-15) 0%, transparent 70%);
  filter: blur(40px);
  pointer-events: none;
  z-index: -1;
}

.feature-code::after {
  content: '';
  position: absolute;
  bottom: 10%;
  right: -5%;
  width: 40%;
  height: 50%;
  background: radial-gradient(ellipse, var(--color-brand-10) 0%, transparent 70%);
  filter: blur(50px);
  pointer-events: none;
  z-index: -1;
}

.code-window {
  border-radius: 12px;
  overflow: hidden;
  background: var(--color-code-bg);
  border: 1px solid var(--color-code-border);
  box-shadow:
    0 4px 6px rgba(0, 0, 0, 0.04),
    0 12px 28px rgba(0, 0, 0, 0.06),
    0 20px 48px rgba(0, 0, 0, 0.04),
    0 0 80px var(--color-brand-6);
  transition: transform 400ms cubic-bezier(0.16, 1, 0.3, 1),
    box-shadow 400ms cubic-bezier(0.16, 1, 0.3, 1);
}

.dark .code-window {
  border-color: transparent;
  box-shadow:
    0 4px 6px rgba(0, 0, 0, 0.15),
    0 12px 28px rgba(0, 0, 0, 0.2),
    0 20px 48px rgba(0, 0, 0, 0.15),
    0 0 80px var(--color-brand-6);
}

.code-window:hover {
  transform: translateY(-6px) scale(1.005);
  box-shadow:
    0 8px 16px rgba(0, 0, 0, 0.06),
    0 24px 48px rgba(0, 0, 0, 0.08),
    0 32px 64px rgba(0, 0, 0, 0.06),
    0 0 100px var(--color-brand-10);
}

.dark .code-window:hover {
  box-shadow:
    0 8px 16px rgba(0, 0, 0, 0.2),
    0 24px 48px rgba(0, 0, 0, 0.25),
    0 32px 64px rgba(0, 0, 0, 0.2),
    0 0 100px var(--color-brand-10);
}

.code-window-header {
  background: var(--color-code-header);
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 8px;
  border-bottom: 1px solid var(--color-code-header-border);
}

.code-window-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.code-window-dot--red {
  background: #ff5f57;
}

.code-window-dot--yellow {
  background: #febc2e;
}

.code-window-dot--green {
  background: #28c840;
}

.code-window-filename {
  margin-left: auto;
  font-size: 0.75rem;
  color: var(--color-code-filename);
  font-family: var(--font-mono);
}

.code-window-body {
  padding: 20px 24px;
}

.code-window-body pre {
  margin: 0;
  background: transparent;
  border: none;
  padding: 0;
}

.code-window-body code {
  font-family: var(--font-mono);
  font-size: 0.875rem;
  line-height: 1.7;
  color: var(--color-syntax-text);
}

/* Code syntax colors */
.code-class {
  color: var(--color-syntax-class);
}

.code-method {
  color: var(--color-syntax-method);
}

.code-string {
  color: var(--color-syntax-string);
}

.code-keyword {
  color: var(--color-syntax-keyword);
}

.code-symbol {
  color: var(--color-syntax-symbol);
}

.code-type {
  color: var(--color-syntax-type);
}

/* Output Grid */
.output-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

/* Section Curve */
.section-curve-wrapper {
  color: var(--color-bg-dark-section);
}

.section-curve {
  display: block;
  width: 100%;
  height: 120px;
  margin-bottom: -1px;
}

/* More Features Section */
.more-features {
  position: relative;
  padding: 120px 24px;
  overflow: hidden;
  background: var(--color-bg-dark-section);
  border-bottom: 1px solid rgba(255, 255, 255, 0.02);
}

.more-features-container {
  position: relative;
  z-index: 1;
  max-width: 1100px;
  margin: 0 auto;
}

.more-features-header {
  text-align: center;
  margin-bottom: 64px;
}

.more-features-title {
  font-size: 2.5rem;
  font-weight: 700;
  letter-spacing: -0.03em;
  margin-bottom: 16px;
  background: linear-gradient(
    90deg,
    rgba(255, 255, 255, 0.7) 0%,
    rgba(170, 175, 185, 0.6) 20%,
    rgba(255, 255, 255, 1) 40%,
    rgba(170, 175, 185, 0.6) 60%,
    rgba(255, 255, 255, 0.7) 80%,
    rgba(170, 175, 185, 0.6) 100%
  );
  background-size: 200% 100%;
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  animation: shimmer 8s ease-in-out infinite;
}

@keyframes shimmer {
  0%, 90%, 100% {
    background-position: 100% 0;
  }
  45%, 55% {
    background-position: 0% 0;
  }
}

.more-features-subtitle {
  font-size: 1.125rem;
  color: rgba(255, 255, 255, 0.5);
  max-width: 500px;
  margin: 0 auto;
}

.more-features-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
}

.more-feature-card {
  background: transparent;
  padding: 28px 24px;
  transition: background 300ms ease;
  border-right: 1px solid rgba(255, 255, 255, 0.02);
  border-bottom: 1px solid rgba(255, 255, 255, 0.02);
}

.more-feature-card:nth-child(4n) {
  border-right: none;
}

.more-feature-card:nth-last-child(-n+4) {
  border-bottom: none;
}

.more-feature-card:hover {
  background: rgba(255, 255, 255, 0.03);
}

.more-feature-icon {
  width: 20px;
  height: 20px;
  color: var(--color-brand-60);
  margin-bottom: 12px;
  stroke-width: 1.5;
}

.more-feature-name {
  font-size: 0.9375rem;
  font-weight: 600;
  margin-bottom: 10px;
  background: linear-gradient(
    135deg,
    rgba(255, 255, 255, 0.95) 0%,
    rgba(170, 175, 185, 0.85) 25%,
    rgba(255, 255, 255, 1) 50%,
    rgba(170, 175, 185, 0.85) 75%,
    rgba(255, 255, 255, 0.95) 100%
  );
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

.more-feature-desc {
  font-size: 0.8125rem;
  color: rgba(255, 255, 255, 0.4);
  line-height: 1.6;
  margin: 0;
}

/* Responsive */
@media (max-width: 900px) {
  .feature {
    padding: 64px 20px;
  }

  .feature-container {
    grid-template-columns: 1fr;
    gap: 40px;
  }

  .feature--alt .feature-container {
    direction: ltr;
  }

  .feature-title {
    font-size: 1.75rem;
  }

  .feature-description {
    font-size: 1rem;
  }

  .output-grid {
    grid-template-columns: 1fr;
  }

  .more-features {
    padding: 80px 20px;
  }

  .more-features-header {
    margin-bottom: 48px;
  }

  .more-features-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .more-feature-card:nth-child(4n) {
    border-right: 1px solid rgba(255, 255, 255, 0.02);
  }

  .more-feature-card:nth-child(2n) {
    border-right: none;
  }

  .more-feature-card:nth-last-child(-n+4) {
    border-bottom: 1px solid rgba(255, 255, 255, 0.02);
  }

  .more-feature-card:nth-last-child(-n+2) {
    border-bottom: none;
  }

  .more-features-title {
    font-size: 2rem;
  }

  .more-feature-card {
    padding: 24px 20px;
  }
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 2rem;
  }

  .generators-logos {
    gap: var(--space-8);
  }

  .code-window-body {
    padding: 16px;
  }

  .code-window-body code {
    font-size: 0.8rem;
  }
}

@media (max-width: 600px) {
  .more-features-grid {
    grid-template-columns: 1fr;
  }

  .more-feature-card:nth-child(2n),
  .more-feature-card:nth-child(4n) {
    border-right: none;
  }

  .more-feature-card:nth-last-child(-n+2),
  .more-feature-card:nth-last-child(-n+4) {
    border-bottom: 1px solid rgba(255, 255, 255, 0.02);
  }

  .more-feature-card:last-child {
    border-bottom: none;
  }
}

/* Scroll Animations */
.animate-on-scroll {
  opacity: 0;
  transform: translateY(40px);
  transition: opacity 0.8s cubic-bezier(0.16, 1, 0.3, 1),
              transform 0.8s cubic-bezier(0.16, 1, 0.3, 1);
}

.animate-on-scroll.is-visible {
  opacity: 1;
  transform: translateY(0);
}

.animate-on-scroll .feature-code {
  opacity: 0;
  transform: translateY(20px) scale(0.98);
  transition: opacity 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.2s,
              transform 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.2s;
}

.animate-on-scroll.is-visible .feature-code {
  opacity: 1;
  transform: translateY(0) scale(1);
}
</style>

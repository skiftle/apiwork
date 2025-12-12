<script setup lang="ts"></script>

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
    <section class="feature">
      <div class="feature-container">
        <div class="feature-content">
          <span class="feature-step">01</span>
          <h2 class="feature-title">
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
    <section class="feature feature--alt">
      <div class="feature-container">
        <div class="feature-content">
          <span class="feature-step">02</span>
          <h2 class="feature-title">
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
    <section class="feature">
      <div class="feature-container">
        <div class="feature-content">
          <span class="feature-step">03</span>
          <h2 class="feature-title">
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
    <section class="feature feature--alt">
      <div class="feature-container feature-container--wide">
        <div class="feature-content feature-content--centered">
          <span class="feature-step">04</span>
          <h2 class="feature-title">
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

    <!-- More Features Section -->
    <section class="more-features">
      <div class="more-features-container">
        <div class="more-features-header">
          <h2 class="more-features-title">And so much more</h2>
          <p class="more-features-subtitle">
            Everything you need to build production-ready APIs
          </p>
        </div>
        <div class="more-features-grid">
          <div class="more-feature-card">
            <h3 class="more-feature-name">Rich Filtering</h3>
            <p class="more-feature-desc">
              Filter by any attribute with operators like eq, gt, lt, contains,
              between, and more.
            </p>
          </div>
          <div class="more-feature-card">
            <h3 class="more-feature-name">Multi-field Sorting</h3>
            <p class="more-feature-desc">
              Sort by multiple fields with priority ordering and nested
              association support.
            </p>
          </div>
          <div class="more-feature-card">
            <h3 class="more-feature-name">Offset Pagination</h3>
            <p class="more-feature-desc">
              Traditional page-based pagination with total counts and page
              metadata.
            </p>
          </div>
          <div class="more-feature-card">
            <h3 class="more-feature-name">Cursor Pagination</h3>
            <p class="more-feature-desc">
              Efficient cursor-based pagination for large datasets without total
              counts.
            </p>
          </div>
          <div class="more-feature-card">
            <h3 class="more-feature-name">Eager Loading</h3>
            <p class="more-feature-desc">
              Automatic N+1 query prevention with smart association preloading.
            </p>
          </div>
          <div class="more-feature-card">
            <h3 class="more-feature-name">STI Support</h3>
            <p class="more-feature-desc">
              Single Table Inheritance with automatic type inference and
              discriminated unions.
            </p>
          </div>
          <div class="more-feature-card">
            <h3 class="more-feature-name">Polymorphic</h3>
            <p class="more-feature-desc">
              Full polymorphic association support with discriminated union type
              generation.
            </p>
          </div>
          <div class="more-feature-card">
            <h3 class="more-feature-name">Nested Resources</h3>
            <p class="more-feature-desc">
              Deep association traversal with circular reference prevention.
            </p>
          </div>
          <div class="more-feature-card">
            <h3 class="more-feature-name">i18n Ready</h3>
            <p class="more-feature-desc">
              Localized error messages, descriptions, and multi-language
              documentation.
            </p>
          </div>
          <div class="more-feature-card">
            <h3 class="more-feature-name">Error Handling</h3>
            <p class="more-feature-desc">
              Structured, machine-readable errors with codes, paths, and
              detailed messages.
            </p>
          </div>
          <div class="more-feature-card">
            <h3 class="more-feature-name">Key Transform</h3>
            <p class="more-feature-desc">
              Automatic key case conversion between camelCase and snake_case.
            </p>
          </div>
          <div class="more-feature-card">
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
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.04), 0 4px 16px rgba(185, 28, 28, 0.08),
    0 8px 40px rgba(252, 208, 208, 0.4);
}

.dark .hero-title {
  color: rgba(248, 250, 252, 0.96);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2), 0 4px 16px rgba(239, 68, 68, 0.12),
    0 8px 40px rgba(61, 32, 32, 0.5);
}

.hero-title .highlight {
  color: color-mix(in srgb, var(--color-brand) 80%, transparent 20%);
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
  color: var(--color-brand);
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

.btn-primary {
  color: rgba(255, 255, 255, 0.9);
  background-color: rgba(227, 15, 15, 0.8);
  box-shadow: 0 8px 18px 0 rgba(227, 15, 15, 0.1);
  border-radius: 9999px;
}

.btn-primary:hover {
  text-decoration: none;
  box-shadow: 0 1px 2px rgba(185, 28, 28, 0.1),
    0 4px 10px -2px rgba(185, 28, 28, 0.18);
  transform: translateY(-1px);
}

.btn-primary:active {
  transform: translateY(1px);
  box-shadow: 0 1px 1px rgba(185, 28, 28, 0.1);
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
  color: var(--color-brand);
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

.feature-step {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--color-brand);
  border: 2px solid var(--color-brand);
  border-radius: 50%;
  margin-bottom: 12px;
  opacity: 0.85;
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
  color: var(--color-brand);
}

.feature-description {
  font-size: 1.1rem;
  color: var(--color-text-muted);
  line-height: 1.7;
  max-width: 480px;
}

/* Code Window */
.code-window {
  border-radius: 12px;
  overflow: hidden;
  background: #1e1e1e;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.07), 0 12px 28px rgba(0, 0, 0, 0.12),
    0 20px 48px rgba(0, 0, 0, 0.08);
  transition: transform 400ms cubic-bezier(0.16, 1, 0.3, 1),
    box-shadow 400ms cubic-bezier(0.16, 1, 0.3, 1);
}

.code-window:hover {
  transform: translateY(-6px) scale(1.005);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1), 0 24px 48px rgba(0, 0, 0, 0.15),
    0 32px 64px rgba(0, 0, 0, 0.1);
}

.code-window-header {
  background: #2d2d2d;
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 8px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
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
  color: rgba(255, 255, 255, 0.35);
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
  color: #e2e8f0;
}

/* Code syntax colors */
.code-class {
  color: #fbbf24;
}

.code-method {
  color: #60a5fa;
}

.code-string {
  color: #a5d6a7;
}

.code-keyword {
  color: #f472b6;
}

.code-symbol {
  color: #7dd3fc;
}

.code-type {
  color: #7dd3fc;
}

/* Output Grid */
.output-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

/* More Features Section */
.more-features {
  position: relative;
  padding: 120px 24px;
  overflow: hidden;
  background: #131313;
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
  color: #fff;
  letter-spacing: -0.03em;
  margin-bottom: 16px;
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
  border-right: 1px solid rgba(255, 255, 255, 0.1);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
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

.more-feature-name {
  font-size: 0.9375rem;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.85);
  margin-bottom: 10px;
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
    border-right: 1px solid rgba(255, 255, 255, 0.1);
  }

  .more-feature-card:nth-child(2n) {
    border-right: none;
  }

  .more-feature-card:nth-last-child(-n+4) {
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
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
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }

  .more-feature-card:last-child {
    border-bottom: none;
  }
}
</style>

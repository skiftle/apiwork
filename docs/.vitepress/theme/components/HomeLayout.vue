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
          Define your API once and get consistency and type-safety everywhere
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
          <svg viewBox="0 0 24 24" width="64" height="64" fill="currentColor">
            <path
              d="M12 0C5.373 0 0 5.373 0 12s5.373 12 12 12 12-5.373 12-12S18.627 0 12 0zm-.281 4.323c.281-.052.52.152.52.434v14.487c0 .282-.239.486-.52.434-3.098-.576-5.453-3.318-5.453-6.619v-2.118c0-3.301 2.355-6.043 5.453-6.618zm1.062 0c3.098.575 5.453 3.317 5.453 6.618v2.118c0 3.301-2.355 6.043-5.453 6.619-.281.052-.52-.152-.52-.434V4.757c0-.282.239-.486.52-.434z"
            />
          </svg>
          <span>OpenAPI</span>
        </div>
        <div class="logo-item">
          <svg viewBox="0 0 24 24" width="64" height="64" fill="currentColor">
            <path
              d="M1.125 0C.502 0 0 .502 0 1.125v21.75C0 23.498.502 24 1.125 24h21.75c.623 0 1.125-.502 1.125-1.125V1.125C24 .502 23.498 0 22.875 0zm17.363 9.75c.612 0 1.154.037 1.627.111a6.38 6.38 0 0 1 1.306.34v2.458a3.95 3.95 0 0 0-.643-.361 5.093 5.093 0 0 0-.717-.26 5.453 5.453 0 0 0-1.426-.2c-.3 0-.573.028-.819.086a2.1 2.1 0 0 0-.623.242c-.17.104-.3.229-.393.374a.888.888 0 0 0-.14.49c0 .196.053.373.156.529.104.156.252.304.443.444s.423.276.696.41c.273.135.582.274.926.416.47.197.892.407 1.266.628.374.222.695.473.963.753.268.279.472.598.614.957.142.359.214.776.214 1.253 0 .657-.125 1.21-.373 1.656a3.033 3.033 0 0 1-1.012 1.085 4.38 4.38 0 0 1-1.487.596c-.566.12-1.163.18-1.79.18a9.916 9.916 0 0 1-1.84-.164 5.544 5.544 0 0 1-1.512-.493v-2.63a5.033 5.033 0 0 0 3.237 1.2c.333 0 .624-.03.872-.09.249-.06.456-.144.623-.25.166-.108.29-.234.373-.38a1.023 1.023 0 0 0-.074-1.089 2.12 2.12 0 0 0-.537-.5 5.597 5.597 0 0 0-.807-.444 27.72 27.72 0 0 0-1.007-.436c-.918-.383-1.602-.852-2.053-1.405-.45-.553-.676-1.222-.676-2.005 0-.614.123-1.141.369-1.582.246-.441.58-.804 1.004-1.089a4.494 4.494 0 0 1 1.47-.629 7.536 7.536 0 0 1 1.77-.201zm-15.113.188h9.563v2.166H9.506v9.646H6.789v-9.646H3.375z"
            />
          </svg>
          <span>TypeScript</span>
        </div>
        <div class="logo-item">
          <svg viewBox="0 0 24 24" width="64" height="64" fill="currentColor">
            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" />
          </svg>
          <span>Zod</span>
        </div>
      </div>
    </section>

    <!-- Code Showcase Section -->
    <section class="showcase">
      <div class="showcase-container">
        <div class="showcase-text">
          <h2 class="showcase-title">Describe it once</h2>
          <p class="showcase-description">
            Apiwork starts with contracts. They let you describe the shapes,
            types, enums and structures your API uses in a clear and explicit
            way — all in one place.
          </p>
        </div>
        <div class="showcase-code">
          <pre><code><span class="code-class">Apiwork</span>::<span class="code-class">API</span>.<span class="code-method">draw</span> <span class="code-string">'/eager_lion'</span> <span class="code-keyword">do</span>
  key_format <span class="code-symbol">:camel</span>

  resources <span class="code-symbol">:invoices</span> <span class="code-keyword">do</span>
    member <span class="code-keyword">do</span>
      patch <span class="code-symbol">:archive</span>
    <span class="code-keyword">end</span>
  <span class="code-keyword">end</span>
<span class="code-keyword">end</span></code></pre>
        </div>
      </div>
    </section>

    <!-- Contract Example Section -->
    <section class="example-section">
      <div class="example-container">
        <div class="example-code">
          <pre><code><span class="code-keyword">class</span> <span class="code-class">InvoiceContract</span> < <span class="code-class">Apiwork</span>::<span class="code-class">Contract</span>
  attribute <span class="code-symbol">:id</span>, <span class="code-class">Integer</span>
  attribute <span class="code-symbol">:number</span>, <span class="code-class">String</span>
  attribute <span class="code-symbol">:amount</span>, <span class="code-class">BigDecimal</span>
  attribute <span class="code-symbol">:status</span>, <span class="code-class">String</span>, enum: <span class="code-symbol">%w[draft sent paid]</span>
  attribute <span class="code-symbol">:due_date</span>, <span class="code-class">Date</span>
<span class="code-keyword">end</span></code></pre>
        </div>
        <div class="example-text">
          <h2 class="example-title">Define your contract</h2>
          <p class="example-description">
            Contracts describe your API's data structures with types,
            validations, and enums. They become the single source of truth for
            serialization, validation, and documentation.
          </p>
        </div>
      </div>
    </section>

    <!-- Controller Example Section -->
    <section class="example-section example-section--alt">
      <div class="example-container">
        <div class="example-text">
          <h2 class="example-title">Use it in your controller</h2>
          <p class="example-description">
            Your controllers stay clean and focused. Apiwork handles
            serialization automatically based on your contract, transforming
            keys, formatting dates, and validating data.
          </p>
        </div>
        <div class="example-code">
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
    </section>

    <!-- Output Section -->
    <section class="example-section">
      <div class="example-container example-container--wide">
        <div class="output-header">
          <h2 class="example-title">Get consistent output everywhere</h2>
          <p class="example-description">
            From a single contract, Apiwork generates OpenAPI documentation,
            TypeScript types, and Zod schemas. Your frontend and backend always
            stay in sync.
          </p>
        </div>
        <div class="output-grid">
          <div class="output-item">
            <span class="output-label">TypeScript</span>
            <pre><code><span class="code-keyword">interface</span> <span class="code-class">Invoice</span> {
  id: <span class="code-type">number</span>;
  number: <span class="code-type">string</span>;
  amount: <span class="code-type">string</span>;
  status: <span class="code-string">'draft'</span> | <span class="code-string">'sent'</span> | <span class="code-string">'paid'</span>;
  dueDate: <span class="code-type">string</span>;
}</code></pre>
          </div>
          <div class="output-item">
            <span class="output-label text-zod">Zod</span>
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
  letter-spacing: -0.04em;
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
  background: linear-gradient(
    90deg,
    var(--color-brand) 0%,
    var(--color-brand-light) 25%,
    var(--color-brand) 50%,
    var(--color-brand-light) 75%,
    var(--color-brand) 100%
  );
  background-size: 300% auto;
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  animation: shimmer 8s ease-in-out infinite;
  filter: drop-shadow(0 2px 8px rgba(185, 28, 28, 0.25));
}

.dark .hero-title .highlight {
  filter: drop-shadow(0 2px 12px rgba(239, 68, 68, 0.35));
}

@keyframes shimmer {
  0%,
  100% {
    background-position: 0% center;
  }
  50% {
    background-position: 100% center;
  }
}

.hero-tagline {
  font-size: var(--font-size-xl);
  font-weight: 500;
  color: var(--color-text-muted);
  margin-bottom: var(--space-10);
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
  gap: var(--space-2);
  padding: var(--space-2) var(--space-6);
  font-size: var(--font-size-base);
  font-weight: 500;
  text-decoration: none;
  border-radius: 9999px;
  transition: all 200ms;
  cursor: pointer;
  user-select: none;
}

.btn-icon {
  width: 1em;
  height: 1em;
  transition: transform 200ms;
}

.btn:hover .btn-icon {
  transform: translateX(3px);
}

.btn-outline {
  background: rgba(255, 255, 255, 0.9);
  color: var(--color-text);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04), 0 2px 12px -1px rgba(0, 0, 0, 0.06);
}

.btn-outline:hover {
  background: rgba(255, 255, 255, 1);
  text-decoration: none;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04), 0 2px 18px -1px rgba(0, 0, 0, 0.08);
  transform: translateY(-1px);
}

.btn-outline:active {
  transform: translateY(1px);
  box-shadow: 0 1px 1px rgba(0, 0, 0, 0.04);
}

.btn-primary {
  background: linear-gradient(
    90deg,
    var(--color-brand) 0%,
    var(--color-brand) 40%,
    #ff8a8a 50%,
    var(--color-brand) 60%,
    var(--color-brand) 100%
  );
  background-size: 400% auto;
  color: white;
  box-shadow: 0 1px 2px rgba(185, 28, 28, 0.1),
    0 2px 6px -1px rgba(185, 28, 28, 0.15);
  animation: shimmer 45s ease-in-out infinite;
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
  color: var(--color-text-muted);
  margin-bottom: var(--space-10);
}

.generators-logos {
  display: flex;
  justify-content: center;
  gap: var(--space-16);
  flex-wrap: wrap;
}

.logo-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
  color: var(--color-text);
  font-size: var(--font-size-sm);
  opacity: 0.7;
}

/* Code Showcase Section */
.showcase {
  padding: var(--space-16) var(--space-6);
  background: linear-gradient(
    135deg,
    rgba(255, 250, 250, 0.95) 0%,
    rgba(254, 242, 242, 0.8) 50%,
    rgba(254, 235, 235, 0.6) 100%
  );
}

.dark .showcase {
  background: linear-gradient(
    135deg,
    rgba(20, 14, 16, 0.95) 0%,
    rgba(28, 18, 20, 0.8) 50%,
    rgba(38, 22, 24, 0.6) 100%
  );
}

.showcase-container {
  display: grid;
  grid-template-columns: 1fr 1.5fr;
  gap: var(--space-12);
  max-width: 1100px;
  margin: 0 auto;
  align-items: center;
}

.showcase-title {
  font-size: var(--font-size-2xl);
  font-weight: 700;
  color: var(--color-text);
  margin-bottom: var(--space-4);
}

.showcase-description {
  font-size: var(--font-size-base);
  color: var(--color-text-muted);
  line-height: var(--line-height);
}

.showcase-code {
  background: rgba(31, 20, 24, 0.95);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: var(--border-radius-lg);
  padding: var(--space-6);
  overflow-x: auto;
  box-shadow: 0 4px 24px -4px rgba(185, 28, 28, 0.15);
}

.showcase-code pre {
  margin: 0;
  background: transparent;
  border: none;
  padding: 0;
}

.showcase-code code {
  font-family: var(--font-mono);
  font-size: var(--font-size-sm);
  line-height: 1.7;
  color: #e2e8f0;
}

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

/* Example Sections */
.example-section {
  padding: var(--space-16) var(--space-6);
}

.example-section--alt {
  background: linear-gradient(
    135deg,
    rgba(255, 252, 252, 0.9) 0%,
    rgba(255, 248, 248, 0.7) 50%,
    rgba(254, 244, 244, 0.5) 100%
  );
}

.dark .example-section--alt {
  background: linear-gradient(
    135deg,
    rgba(18, 12, 14, 0.9) 0%,
    rgba(24, 16, 18, 0.7) 50%,
    rgba(32, 20, 22, 0.5) 100%
  );
}

.example-container {
  display: grid;
  grid-template-columns: 1.5fr 1fr;
  gap: var(--space-12);
  max-width: 1100px;
  margin: 0 auto;
  align-items: center;
}

.example-container--wide {
  grid-template-columns: 1fr;
  max-width: 900px;
}

.example-title {
  font-size: var(--font-size-2xl);
  font-weight: 700;
  color: var(--color-text);
  margin-bottom: var(--space-4);
}

.example-description {
  font-size: var(--font-size-base);
  color: var(--color-text-muted);
  line-height: var(--line-height);
}

.example-code {
  background: rgba(31, 20, 24, 0.95);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: var(--border-radius-lg);
  padding: var(--space-6);
  overflow-x: auto;
  box-shadow: 0 4px 24px -4px rgba(185, 28, 28, 0.15);
}

.example-code pre {
  margin: 0;
  background: transparent;
  border: none;
  padding: 0;
}

.example-code code {
  font-family: var(--font-mono);
  font-size: var(--font-size-sm);
  line-height: 1.7;
  color: #e2e8f0;
}

/* Output Grid */
.output-header {
  text-align: center;
  margin-bottom: var(--space-10);
}

.output-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-6);
}

.output-item {
  background: rgba(31, 20, 24, 0.95);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: var(--border-radius-lg);
  padding: var(--space-6);
  overflow-x: auto;
  box-shadow: 0 4px 24px -4px rgba(185, 28, 28, 0.15);
}

.output-item pre {
  margin: 0;
  background: transparent;
  border: none;
  padding: 0;
}

.output-item code {
  font-family: var(--font-mono);
  font-size: var(--font-size-sm);
  line-height: 1.7;
  color: #e2e8f0;
}

.output-label {
  display: inline-block;
  font-size: var(--font-size-xs);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: var(--space-3);
}

.code-type {
  color: #7dd3fc;
}

/* Responsive */
@media (max-width: 768px) {
  .hero-title {
    font-size: 2rem;
  }

  .showcase-container {
    grid-template-columns: 1fr;
  }

  .example-container {
    grid-template-columns: 1fr;
  }

  .output-grid {
    grid-template-columns: 1fr;
  }

  .generators-logos {
    gap: var(--space-8);
  }
}
</style>

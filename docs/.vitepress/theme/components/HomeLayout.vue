<script setup lang="ts">
import { onMounted, onUnmounted } from "vue";
import CodeWindow from "./CodeWindow.vue";
import HeroSection from "./HeroSection.vue";
import GeneratorsSection from "./GeneratorsSection.vue";
import FeatureSection from "./FeatureSection.vue";
import MoreFeaturesSection from "./MoreFeaturesSection.vue";

let observer: IntersectionObserver | null = null;

onMounted(() => {
  observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
        }
      });
    },
    { threshold: 0.1, rootMargin: "0px 0px -50px 0px" }
  );

  document.querySelectorAll(".animate-on-scroll").forEach((el) => {
    observer?.observe(el);
  });
});

onUnmounted(() => {
  observer?.disconnect();
});
</script>

<template>
  <div class="home-layout">
    <HeroSection />
    <GeneratorsSection />

    <FeatureSection
      step="01"
      description="Apiwork starts with contracts. They let you describe the shapes, types, enums and structures your API uses in a clear and explicit way — all in one place."
      :blob-variant="1"
      class="animate-on-scroll"
    >
      <template #icon>
        <svg class="feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
          <polyline points="14 2 14 8 20 8" />
          <line x1="16" y1="13" x2="8" y2="13" />
          <line x1="16" y1="17" x2="8" y2="17" />
          <polyline points="10 9 9 9 8 9" />
        </svg>
      </template>
      <template #title>Describe it <span class="accent">once</span></template>
      <template #code>
        <CodeWindow filename="config/apis/invoices.rb">
          <pre><code><span class="code-class">Apiwork</span><span class="code-punctuation">::</span><span class="code-class">API</span><span class="code-punctuation">.</span><span class="code-function">draw</span> <span class="code-string">'/api/v1'</span> <span class="code-keyword">do</span>
  <span class="code-function">key_format</span> <span class="code-symbol">:camel</span>

  <span class="code-function">resources</span> <span class="code-symbol">:invoices</span> <span class="code-keyword">do</span>
    <span class="code-function">member</span> <span class="code-keyword">do</span>
      <span class="code-function">patch</span> <span class="code-symbol">:archive</span>
    <span class="code-keyword">end</span>
  <span class="code-keyword">end</span>
<span class="code-keyword">end</span></code></pre>
        </CodeWindow>
      </template>
    </FeatureSection>

    <FeatureSection
      step="02"
      description="Contracts describe your API's data structures with types, validations, and enums. They become the single source of truth for serialization, validation, and documentation."
      alt
      :blob-variant="2"
      class="animate-on-scroll"
    >
      <template #icon>
        <svg class="feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
          <line x1="3" y1="9" x2="21" y2="9" />
          <line x1="9" y1="21" x2="9" y2="9" />
        </svg>
      </template>
      <template #title>Define your <span class="accent">contract</span></template>
      <template #code>
        <CodeWindow filename="app/contracts/invoice_contract.rb">
          <pre><code><span class="code-keyword">class</span> <span class="code-class">InvoiceContract</span> <span class="code-punctuation">&lt;</span> <span class="code-class">Apiwork</span><span class="code-punctuation">::</span><span class="code-class">Contract</span>
  <span class="code-function">attribute</span> <span class="code-symbol">:id</span><span class="code-punctuation">,</span> <span class="code-class">Integer</span>
  <span class="code-function">attribute</span> <span class="code-symbol">:number</span><span class="code-punctuation">,</span> <span class="code-class">String</span>
  <span class="code-function">attribute</span> <span class="code-symbol">:amount</span><span class="code-punctuation">,</span> <span class="code-class">BigDecimal</span>
  <span class="code-function">attribute</span> <span class="code-symbol">:status</span><span class="code-punctuation">,</span> <span class="code-class">String</span><span class="code-punctuation">,</span> <span class="code-symbol">enum:</span> <span class="code-symbol">%w[draft sent paid]</span>
  <span class="code-function">attribute</span> <span class="code-symbol">:due_date</span><span class="code-punctuation">,</span> <span class="code-class">Date</span>
<span class="code-keyword">end</span></code></pre>
        </CodeWindow>
      </template>
    </FeatureSection>

    <FeatureSection
      step="03"
      description="Your controllers stay clean and focused. Apiwork handles serialization automatically based on your contract, transforming keys, formatting dates, and validating data."
      :blob-variant="3"
      class="animate-on-scroll"
    >
      <template #icon>
        <svg class="feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polyline points="16 18 22 12 16 6" />
          <polyline points="8 6 2 12 8 18" />
        </svg>
      </template>
      <template #title>Use it in your <span class="accent">controller</span></template>
      <template #code>
        <CodeWindow filename="app/controllers/invoices_controller.rb">
          <pre><code><span class="code-keyword">class</span> <span class="code-class">InvoicesController</span> <span class="code-punctuation">&lt;</span> <span class="code-class">ApplicationController</span>
  <span class="code-keyword">def</span> <span class="code-method">show</span>
    <span class="code-variable">invoice</span> <span class="code-punctuation">=</span> <span class="code-class">Invoice</span><span class="code-punctuation">.</span><span class="code-function">find</span><span class="code-punctuation">(</span><span class="code-variable">params</span><span class="code-punctuation">[</span><span class="code-symbol">:id</span><span class="code-punctuation">])</span>
    <span class="code-function">respond_with</span> <span class="code-variable">invoice</span>
  <span class="code-keyword">end</span>

  <span class="code-keyword">def</span> <span class="code-method">create</span>
    <span class="code-variable">invoice</span> <span class="code-punctuation">=</span> <span class="code-class">Invoice</span><span class="code-punctuation">.</span><span class="code-function">create!</span><span class="code-punctuation">(</span><span class="code-function">resource_params</span><span class="code-punctuation">)</span>
    <span class="code-function">respond_with</span> <span class="code-variable">invoice</span><span class="code-punctuation">,</span> <span class="code-symbol">status:</span> <span class="code-symbol">:created</span>
  <span class="code-keyword">end</span>
<span class="code-keyword">end</span></code></pre>
        </CodeWindow>
      </template>
    </FeatureSection>

    <FeatureSection
      step="04"
      description="From a single contract, Apiwork generates OpenAPI documentation, TypeScript types, and Zod schemas. Your frontend and backend always stay in sync."
      alt
      wide
      :blob-variant="4"
      class="animate-on-scroll"
    >
      <template #icon>
        <svg class="feature-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
          <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
          <line x1="12" y1="22.08" x2="12" y2="12" />
        </svg>
      </template>
      <template #title>Get consistent <span class="accent">output</span> everywhere</template>
      <template #code>
        <CodeWindow filename="types.ts">
          <pre><code><span class="code-keyword">interface</span> <span class="code-class">Invoice</span> <span class="code-punctuation">{</span>
  <span class="code-property">id</span><span class="code-punctuation">:</span> <span class="code-type">number</span><span class="code-punctuation">;</span>
  <span class="code-property">number</span><span class="code-punctuation">:</span> <span class="code-type">string</span><span class="code-punctuation">;</span>
  <span class="code-property">amount</span><span class="code-punctuation">:</span> <span class="code-type">string</span><span class="code-punctuation">;</span>
  <span class="code-property">status</span><span class="code-punctuation">:</span> <span class="code-string">'draft'</span> <span class="code-punctuation">|</span> <span class="code-string">'sent'</span> <span class="code-punctuation">|</span> <span class="code-string">'paid'</span><span class="code-punctuation">;</span>
  <span class="code-property">dueDate</span><span class="code-punctuation">:</span> <span class="code-type">string</span><span class="code-punctuation">;</span>
<span class="code-punctuation">}</span></code></pre>
        </CodeWindow>
        <CodeWindow filename="schemas.ts">
          <pre><code><span class="code-keyword">const</span> <span class="code-variable">InvoiceSchema</span> <span class="code-punctuation">=</span> <span class="code-variable">z</span><span class="code-punctuation">.</span><span class="code-function">object</span><span class="code-punctuation">({</span>
  <span class="code-property">id</span><span class="code-punctuation">:</span> <span class="code-variable">z</span><span class="code-punctuation">.</span><span class="code-function">number</span><span class="code-punctuation">(),</span>
  <span class="code-property">number</span><span class="code-punctuation">:</span> <span class="code-variable">z</span><span class="code-punctuation">.</span><span class="code-function">string</span><span class="code-punctuation">(),</span>
  <span class="code-property">amount</span><span class="code-punctuation">:</span> <span class="code-variable">z</span><span class="code-punctuation">.</span><span class="code-function">string</span><span class="code-punctuation">(),</span>
  <span class="code-property">status</span><span class="code-punctuation">:</span> <span class="code-variable">z</span><span class="code-punctuation">.</span><span class="code-function">enum</span><span class="code-punctuation">([</span><span class="code-string">'draft'</span><span class="code-punctuation">,</span> <span class="code-string">'sent'</span><span class="code-punctuation">,</span> <span class="code-string">'paid'</span><span class="code-punctuation">]),</span>
  <span class="code-property">dueDate</span><span class="code-punctuation">:</span> <span class="code-variable">z</span><span class="code-punctuation">.</span><span class="code-function">string</span><span class="code-punctuation">(),</span>
<span class="code-punctuation">});</span></code></pre>
        </CodeWindow>
      </template>
    </FeatureSection>

    <MoreFeaturesSection class="animate-on-scroll" />
  </div>
</template>

<style scoped>
.home-layout {
  min-height: calc(100vh - var(--header-height));

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

  .code-variable {
    color: var(--color-syntax-variable);
  }

  .code-function {
    color: var(--color-syntax-function);
  }

  .code-property {
    color: var(--color-syntax-property);
  }

  .code-number {
    color: var(--color-syntax-number);
  }

  .code-punctuation {
    color: var(--color-syntax-punctuation);
  }
}

.animate-on-scroll {
  opacity: 0;
  transform: translateY(40px);
  transition: opacity 0.8s cubic-bezier(0.16, 1, 0.3, 1),
    transform 0.8s cubic-bezier(0.16, 1, 0.3, 1);

  &.is-visible {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-on-scroll :deep(.code) {
  opacity: 0;
  transform: translateY(20px) scale(0.98);
  transition: opacity 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.2s,
    transform 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.2s;
}

.animate-on-scroll.is-visible :deep(.code) {
  opacity: 1;
  transform: translateY(0) scale(1);
}
</style>

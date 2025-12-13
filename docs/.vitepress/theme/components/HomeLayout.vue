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
      description="One declarative block defines your entire API surface. Resources, key format, routing — all in one place. Think routes.rb, but for your entire API layer."
      :blob-variant="1"
      class="animate-on-scroll"
    >
      <template #icon>
        <svg
          class="feature-icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <path
            d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"
          />
          <polyline points="14 2 14 8 20 8" />
          <line x1="16" y1="13" x2="8" y2="13" />
          <line x1="16" y1="17" x2="8" y2="17" />
          <polyline points="10 9 9 9 8 9" />
        </svg>
      </template>
      <template #title>Draw your <span class="accent">API</span></template>
      <template #code>
        <CodeWindow filename="config/apis/invoices.rb">
          <pre><code><span class="code-class">Apiwork</span><span class="code-punctuation">::</span><span class="code-class">API</span><span class="code-punctuation">.</span><span class="code-function">draw</span> <span class="code-string">'/api/v1'</span> <span class="code-keyword">do</span>
  <span class="code-function">key_format</span> <span class="code-symbol">:camel</span>

  <span class="code-function">resources</span> <span class="code-symbol">:invoices</span> <span class="code-keyword">do</span>
    <span class="code-function">resources</span> <span class="code-symbol">:payments</span>
  <span class="code-keyword">end</span>
<span class="code-keyword">end</span></code></pre>
        </CodeWindow>
      </template>
    </FeatureSection>

    <FeatureSection
      description="One definition validates requests, shapes responses, and generates documentation. The type system handles everything — dates, enums, nested objects, discriminated unions — and maps perfectly to every output format."
      alt
      :blob-variant="2"
      class="animate-on-scroll"
    >
      <template #icon>
        <svg
          class="feature-icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
          <line x1="3" y1="9" x2="21" y2="9" />
          <line x1="9" y1="21" x2="9" y2="9" />
        </svg>
      </template>
      <template #title
        >Define your <span class="accent">contracts</span></template
      >
      <template #code>
        <CodeWindow filename="app/contracts/invoice_contract.rb">
          <pre><code><span class="code-keyword">class</span> <span class="code-class">InvoiceContract</span> <span class="code-punctuation">&lt;</span> <span class="code-class">Apiwork</span><span class="code-punctuation">::</span><span class="code-class">Contract</span><span class="code-punctuation">::</span><span class="code-class">Base</span>
  <span class="code-function">enum</span> <span class="code-symbol">:status</span><span class="code-punctuation">,</span> <span class="code-symbol">values:</span> <span class="code-symbol">%i[draft sent due paid]</span>

  <span class="code-function">action</span> <span class="code-symbol">:index</span> <span class="code-keyword">do</span>
    <span class="code-function">request</span> <span class="code-keyword">do</span>
      <span class="code-function">query</span> <span class="code-keyword">do</span>
        <span class="code-function">param</span> <span class="code-symbol">:status</span><span class="code-punctuation">,</span> <span class="code-symbol">type:</span> <span class="code-symbol">:string</span><span class="code-punctuation">,</span> <span class="code-symbol">enum:</span> <span class="code-symbol">:status</span>
      <span class="code-keyword">end</span>
    <span class="code-keyword">end</span>

    <span class="code-function">response</span> <span class="code-keyword">do</span>
      <span class="code-function">body</span> <span class="code-keyword">do</span>
        <span class="code-function">param</span> <span class="code-symbol">:invoices</span><span class="code-punctuation">,</span> <span class="code-symbol">type:</span> <span class="code-symbol">:array</span> <span class="code-keyword">do</span>
          <span class="code-function">param</span> <span class="code-symbol">:id</span><span class="code-punctuation">,</span> <span class="code-symbol">type:</span> <span class="code-symbol">:uuid</span>
          <span class="code-function">param</span> <span class="code-symbol">:number</span><span class="code-punctuation">,</span> <span class="code-symbol">type:</span> <span class="code-symbol">:string</span>
          <span class="code-function">param</span> <span class="code-symbol">:status</span><span class="code-punctuation">,</span> <span class="code-symbol">type:</span> <span class="code-symbol">:string</span><span class="code-punctuation">,</span> <span class="code-symbol">enum:</span> <span class="code-symbol">:status</span>
        <span class="code-keyword">end</span>
      <span class="code-keyword">end</span>
    <span class="code-keyword">end</span>
  <span class="code-keyword">end</span>
<span class="code-keyword">end</span></code></pre>
        </CodeWindow>
      </template>
    </FeatureSection>

    <FeatureSection
      description="But why write contracts manually? Your database already knows. Column types, enums, nullability — inherited automatically. Apiwork handles filtering, sorting, and pagination. You just say what to expose."
      :blob-variant="3"
      class="animate-on-scroll"
    >
      <template #icon>
        <svg
          class="feature-icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <ellipse cx="12" cy="5" rx="9" ry="3" />
          <path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3" />
          <path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5" />
        </svg>
      </template>
      <template #title
        >Let your models <span class="accent">speak</span></template
      >
      <template #code>
        <div class="code-stack">
          <CodeWindow filename="app/schemas/invoice_schema.rb">
            <pre><code><span class="code-keyword">class</span> <span class="code-class">InvoiceSchema</span> <span class="code-punctuation">&lt;</span> <span class="code-class">Apiwork</span><span class="code-punctuation">::</span><span class="code-class">Schema</span><span class="code-punctuation">::</span><span class="code-class">Base</span>
  <span class="code-function">attribute</span> <span class="code-symbol">:id</span>
  <span class="code-function">attribute</span> <span class="code-symbol">:number</span><span class="code-punctuation">,</span> <span class="code-symbol">sortable:</span> <span class="code-keyword">true</span>
  <span class="code-function">attribute</span> <span class="code-symbol">:issued_on</span>
  <span class="code-function">attribute</span> <span class="code-symbol">:status</span><span class="code-punctuation">,</span> <span class="code-symbol">filterable:</span> <span class="code-keyword">true</span>

  <span class="code-function">belongs_to</span> <span class="code-symbol">:customer</span>
  <span class="code-function">has_many</span> <span class="code-symbol">:lines</span><span class="code-punctuation">,</span> <span class="code-symbol">writable:</span> <span class="code-keyword">true</span>
<span class="code-keyword">end</span></code></pre>
          </CodeWindow>
          <CodeWindow filename="app/contracts/invoice_contract.rb">
            <pre><code><span class="code-keyword">class</span> <span class="code-class">InvoiceContract</span> <span class="code-punctuation">&lt;</span> <span class="code-class">Apiwork</span><span class="code-punctuation">::</span><span class="code-class">Contract</span><span class="code-punctuation">::</span><span class="code-class">Base</span>
  <span class="code-function">schema!</span> <span class="code-comment"># That's it.</span>
<span class="code-keyword">end</span></code></pre>
          </CodeWindow>
        </div>
      </template>
    </FeatureSection>

    <FeatureSection
      description="Your controllers stay focused on what matters. Apiwork handles the boundaries — requests are validated before they reach you, responses serialized on the way out. Just use your params and respond with data."
      alt
      :blob-variant="4"
      class="animate-on-scroll"
    >
      <template #icon>
        <svg
          class="feature-icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <polyline points="16 18 22 12 16 6" />
          <polyline points="8 6 2 12 8 18" />
        </svg>
      </template>
      <template #title
        >Focus on <span class="accent">business logic</span></template
      >
      <template #code>
        <CodeWindow filename="app/controllers/invoices_controller.rb">
          <pre><code><span class="code-keyword">class</span> <span class="code-class">InvoicesController</span> <span class="code-punctuation">&lt;</span> <span class="code-class">ApplicationController</span>
  <span class="code-keyword">def</span> <span class="code-method">show</span>
    <span class="code-variable">invoice</span> <span class="code-punctuation">=</span> <span class="code-class">Invoice</span><span class="code-punctuation">.</span><span class="code-function">find</span><span class="code-punctuation">(</span><span class="code-variable">params</span><span class="code-punctuation">[</span><span class="code-symbol">:id</span><span class="code-punctuation">])</span>
    <span class="code-function">respond</span> <span class="code-variable">invoice</span>
  <span class="code-keyword">end</span>

  <span class="code-keyword">def</span> <span class="code-method">create</span>
    <span class="code-variable">invoice</span> <span class="code-punctuation">=</span> <span class="code-class">Invoice</span><span class="code-punctuation">.</span><span class="code-function">create</span><span class="code-punctuation">(</span><span class="code-variable">contract</span><span class="code-punctuation">.</span><span class="code-function">body</span><span class="code-punctuation">[</span><span class="code-symbol">:invoice</span><span class="code-punctuation">])</span>
    <span class="code-function">respond</span> <span class="code-variable">invoice</span>
  <span class="code-keyword">end</span>
<span class="code-keyword">end</span></code></pre>
        </CodeWindow>
      </template>
    </FeatureSection>

    <FeatureSection
      description="TypeScript types, Zod schemas, and OpenAPI specs — all generated from your contracts. When your API changes, your frontend types update automatically. They can never go stale."
      alt
      wide
      :blob-variant="1"
      class="animate-on-scroll"
    >
      <template #icon>
        <svg
          class="feature-icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <path
            d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"
          />
          <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
          <line x1="12" y1="22.08" x2="12" y2="12" />
        </svg>
      </template>
      <template #title
        >Zero <span class="accent">drift</span></template
      >
      <template #code>
        <CodeWindow filename="types.ts">
          <pre><code><span class="code-keyword">interface</span> <span class="code-class">Invoice</span> <span class="code-punctuation">{</span>
  <span class="code-property">id</span><span class="code-punctuation">:</span> <span class="code-type">string</span><span class="code-punctuation">;</span>
  <span class="code-property">number</span><span class="code-punctuation">:</span> <span class="code-type">string</span><span class="code-punctuation">;</span>
  <span class="code-property">amount</span><span class="code-punctuation">:</span> <span class="code-type">string</span><span class="code-punctuation">;</span>
  <span class="code-property">status</span><span class="code-punctuation">:</span> <span class="code-string">'draft'</span> <span class="code-punctuation">|</span> <span class="code-string">'sent'</span> <span class="code-punctuation">|</span> <span class="code-string">'paid'</span><span class="code-punctuation">;</span>
  <span class="code-property">dueDate</span><span class="code-punctuation">:</span> <span class="code-type">string</span><span class="code-punctuation">;</span>
<span class="code-punctuation">}</span></code></pre>
        </CodeWindow>
        <CodeWindow filename="schemas.ts">
          <pre><code><span class="code-keyword">const</span> <span class="code-variable">InvoiceSchema</span> <span class="code-punctuation">=</span> <span class="code-variable">z</span><span class="code-punctuation">.</span><span class="code-function">object</span><span class="code-punctuation">({</span>
  <span class="code-property">id</span><span class="code-punctuation">:</span> <span class="code-variable">z</span><span class="code-punctuation">.</span><span class="code-function">string</span><span class="code-punctuation">().</span><span class="code-function">uuid</span><span class="code-punctuation">(),</span>
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
    color: var(--shiki-token-constant);
  }

  .code-method {
    color: var(--shiki-token-function);
  }

  .code-string {
    color: var(--shiki-token-string);
  }

  .code-keyword {
    color: var(--shiki-token-keyword);
  }

  .code-symbol {
    color: var(--shiki-token-parameter);
  }

  .code-type {
    color: var(--shiki-token-keyword);
  }

  .code-variable {
    color: var(--shiki-token-function);
  }

  .code-function {
    color: var(--shiki-token-function);
  }

  .code-property {
    color: var(--shiki-token-constant);
  }

  .code-number {
    color: var(--shiki-token-constant);
  }

  .code-punctuation {
    color: var(--shiki-token-punctuation);
  }

  .code-comment {
    color: var(--shiki-token-comment);
  }
}

.code-stack {
  display: flex;
  flex-direction: column;
  gap: 32px;
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

---
layout: home

hero:
  name: "Apiwork"
  text: "A Contract-Driven API Layer for Rails"
  tagline: "Bring clarity to your API without changing how you write Rails."
  actions:
    - theme: brand
      text: Getting Started
      link: /getting-started/introduction
    - theme: alt
      text: Type System
      link: /type-system/introduction

features:
  - icon: 🧾
    title: Describe it once.
    details: >
      Apiwork starts with contracts. They let you describe the shapes, types, enums and structures
      your API uses in a clear and explicit way — all in one place.

  - icon: 🌱
    title: We reuse what Rails already gives us. You only specify the rest.
    details: >
      Apiwork reads from Active Record and your database to pick up as much information as possible:
      attributes, types, relationships and defaults. You only define what your API should expose or
      override. Everything else is inherited automatically.

  - icon: ⚙️
    title: A runtime that handles the heavy lifting.
    details: >
      If you add schemas, they give adapters clear instructions. The built-in adapter supports
      advanced filtering, sorting, pagination and efficient loading — all without extra code in
      your controllers.

  - icon: 🧬
    title: One source, used everywhere.
    details: >
      Apiwork can generate OpenAPI, TypeScript and Zod definitions based on everything it knows
      about your API. You can use them for client generation, validation or documentation, and
      they follow Rails' i18n when you need localized messages.

  - icon: 🚨
    title: Consistent errors, everywhere.
    details: >
      Validation problems, contract mismatches and HTTP errors all use the same simple format.
      Easier to debug, easier to read and easier for clients to rely on.

  - icon: 🧩
    title: One system instead of many gems.
    details: >
      Things that usually require several libraries — filtering, pagination, validation,
      documentation — come built into Apiwork and work together naturally.

  - icon: ❤️
    title: Rails stays Rails.
    details: >
      You keep working in Rails the way you always have. Apiwork doesn't change your models or
      your workflow — it just adds a clear API layer on top when you need one.
---

---

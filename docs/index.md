---
layout: home

hero:
  name: Apiwork
  text: Typed APIs for Rails
  tagline: Define your API once — and generate everything from it
  image:
    light: /logo-light.svg
    dark: /logo-dark.svg
    alt: Apiwork
  actions:
    - theme: brand
      text: Get Started
      link: /guide/introduction
    - theme: alt
      text: See Examples
      link: /examples/
    - theme: alt
      text: View on GitHub
      link: https://github.com/skiftle/apiwork

features:
  - icon: "🔁"
    title: Nothing Drifts
    details: The same definitions that validate requests in production generate your OpenAPI, TypeScript, and Zod. One source of truth for the entire boundary.

  - icon: "🛤"
    title: Rails Stays Rails
    details: ActiveRecord, migrations, associations, validations, gems — none of it changes. Apiwork adds the typed boundary.

  - icon: "🔀"
    title: Rails Concepts, Typed
    details: Enums become typed enums. STI and polymorphic associations become discriminated unions. Apiwork maps what Rails knows to the typed world.

  - icon: "🔍"
    title: Query Engine
    details: Filtering, sorting, and pagination with typed operators, validated parameters, and generated client types. Declare filterable and the rest is built for you.

  - icon: "📦"
    title: Nested Writes
    details: Create, update, and delete nested records in one request. Fully typed payloads with structured error paths at every level.

  - icon: "⚡"
    title: Prisma Ergonomics, Rails Power
    details: Sorbus is the typed TypeScript client, purpose-built for Apiwork. It turns your API into a Prisma-like experience — end-to-end types derived from your database, backed by the full power of Rails.
---

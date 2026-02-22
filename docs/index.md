---
layout: home

hero:
  name: Apiwork
  text: A contract-driven API layer for Rails
  tagline: Define your API once — and generate everything from it
  actions:
    - theme: brand
      text: Get Started
      link: /guide/
    - theme: alt
      text: See Examples
      link: /examples/

features:
  - icon: "\U0001F5C4"
    title: Database as source of truth
    details: Apiwork reads from ActiveRecord and the database. No repeated field definitions, enums, or nullability.
  - icon: "\U0001F3AF"
    title: Explicit behavior
    details: Requests, responses, errors, filtering, and pagination defined in one place — not implied across controllers.
  - icon: "\U0001F517"
    title: Zero drift
    details: TypeScript types, Zod schemas, and OpenAPI specs generated from the same contracts that run in production.
  - icon: "\U0001F6E1"
    title: Boring controllers
    details: Unknown input never reaches your code. Controllers stay boring, predictable, and easy to reason about.
  - icon: "\U0001F50D"
    title: Rich filtering
    details: Filter by any attribute with operators like eq, gt, lt, contains, between, and more. Multi-field sorting and pagination included.
  - icon: "\U0001F4BE"
    title: Nested saves
    details: Create, update, and delete nested associations in a single request with structured error reporting via JSON Pointers.
---

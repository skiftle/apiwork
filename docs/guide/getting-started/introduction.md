---
order: 1
---

# Introduction

Apiwork is an API layer for Rails applications, built around a clear and explicit boundary.

You define your API using a declarative contract language. That definition describes what your API accepts, what it exposes, and how data is shaped at the boundary. Everything else builds on that structure.

Apiwork sits at the edge of your application. Incoming requests are validated against the contract before they reach your code. Invalid requests are rejected at the boundary. Outgoing responses are shaped according to the same contract.

The result is an API that is explicit, predictable, and easy to reason about.

## A Contract-Driven API

At the core of Apiwork is a contract language.

The contract defines the API surface: what the API accepts, what it returns, and how data is structured. Incoming requests are validated against the contract. Outgoing responses are shaped by the same contract.

The contract is not documentation and it is not configuration. It is the definition of the API itself.

## Convention as Consistency

In most APIs, the same patterns appear again and again. Resources are filtered in similar ways. Sorting follows the same conventions. Pagination works consistently across endpoints. Relations are included predictably. Nested writes follow the same rules.

These are API concerns rather than domain concerns.

Apiwork captures these conventions in its schema and adapter system. Schemas describe the API model. Adapters execute it at the boundary.

Apiwork includes a built-in adapter that implements a conventional API model with consistent filtering, predictable sorting, standard pagination, relation traversal, N+1-safe loading, and nested writes.
This adapter provides a complete API runtime out of the box.

Adapters are not fixed. You can replace them, extend them, or write your own. The contract language stays the same. The schema model stays the same. Only the execution strategy changes.

## From Domain to API

In a typical Rails application, most of what defines the API already exists. Column types, nullability, enums, and relations are defined in the database schema and expressed through Active Record models.
Apiwork builds on this foundation.

The database defines the data model. Schemas define how that model is exposed through the API.

Schemas connect your domain model to the API layer. They define which attributes and relations are exposed, how records can be queried, and how writes are handled. From this structure, Apiwork can derive contracts automatically.

Instead of manually describing every field and constraint, you describe what should be exposed and how it should behave.

## Built on Introspection

Apiwork is built around the idea that the entire API is introspectable.

Contracts, API definitions, and schemas are represented as structured data that can be inspected at runtime. This makes the API explicit not only in how it behaves, but in how it can be understood.

Because the API is introspectable by design, other representations can be derived from the same structure. API specifications, client types, and validation schemas are generated from the same source that defines the API itself.

OpenAPI documentation, TypeScript definitions, and Zod schemas are not maintained separately. They are exports of the API model. When the API changes, its exports change with it.
This keeps behavior, documentation, and clients aligned over time.

## Next Steps

The following guides explain how this works in practice.

- [Installation](./installation.md)
- [Core Concepts](./core-concepts.md)
- [Quick Start](./quick-start.md)

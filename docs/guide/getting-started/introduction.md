---
order: 1
---

# Introduction

Apiwork is an API layer for Rails applications, built around a clear boundary.

You define a contract for what your API accepts and exposes. Everything else builds on that definition.

Apiwork sits at the edge of your application. Incoming requests are validated against the contract before they reach your code. Outgoing responses are shaped by the same contract on the way out. Data that matches flows through. Data that doesn’t is rejected at the boundary.

The result is an API that is explicit, predictable, and easy to reason about.

## Behavior Follows Structure

Once the structure is in place, common API behavior follows naturally. Filtering, sorting, pagination, sideloading, N+1 prevention, and nested writes all derive from the same underlying model.

This behavior is not implemented as independent features. It emerges from how contracts, API definitions, and schemas work together to describe what the API allows and exposes.

That same structure is also used to generate API specifications and documentation, keeping behavior and documentation aligned over time.

## Rails-Native by Design

Apiwork is designed to feel natural in a Rails application.

You still write controllers, and request flow follows familiar Rails conventions. Apiwork builds on what is already there and adds structure only where it serves a clear purpose.

## Built on Introspection

Apiwork is built around the idea that the entire API is introspectable.

Contracts, API definitions, and schemas are represented as structured data that can be inspected at runtime. This makes the API explicit not only in how it behaves, but in how it can be understood.

Because the API is introspectable by design, other representations can be derived from the same source. API specifications, type definitions, and validation schemas are generated from the same structure that defines the API itself, without being maintained separately.

Introspection in Apiwork does not stop at the API surface. Much of the information that defines an API already exists in the database schema and the Active Record models built on top of it.

By building upward from this foundation, contracts and API definitions stay grounded in a single source of truth. That information flows through the API layer and out to clients without duplication or manual synchronization.

This is a core advantage of contract-driven API design in Apiwork. The contract becomes a reliable, introspectable representation of the domain that other tools and consumers can build on.

## Next Steps

The following guides explain how this works in practice.

- [Installation](./installation.md)
- [Core Concepts](./core-concepts.md)
- [Quick Start](./quick-start.md)

---
order: 1
---

# Introduction

Apiwork starts with a simple idea: define your API once, and let the rest build on that.

At the edge of your app — where data comes in and goes out — Apiwork adds a small, contract-driven layer. Requests are validated against that contract, and responses are shaped by it. Data that matches the contract flows through. Data that doesn’t is rejected at the boundary, keeping the rest of your app predictable and consistent.

## Behaviour follows structure

From that same boundary — and a few reasonable assumptions about common API behaviour — a lot follows automatically. Filtering, sorting, pagination, sideloading, avoiding N+1 queries, and nested writes all follow the same pattern. This logic isn’t implemented separately; it falls out of the structure already in place. That same structure also enables API specifications and documentation to be generated from the same source, keeping behaviour and documentation aligned over time.

## Rails-native by design

Apiwork is designed to feel natural in Rails. You still write your controllers, and the overall flow follows established Rails conventions. Rather than replacing Rails, Apiwork builds on what’s already there, introducing new concepts only where they serve a clear purpose. The result is an API layer that feels familiar and predictable, with abstraction kept to the minimum required.

## No duplicated domain knowledge

Another important aspect of Apiwork is that it avoids repeating information you’ve already expressed elsewhere. Rails — and the database beneath it — already encodes much of your domain: attributes, types, enum values, associations, defaults, and nullability. Apiwork builds on that knowledge instead of duplicating it. In practice, the database becomes the source of truth, and the API stays aligned with it automatically. Because everything starts from the same foundation, consistency largely comes for free.

## Next steps

This introduction covers the ideas at a high level. From here, the next step is to see how they work in practice — how an API is defined, how that definition is used throughout the system, and how Rails’ own knowledge flows through the rest of the stack.

- [Installation](./installation.md)
- [Core Concepts](./core-concepts.md)
- [Quick Start](./quick-start.md)

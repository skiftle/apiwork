---
order: 1
---

# Introduction

Apiwork starts with a simple idea: define your API once, and let the rest build on that.

At the edge of your app — where data comes in and goes out — Apiwork adds a small, contract-driven layer. Every request is checked against that definition, and every response is shaped by it. If the data fits, it passes through. If it doesn’t, it’s stopped early, before it can cause problems deeper in the system.

## Behaviour follows structure

Once that single definition is in place — together with a few reasonable assumptions about how APIs tend to behave — Apiwork can take care of a lot for you automatically. Filtering, sorting, pagination, sideloading, avoiding N+1 queries, and nested writes all follow the same pattern. You’re not writing this logic by hand; it naturally follows from the structure you’ve already defined. That same structure also makes it possible to generate API specifications and documentation, so behaviour and docs stay aligned over time.

## Rails-native by design

Apiwork is designed to feel natural in Rails. You still write your controllers, and the overall flow follows established Rails conventions. Instead of trying to replace Rails, Apiwork works with it — building on existing functionality and introducing new concepts only where they serve a clear purpose. The goal is an API layer that feels familiar and predictable, with abstraction kept to the minimum required.

## No duplicated domain knowledge

Another important aspect of Apiwork is that it avoids asking you to repeat information you’ve already expressed elsewhere. Rails — and the database underneath it — already knows a lot about your domain: attributes, types, enum values, associations, defaults, and nullability. Apiwork builds on that knowledge instead of duplicating it. In practice, this means the database becomes the source of truth, and the API stays aligned with it automatically. Since everything starts from the same foundation, consistency largely comes for free.

## Next steps

This introduction covers the ideas at a high level. From here, the next step is to see how they work in practice — how an API is defined, how that definition is used throughout the system, and how Rails’ own knowledge flows through the rest of the stack.

- [Installation](./installation.md)
- [Quick Start](./quick-start.md)
- [Core Concepts](./core-concepts.md)

---
order: 1
---

# Introduction

Apiwork starts with a simple idea: **define your API once**, and let the
rest build on that. At the edge of your app — where data comes in and
goes out — Apiwork adds a small contract‑driven layer. Every request
is checked against the contract, every response is shaped by it. If the
data fits, it passes through; if not, it's stopped early.

Once that single definition is in place — together with a few
reasonable assumptions about how APIs tend to behave — Apiwork can do
quite a lot for you automatically. Filtering, sorting, pagination,
sideloading, avoiding N+1 queries, and nested writes all follow the same
pattern. You're not writing this logic yourself; it simply comes from
the structure you've already defined.

Apiwork is also meant to feel natural in Rails. You still write your
controllers, and the whole flow follows the Rails way of doing things,
so nothing feels out of place. At a high level, your API has a
**contract** — a clear shape that requests must follow and responses
must match.

The key is that Apiwork doesn't ask you to repeat information you've
already expressed elsewhere. Rails — and the database underneath it
— already knows a lot about your domain: attributes, types, enum
values, associations, defaults, nullability. Apiwork builds on that
instead of duplicating it. In practice, the database becomes the source
of truth, and the API stays aligned with it automatically. Since
everything starts from the same foundation, consistency more or less
comes for free.

With a single, explicit definition guiding the boundary of your app, a
lot of good things become possible. Modern APIs rely on structure and
predictability — clear shapes, stable behaviour, and types that
clients can trust. Apiwork gives Rails that structure without changing
how you work. You keep the productivity and simplicity of Ruby, and at
the same time you get the clarity and type‑safety expected in modern API
ecosystems.

From here, the next step is to see how these ideas look in practice —
how an API is defined, how its structure becomes a contract, and how
Rails' own knowledge flows through the rest of the system.

## What's Next

- [Installation](./installation.md)
- [Core Concepts](./core-concepts.md)
- [Quick Start](./quick-start.md)

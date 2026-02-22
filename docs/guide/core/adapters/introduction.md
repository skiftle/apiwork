---
order: 1
---

# Introduction

The adapter executes your API at runtime. It translates between representations and HTTP — validating requests, building queries, and rendering responses.

## What Adapters Do

Every request flows through the adapter:

1. **Validate** — Check request against contract types
2. **Transform** — Convert input for processing
3. **Query** — Build and execute database queries
4. **Serialize** — Convert records to response format
5. **Wrap** — Structure the final response body

The adapter derives most behavior from your representations. Filterable attributes become filter parameters. Sortable attributes become sort options. Associations become includable relations.

## Capabilities

Adapters are built from capabilities — modular features like filtering, sorting, pagination. Each capability contributes to three phases:

| Phase | Runs | Purpose |
|-------|------|---------|
| **API** | Once at boot | Register shared types |
| **Contract** | Once per representation | Generate representation-specific types |
| **Runtime** | Each request | Process data |

## Standard Adapter

Apiwork ships with a complete REST adapter. It provides:

- [Filtering](./standard-adapter/filtering.md) — `?filter[status][eq]=sent`
- [Sorting](./standard-adapter/sorting.md) — `?sort[created_at]=desc`
- [Pagination](./standard-adapter/pagination.md) — offset or cursor
- [Includes](./standard-adapter/includes.md) — eager load associations
- [Action Defaults](./standard-adapter/action-defaults.md) — generated CRUD

For minor changes, [extend the standard adapter](./standard-adapter/extending.md).

## Next Steps

- [Standard Adapter](./standard-adapter/introduction.md) — the built-in REST adapter
- [Custom Adapters](./custom-adapters/introduction.md) — build your own for JSON:API, HAL, or any format

#### See also

- [Adapter::Base reference](../../../reference/adapter/base.md) — all adapter methods and options

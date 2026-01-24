---
order: 1
---

# Introduction

The **adapter** is the runtime layer that executes your API. It translates between schema definitions and HTTP — handling requests, building queries, and rendering responses.

The adapter implements the API conventions and enforces consistent behavior across the entire API. Every resource follows the same patterns for filtering, sorting, pagination, and serialization.

## Bound Contracts

A contract becomes **bound** when you call `schema!`. This connects the contract to a schema by naming convention — `InvoiceContract` finds `InvoiceSchema` in the same namespace.

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!
end
```

Bound contracts unlock capabilities like filtering, sorting, and includes — behaviors that require knowledge of the underlying data structure. Contracts without schemas remain valid but operate without these derived behaviors.

## Capabilities

Adapters are composed of **capabilities** — modular units that provide specific functionality. The standard adapter includes capabilities for filtering, sorting, pagination, includes, and writing.

Each capability can contribute to three phases:

| Phase | Runs | Purpose |
|-------|------|---------|
| **API** | Once per API | Register shared types used across all contracts |
| **Contract** | Once per bound contract | Generate contract-specific types |
| **Computation** | Each request | Transform data at runtime |

For example, the Filtering capability:

- **API phase**: Registers generic filter types (`string_filter`, `date_filter`, `uuid_filter`) — once per API
- **Contract phase**: Generates a `filter` type from the schema's filterable attributes — once per bound contract
- **Computation phase**: Translates filter parameters into database queries — once per request

Computations can be scoped to run only for collections or single records. Pagination runs on collections. Writing validation runs on records.

## The Standard Adapter

Apiwork ships with a complete REST API adapter out of the box. For each resource, it automatically generates the corresponding actions and derives their behavior from the schema.

The standard adapter provides:

- [Action Defaults](./standard-adapter/action-defaults.md) — generated CRUD actions
- [Filtering](./standard-adapter/filtering.md) — `?filter[field][op]=value`
- [Sorting](./standard-adapter/sorting.md) — `?sort[field]=asc`
- [Pagination](./standard-adapter/pagination.md) — offset or cursor-based
- [Includes](./standard-adapter/includes.md) — eager loading associations
- [Serialization](./standard-adapter/serialization.md) — response formatting

All generated behavior remains fully customizable. You can override individual actions, replace them entirely, or extend them by merging additional behavior on top.

## Custom Adapters

For different response formats or query logic, you can create a [custom adapter](./custom-adapters.md). Custom adapters let you change how queries are built and responses are rendered while keeping the schema-driven type system.

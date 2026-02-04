---
order: 1
---

# Introduction

The **adapter** is the runtime layer that executes your API. It translates between schema definitions and HTTP — handling requests, building queries, and rendering responses.

The adapter implements your API conventions and enforces consistent behavior across the entire API.

## Contracts with Representation

A contract gains a **representation** when you call `representation` with a representation class.

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation
end
```

Contracts with representation unlock capabilities like filtering, sorting, and includes — behaviors that require knowledge of the underlying data structure. Contracts without representations remain valid but operate without these derived behaviors.

## Capabilities

Adapters are composed of **capabilities** — modular units that provide specific functionality. The standard adapter includes capabilities for filtering, sorting, pagination, includes, and writing.

Each capability can contribute to three phases:

| Phase | Runs | Purpose |
|-------|------|---------|
| **API** | Once per API | Register shared types used across all contracts |
| **Contract** | Once per contract with representation | Generate contract-specific types |
| **Computation** | Each request | Transform data at runtime |

For example, the Filtering capability:

- **API phase**: Registers generic filter types (`string_filter`, `date_filter`, `uuid_filter`) — once per API
- **Contract phase**: Generates a `filter` type from the representation's filterable attributes — once per contract with representation
- **Computation phase**: Translates filter parameters into database queries — once per request

Computations can be scoped to run only for collections or single records. Pagination runs on collections. Writing validation runs on records.

## The Standard Adapter

Apiwork ships with a complete REST API adapter out of the box. For each resource, it automatically generates the corresponding actions and derives their behavior from the representation.

The standard adapter provides:

- [Action Defaults](./standard-adapter/action-defaults.md) — generated CRUD actions
- [Filtering](./standard-adapter/filtering.md) — `?filter[field][op]=value`
- [Sorting](./standard-adapter/sorting.md) — `?sort[field]=asc`
- [Pagination](./standard-adapter/pagination.md) — offset or cursor-based
- [Includes](./standard-adapter/includes.md) — eager loading associations
- [Serialization](./standard-adapter/serialization.md) — response formatting

All generated behavior remains fully customizable. You can override individual actions, replace them entirely, or extend them by merging additional behavior on top.

## Custom Adapters

For different response formats or query logic, you can create a [custom adapter](./custom-adapters.md). Custom adapters let you change how queries are built and responses are rendered while keeping the representation-driven type system.

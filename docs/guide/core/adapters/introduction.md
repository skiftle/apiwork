---
order: 1
---

# Introduction

The **adapter** is the runtime layer that executes your API. It translates between schema definitions and HTTP — handling requests, building queries, and rendering responses.

The adapter implements the API conventions and enforces consistent behavior across the entire API. Every resource follows the same patterns for filtering, sorting, pagination, and serialization.

## Two Phases

The adapter operates in two distinct phases: **definition time** and **request time**.

### Definition Time

When you call `schema!`, the adapter reads your schema and interprets it as an executable contract.

From this single definition, Apiwork derives a set of typed constraints that describe:

- which query parameters are allowed
- how data can be written
- how responses should be serialized

### Request Time

When a request arrives, the contract validates it against the generated types. Then the adapter:

1. **Query** — translates filter/sort/page/include into database queries
2. **Serialize** — formats the response according to the schema

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

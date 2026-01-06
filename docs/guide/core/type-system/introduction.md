---
order: 1
---

# Introduction

The **Type System** defines the language used by Apiwork contracts.

It describes data shapes, constraints, and semantics declaratively.
These definitions express what data is allowed at the API boundary.

Types are defined in Ruby, but are purely declarative. They define shape and constraints.

---

## What the Type System Defines

The type system defines:

- What fields exist
- Which values are allowed
- Which fields are required or optional
- How values are structured and nested
- What invariants must hold

It does **not** define runtime behavior, such as:

- how requests are handled
- how data is queried
- how responses are rendered

Those concerns belong to the [Execution Engine](../execution-engine/introduction.md).

---

## Shapes and Constraints

A type defines both **shape** and **constraints**.

```ruby
type :invoice do
  param :id, type: :uuid
  param :number, type: :string
  param :status, type: :string, enum: %w[draft sent paid]
  param :total, type: :decimal
  param :line_items, type: :array, of: :line_item
end
```

This definition expresses:

- which fields exist
- how they are nested
- which values are valid
- which constraints apply

---

## Primitives

Types are built from primitives:

| Type        | Description              |
| ----------- | ------------------------ |
| `:string`   | Text values              |
| `:integer`  | Whole numbers            |
| `:boolean`  | True / false             |
| `:date`     | Date only (ISO 8601)     |
| `:datetime` | Date and time (ISO 8601) |
| `:time`     | Time only (ISO 8601)     |
| `:uuid`     | UUID format              |
| `:decimal`  | Precise decimal values   |
| `:float`    | Floating point numbers   |

Structural types (`:array`, `:object`) and special types (`:json`, `:binary`, `:literal`, `:unknown`) are also available.

---

## Next Steps

| Topic                             | Description                                         |
| --------------------------------- | --------------------------------------------------- |
| [Types](./types.md)               | Optionality, nullability, defaults, and constraints |
| [Enums](./enums.md)               | Restrict values to a fixed set                      |
| [Unions](./unions.md)             | Multiple shapes with a discriminator                |
| [Custom Types](./custom-types.md) | Reusable named types                                |
| [Scoping](./scoping.md)           | API-level vs contract-scoped types                  |
| [Type Merging](./type-merging.md) | Extending and composing types                       |

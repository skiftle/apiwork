---
order: 1
---

# Introduction

The **Type System** defines the language used by Apiwork contracts.

It describes data shapes, constraints, and semantics declaratively.
These definitions express what data is allowed at the API boundary.

Types are defined in Ruby, but are purely declarative. They define shape and constraints.

---

## Three Concepts

The type system has three distinct concepts:

| Concept | Purpose | DSL |
|---------|---------|-----|
| **object** | Structured data with named fields | `object :name do ... end` |
| **union** | One of several shapes | `union :name do ... end` |
| **enum** | Restricted set of values | `enum :name, values: [...]` |

**Objects** define structure. **Unions** define alternatives. **Enums** constrain values.

Technically, only objects and unions are types — they define shape. Enums are value constraints applied to a field, not standalone types. You reference an enum with `enum: :name`, not `type: :name`.

```ruby
object :invoice do
  param :id, type: :uuid
  param :status, type: :string, enum: :invoice_status
  param :payment, type: :payment_method
end

union :payment_method, discriminator: :kind do
  variant tag: 'card', type: :object do
    param :last_four, type: :string
  end
  variant tag: 'bank', type: :object do
    param :account, type: :string
  end
end

enum :invoice_status, values: %w[draft sent paid]
```

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

An object defines both **shape** and **constraints**.

```ruby
object :invoice do
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

| Topic                   | Description                                         |
| ----------------------- | --------------------------------------------------- |
| [Types](./types.md)     | Optionality, nullability, defaults, and constraints |
| [Objects](./objects.md) | Reusable named objects                              |
| [Unions](./unions.md)   | Multiple shapes with a discriminator                |
| [Enums](./enums.md)     | Restrict values to a fixed set                      |
| [Scoping](./scoping.md) | API-level vs contract-scoped types                  |
| [Merging](./merging.md) | Extending and composing types                       |

#### See also

- [Contract::Base reference](../../../reference/contract-base.md) — `object`, `union`, and `enum` methods

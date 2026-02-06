---
order: 1
---

# Introduction

Types define the structure of data in your contracts.

It describes data shapes, constraints, and semantics declaratively. These definitions express what data is allowed at the API boundary — and how it is interpreted.

Types are defined in Ruby, but are purely declarative. They describe both the wire format and the runtime semantics used for coercion and validation.

---

## Three Concepts

There are three distinct concepts:

| Concept    | Purpose                           | DSL                         |
| ---------- | --------------------------------- | --------------------------- |
| **object** | Structured data with named fields | `object :name do ... end`   |
| **union**  | One of several shapes             | `union :name do ... end`    |
| **enum**   | Restricted set of values          | `enum :name, values: [...]` |

**Objects** define structure. **Unions** define alternatives. **Enums** constrain values.

Technically, only objects and unions are _types_ — they define shape. Enums are value constraints applied to a param, not standalone types.

```ruby
object :invoice do
  uuid :id
  datetime :created_at
  reference :payment_method
  string :status, enum: :status
end

union :payment_method, discriminator: :kind do
  variant tag: 'card' do
    object do
      string :last_four
    end
  end
  variant tag: 'bank' do
    object do
      string :account
    end
  end
end

enum :status, values: %w[draft sent paid]
```

---

## What Types Define

Types define:

- What fields exist
- Which values are allowed
- Which fields are required or optional
- How values are structured and nested
- What invariants must hold

It does **not** define runtime behavior, such as:

- how requests are handled
- how data is queried
- how responses are rendered

Those concerns belong to the [Adapter](../adapters/introduction.md).

---

## Shapes and Constraints

An object defines both **shape** and **constraints**.

```ruby
object :invoice do
  uuid :id
  string :number
  string :status, enum: %w[draft sent paid]
  decimal :total
  array :items do
    reference :items
  end
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
| `:number`   | Floating point numbers   |

Structural types (`:array`, `:object`) and special types (`:binary`, `:literal`, `:unknown`) are also available.

---

## Next Steps

| Topic                       | Description                               |
| --------------------------- | ----------------------------------------- |
| [Types](./types.md)         | Primitives, scalars, and special types    |
| [Modifiers](./modifiers.md) | Optional, nullable, defaults, constraints |
| [Objects](./objects.md)     | Reusable named objects                    |
| [Unions](./unions.md)       | Multiple shapes with a discriminator      |
| [Enums](./enums.md)         | Restrict values to a fixed set            |
| [Scoping](./scoping.md)     | API-level vs contract-scoped types        |
| [Declaration Merging](./declaration-merging.md) | Multiple declarations combine |
| [Type Reuse](./type-reuse.md) | Inheritance and composition               |

#### See also

- [Contract::Base reference](../../../reference/contract/base.md) — `object`, `union`, and `enum` methods

---
order: 1
---

# Introduction

The type system is a DSL for describing data shapes. You define types in Ruby, and Apiwork uses them throughout the request lifecycle and for generating specs.

## What Types Do

When you define a type, Apiwork uses it for:

**Request handling:**
- Validates that incoming data matches the expected shape
- Coerces values to the correct type (e.g., `"123"` → `123`)
- Rejects requests with missing required fields or wrong types

**Response handling:**
- Validates outgoing data before sending
- Serializes values to the correct format (e.g., dates to ISO 8601)
- Transforms keys if configured (e.g., `created_at` → `createdAt`)

**Spec generation:**
- [Introspection](../../advanced/introspection.md) converts types to a JSON representation
- Spec generators read this JSON and produce TypeScript, Zod, and OpenAPI

## Primitives

Every type is built from primitives:

| Type | Description |
|------|-------------|
| `:string` | Text values |
| `:integer` | Whole numbers |
| `:boolean` | True/false |
| `:date` | Date only (ISO 8601) |
| `:datetime` | Date and time (ISO 8601) |
| `:uuid` | UUID format |
| `:decimal` | Precise decimals |
| `:float` | Floating point |

Plus: `:json`, `:binary`, `:literal`, `:unknown`

Combine them into structures:

```ruby
type :invoice do
  param :id, type: :uuid
  param :number, type: :string
  param :status, type: :string, enum: %w[draft sent paid]
  param :total, type: :decimal
  param :line_items, type: :array, of: :line_item
end
```

## What's Next

| Topic | Description |
|-------|-------------|
| [Types](./types.md) | Type options: optional, nullable, default, min/max |
| [Enums](./enums.md) | Restrict values to a set |
| [Unions](./unions.md) | Multiple type options with discriminator |
| [Custom Types](./custom-types.md) | Reusable named types |
| [Scoping](./scoping.md) | API-level vs contract-scoped types |
| [Type Merging](./type-merging.md) | Extend existing types |

See also: [Introspection](../../advanced/introspection.md), [Spec Generation](../spec-generation/introduction.md)

---
order: 1
---

# Introduction

The type system powers everything in Apiwork. Requests, responses, filters, payloads — all flow through it.

Define a type once. Use it in contracts, schemas, and generated specs. The same definition produces Ruby validation, TypeScript types, Zod schemas, and OpenAPI specs.

## [Types](./types.md)

Primitives form the foundation. Every param and attribute uses one of these:

| Type | Description |
|------|-------------|
| `:string` | Text values |
| `:integer` | Whole numbers |
| `:boolean` | True/false |
| `:date` | Date only |
| `:datetime` | Date and time |
| `:uuid` | UUID format |
| `:decimal` | Precise decimals |
| `:float` | Floating point |

Plus special types: `:json`, `:binary`, `:literal`, `:unknown`

## [Enums](./enums.md)

Restrict values to a predefined set:

```ruby
enum :status, values: %w[draft published archived]
```

```typescript
type Status = 'archived' | 'draft' | 'published';
```

## [Unions](./unions.md)

Multiple type options with optional discriminator:

```ruby
union :payment_method, discriminator: :type do
  variant tag: 'card' do
    param :last_four, type: :string
  end
  variant tag: 'bank' do
    param :account_number, type: :string
  end
end
```

## [Custom Types](./custom-types.md)

Reusable object structures:

```ruby
type :address do
  param :street, type: :string
  param :city, type: :string
  param :country, type: :string
end
```

Reference anywhere:

```ruby
param :shipping_address, type: :address
param :addresses, type: :array, of: :address
```

## [Scoping](./scoping.md)

Types live at two levels:

- **API-level** — available to all contracts, keeps original name
- **Contract-scoped** — prefixed with contract name in specs

A `:status` type in `OrderContract` becomes `order_status` in generated output.

## [Type Merging](./type-merging.md)

Types are open for extension. Multiple declarations merge:

```ruby
type :user do
  param :name, type: :string
end

type :user do
  param :email, type: :string  # Added to existing type
end
```

## Generated Output

Every type definition produces four outputs:

| Format | Use |
|--------|-----|
| Introspection | Internal JSON representation |
| TypeScript | Frontend type definitions |
| Zod | Runtime validation schemas |
| OpenAPI | API documentation |

See [Spec Generation](../spec-generation/introduction.md) for details.

---
order: 1
---

# Introduction

The type system powers everything in Apiwork. Requests, responses, filters, payloads — all flow through it.

Define a type once. Use it in contracts, schemas, and generated specs.

## [Types](./types.md)

Reusable structures:

```ruby
type :address do
  param :street, type: :string
  param :city, type: :string
  param :country, type: :string
end
```

```typescript
// TypeScript
export interface Address {
  city?: string;
  country?: string;
  street?: string;
}

// Zod
export const AddressSchema = z.object({
  city: z.string().optional(),
  country: z.string().optional(),
  street: z.string().optional()
});
```

## [Enums](./enums.md)

Restrict values to a set:

```ruby
enum :status, values: %w[draft published archived]
```

```typescript
// TypeScript
type Status = 'archived' | 'draft' | 'published';

// Zod
const StatusSchema = z.enum(['archived', 'draft', 'published']);
```

## [Unions](./unions.md)

Multiple type options:

```ruby
union :filter_value do
  variant type: :string
  variant type: :integer
end
```

```typescript
// TypeScript
type FilterValue = number | string;

// Zod
const FilterValueSchema = z.union([z.number().int(), z.string()]);
```

## Scoping

Types can live at two levels:

**API-level** — available to all contracts:
```ruby
Apiwork::API.draw '/api/v1' do
  type :address do
    param :street, type: :string
  end
end
```

**Contract-scoped** — local to one contract:
```ruby
class OrderContract < Apiwork::Contract::Base
  type :line_item do
    param :product_id, type: :integer
    param :quantity, type: :integer
  end
end
```

The difference in generated specs: contract-scoped types get prefixed with the contract name. A `:status` type in `OrderContract` becomes `order_status`. API-level types keep their name as-is.

See [Scoping](./scoping.md) for details.

## Available Types

For all primitives and special types, see [Types](./types.md).

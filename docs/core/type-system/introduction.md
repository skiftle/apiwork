---
order: 1
---

# Type System

The type system is the heart of Apiwork. Every request, response, filter, sort, and payload flows through it. Define a type once, use it everywhere — in contracts, schemas, and generated client code.

## [Types](./types.md)

Types are reusable structures:

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

Enums restrict values to a predefined set:

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

Unions allow multiple type options:

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

## Two Levels

Types can be defined at two levels:

1. **API-level** (global): Available to all contracts in the API
2. **Contract-scoped**: Local to a specific contract, unless you explicitly import it into another.

From an external perspective, all types are effectively global. The only difference between API-level types and contract-scoped types is that contract types are prefixed with the contract name. This prefix can be customized using the `identifier` option.

For example, a type `:status` defined in `OrderContract` becomes `order_status` in the generated specs, while an API-level `:status` type remains simply `status`.

```ruby
# API-level (global)
type :address do
  param :street, type: :string
end

# Contract-scoped
class OrderContract < Apiwork::Contract::Base
  type :line_item do
    param :product_id, type: :integer
    param :quantity, type: :integer
  end
end
```

See [Scoping](./scoping.md) for details.

## Available Types

For a complete reference of all primitive and special types, see [Types](./types.md).

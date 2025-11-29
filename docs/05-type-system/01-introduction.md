# Type System

Apiwork provides a type system for defining reusable types.

## Types

Types are reusable structures:

```ruby
Apiwork::API.draw '/api/v1' do
  type :address do
    param :street, type: :string
    param :city, type: :string
    param :country, type: :string
  end
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

## Enums

Enums restrict values to a predefined set:

```ruby
Apiwork::API.draw '/api/v1' do
  enum :status, values: %w[draft published archived]
end
```

```typescript
// TypeScript
type Status = 'archived' | 'draft' | 'published';

// Zod
const StatusSchema = z.enum(['archived', 'draft', 'published']);
```

## Unions

Unions allow multiple type options:

```ruby
Apiwork::API.draw '/api/v1' do
  union :filter_value do
    variant type: :string
    variant type: :integer
  end
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
Apiwork::API.draw '/api/v1' do
  type :address do
    param :street, type: :string
  end
end

# Contract-scoped
class OrderContract < Apiwork::Contract::Base
  type :line_item do
    param :product_id, type: :integer
    param :quantity, type: :integer
  end
end
```

See [Scoping](./04-scoping.md) for details.

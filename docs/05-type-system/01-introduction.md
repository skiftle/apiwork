# Type System

Apiwork provides a type system for defining reusable types.

## Why Symbol-Based Types?

Types are referenced by symbols (`:address`, `:status`) rather than Ruby classes. This enables:

**Define in any order** — Reference a type before it's defined:

```ruby
param :billing, type: :billing_address  # Works!

type :billing_address do
  param :street, type: :string
end
```

With Ruby classes, this would fail with `NameError: uninitialized constant`.

**Automatic spec generation** — Symbol names map directly to output formats:

| Ruby | TypeScript | Zod |
|------|------------|-----|
| `:address` | `Address` | `AddressSchema` |
| `:user_status` | `UserStatus` | `UserStatusSchema` |

**Scoping without class proliferation** — The same type name in different contexts:

```ruby
# In PostContract
type :status  # → post_status

# In OrderContract
type :status  # → order_status
```

One concept, automatic namespacing. No need for `PostStatusType`, `OrderStatusType` classes.

**Circular references handled** — Post references Comments, Comments reference Post. Detected and resolved at spec generation time, not load time.

## Types

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

## Enums

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

## Unions

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

See [Scoping](./04-scoping.md) for details.

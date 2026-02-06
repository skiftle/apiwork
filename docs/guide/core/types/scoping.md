---
order: 7
---

# Scoping

Objects, unions, and enums can be global (API-level) or scoped to a contract.

## API-Level Definitions

Defined in the API define block:

```ruby
Apiwork::API.define '/api/v1' do
  object :address do
    string :street
    string :city
  end

  enum :status, values: %w[active inactive]
end
```

Available to all contracts in the API.

## Contract-Scoped Definitions

Defined inside a contract:

```ruby
class OrderContract < Apiwork::Contract::Base
  object :line_item do
    integer :product_id
    integer :quantity
  end

  enum :priority, values: %i[low medium high]
end
```

Only available within that contract.

## Scoped Names

Contract-scoped definitions get a prefix based on the contract:

| Contract        | Name         | Scoped Name        |
| --------------- | ------------ | ------------------ |
| `OrderContract` | `:line_item` | `:order_line_item` |
| `PostContract`  | `:status`    | `:post_status`     |

This prefix appears in the generated output:

```typescript
// API-level (no prefix)
export interface Address { ... }
export const AddressSchema = z.object({ ... });

// Contract-scoped (prefixed with contract name)
export interface OrderLineItem { ... }
export const OrderLineItemRepresentation = z.object({ ... });

// Contract-scoped enum
export type PostStatus = 'draft' | 'published';
export const PostStatusSchema = z.enum(['draft', 'published']);
```

## Resolution Priority

When an object or enum is referenced, Apiwork looks in this order:

1. Contract-scoped definitions (if inside a contract)
2. API-level definitions

```ruby
class PostContract < Apiwork::Contract::Base
  enum :status, values: %w[draft published]  # Contract-scoped

  action :create do
    request do
      body do
        string :status, enum: :status         # Resolves to contract-scoped post_status
        reference :address                    # Uses global address
      end
    end
  end
end
```

## Importing Types

Access types from other contracts:

```ruby
class OrderContract < Apiwork::Contract::Base
  import UserContract, as: :user

  action :create do
    request do
      body do
        reference :shipping_address, to: :user_address
      end
    end
  end
end
```

See [Imports](../contracts/imports.md) for sharing types between contracts.

## Generated Output

API-level definitions keep their original name. Contract-scoped definitions get prefixed.

### Introspection

```json
{
  "types": {
    "address": {
      "type": "object",
      "shape": { ... }
    },
    "order_line_item": {
      "type": "object",
      "shape": { ... }
    }
  },
  "enums": {
    "status": {
      "values": ["active", "inactive"]
    },
    "post_status": {
      "values": ["draft", "published"]
    }
  }
}
```

### TypeScript

```typescript
// API-level (no prefix)
export interface Address { ... }

// Contract-scoped (prefixed)
export interface OrderLineItem { ... }
export type PostStatus = 'draft' | 'published';
```

#### See also

- [API::Base reference](../../../reference/api/base.md) — API-level `object`, `union`, and `enum`
- [Contract::Base reference](../../../reference/contract/base.md) — contract-scoped definitions

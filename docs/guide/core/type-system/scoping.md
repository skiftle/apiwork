---
order: 6
---

# Scoping

Types can be global (API-level) or scoped to a contract.

## API-Level Types

Defined in the API define block:

```ruby
Apiwork::API.define '/api/v1' do
  type :address do
    param :street, type: :string
    param :city, type: :string
  end

  enum :status, values: %w[active inactive]
end
```

Available to all contracts in the API.

## Contract-Scoped Types

Defined inside a contract:

```ruby
class OrderContract < Apiwork::Contract::Base
  type :line_item do
    param :product_id, type: :integer
    param :quantity, type: :integer
  end

  enum :priority, values: %i[low medium high]
end
```

Only available within that contract.

## Scoped Names

Contract-scoped types get a prefix based on the contract:

| Contract        | Type         | Scoped Name        |
| --------------- | ------------ | ------------------ |
| `OrderContract` | `:line_item` | `:order_line_item` |
| `PostContract`  | `:status`    | `:post_status`     |

This prefix appears in the generated output:

```typescript
// API-level type (no prefix)
export interface Address { ... }
export const AddressSchema = z.object({ ... });

// Contract-scoped type (prefixed with contract name)
export interface OrderLineItem { ... }
export const OrderLineItemSchema = z.object({ ... });

// Contract-scoped enum
type PostStatus = 'draft' | 'published';
const PostStatusSchema = z.enum(['draft', 'published']);
```

## Resolution Priority

When a type is referenced, Apiwork looks:

1. Contract-scoped types (if inside a contract)
2. API-level types

```ruby
class PostContract < Apiwork::Contract::Base
  enum :status, values: %w[draft published]  # Contract-scoped

  action :create do
    request do
      body do
        param :status, type: :string, enum: :status  # Uses post_status
        param :address, type: :address                # Uses global address
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
        param :shipping_address, type: :user_address
      end
    end
  end
end
```

See [Imports](../contracts/imports.md) for sharing types between contracts.

## Generated Output

API-level types keep their original name. Contract-scoped types get prefixed.

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
interface Address { ... }

// Contract-scoped (prefixed)
interface OrderLineItem { ... }
type PostStatus = "draft" | "published";
```

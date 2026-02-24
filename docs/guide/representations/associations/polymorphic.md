---
order: 5
---

# Polymorphic

Polymorphic associations connect to multiple model types.

## Definition

Polymorphic associations accept an array of representation classes:

```ruby
class ItemRepresentation < Apiwork::Representation::Base
  belongs_to :billable, polymorphic: [
    ServiceRepresentation,
    ProductRepresentation,
  ]
end
```

Each representation's model determines the polymorphic type value. Symbols and hashes are not accepted — representation classes are required.

## Rails Setup

The model requires standard Rails polymorphic configuration:

```ruby
class Item < ApplicationRecord
  belongs_to :billable, polymorphic: true
end

class Service < ApplicationRecord
  has_many :items, as: :billable
end
```

Database columns required: `billable_id` and `billable_type`.

## Generated Types

Polymorphic associations generate discriminated unions. The type field name and key format depend on adapter configuration:

```typescript
export type ItemBillable =
  | { billableType: 'service' } & Service
  | { billableType: 'product' } & Product;

export interface Item {
  description: string;
  billable?: ItemBillable;
}
```

## Restrictions

Polymorphic associations have limitations:

| Feature | Supported | Reason |
|---------|-----------|--------|
| `include` | Yes | |
| `writable` | No | Rails doesn't support nested attributes for polymorphic |
| `filterable` | No | Cannot filter across multiple tables |
| `sortable` | No | Cannot sort across multiple tables |

If you need filtering or sorting on polymorphic associations, the associated models can be exposed as their own [resources](/guide/api-definitions/resources).

## Examples

- [Polymorphic Associations](/examples/polymorphic-associations.md) — Handle belongs_to associations with multiple types

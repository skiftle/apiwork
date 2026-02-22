---
order: 4
---
# Associations

An association defines a relationship between resources. Each association declares its type, representation mapping, and include mode — the adapter uses these declarations to derive query capabilities and nested write behavior.

## What Associations Do

Every association declares:

- **Relationship type** — `has_one`, `has_many`, or `belongs_to`
- **Representation mapping** — which representation renders the related resource (auto-detected)
- **Include mode** — whether the association is always present or opt-in per request
- **Behavior flags** — whether the association is writable, filterable, or sortable

## A Minimal Declaration

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  belongs_to :customer, filterable: true, include: :always
  has_many :items, writable: true
  has_one :receipt
end
```

Apiwork detects the associated representation and nullable from your model. The adapter interprets behavior flags like `filterable` and `writable` at runtime.

## Next Steps

- [Declaration](./declaration.md) — types, auto-detection, options reference, and response structure
- [Include Modes](./include-modes.md) — controlling when associations appear in responses
- [Writable](./writable.md) — nested create, update, and delete through associations
- [Polymorphic](./polymorphic.md) — associations that belong to multiple model types

#### See also

- [Representation::Base reference](../../../../reference/apiwork/representation/base.md) — all association options

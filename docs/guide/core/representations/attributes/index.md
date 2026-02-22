---
order: 3
---
# Attributes

An attribute defines a single field exposed through your API. Each attribute declares its type, visibility, and behavior — the adapter uses these declarations to derive contracts, request shapes, and query capabilities.

## What Attributes Do

Every attribute declares:

- **Field exposure** — which model columns appear in API responses
- **Type information** — data type, nullability, and enum values (auto-detected from the database)
- **Behavior flags** — whether the field is writable, filterable, or sortable
- **Metadata** — descriptions, examples, and deprecation markers for generated exports

## A Minimal Declaration

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :number, filterable: true, sortable: true, writable: true
  attribute :status, filterable: true
  attribute :issued_on, sortable: true
  attribute :total
end
```

Apiwork detects types, nullability, and enum values from your database. The adapter interprets behavior flags like `filterable` and `sortable` at runtime.

## Next Steps

- [Declaration](./declaration.md) — auto-detection, options reference, and batch configuration
- [Custom](./custom.md) — virtual attributes backed by methods
- [Writable](./writable.md) — controlling create and update access
- [Encode & Decode](./encode-decode.md) — transforming values during serialization
- [Inline Types](./inline-types.md) — defining shapes for JSON/JSONB columns
- [Metadata](./metadata.md) — descriptions, examples, deprecation, and format hints

#### See also

- [Representation::Element](/reference/apiwork/representation/element.md) — block context reference

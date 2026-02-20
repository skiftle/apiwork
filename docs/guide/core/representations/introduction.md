---
order: 1
---

# Introduction

A representation describes how an ActiveRecord model appears through your API. It connects your domain model to the boundary — declaring which attributes are visible, which are writable, and how associations are exposed.

## What Representations Do

Every representation declares:

- **Map models to the boundary** — reflect column types, enums, nullability, and associations from your database
- **Declare visibility** — which attributes and relations are exposed in responses
- **Configure behavior** — which fields are filterable, sortable, writable, or includable
- **Drive the adapter** — the adapter derives contracts, request shapes, and runtime behavior from the representation

Representations are optional. You can write [contracts](../contracts/introduction.md) entirely by hand. Representations exist to remove duplication for endpoints that expose ActiveRecord models.

## A Minimal Representation

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :id
  attribute :number, filterable: true, sortable: true, writable: true
  attribute :status, filterable: true
  attribute :issued_on, sortable: true, writable: true

  belongs_to :customer, filterable: true
  has_many :lines, writable: true
end
```

Apiwork infers the model from the class name (`InvoiceRepresentation` maps to `Invoice`) and derives types, nullability, and enum values from your database and models.

Connect the representation to a contract to activate it:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation
end
```

The [adapter](../adapters/introduction.md) then derives filter types, sort options, request payloads, and response shapes automatically.

## Next Steps

- [Attributes](./attributes.md) — declaring scalar fields and their options
- [Associations](./associations.md) — exposing relations and nested writes
- [Inference](./inference.md) — how models and types are resolved
- [Configuration](./configuration.md) — root key, metadata, and global options
- [Serialization](./serialization.md) — how records are rendered in responses
- [Single Table Inheritance](./single-table-inheritance.md) — STI support

#### See also

- [Representation::Base reference](../../../reference/representation/base.md) — all representation methods and options

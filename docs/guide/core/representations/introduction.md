---
order: 1
---

# Introduction

A representation connects your model, contract, and endpoint behavior.

It describes:

- Which attributes and relations are exposed
- How data is shaped when rendered
- The metadata that powers filtering, sorting, pagination and nested operations

If you've used Active Model Serializers, the DSL will look familiar. But representations also describe how the API can query and interact with records — not just how to serialize them.

## Why Representations?

Contracts require you to describe structures that already exist in your models.

Representations map ActiveRecord models into Apiwork's metadata — column types, enums, associations, constraints. Instead of repeating what Rails already knows, Apiwork builds on it.

## Basic Example

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :id
  attribute :number
  attribute :issued_on
  attribute :created_at

  has_many :lines
  belongs_to :customer
end
```

This tells Apiwork that:

- `id`, `number`, `issued_on`, `created_at` are scalar attributes on `Invoice`
- `lines` is a `has_many` relation that can be included
- `customer` is a `belongs_to` relation that can be included

## Model Inference

Every representation is backed by a model. By default, Apiwork infers the model from the representation's class name:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  # Expects Invoice model
end
```

This works even when namespaced:

```ruby
module Api::V1
  class InvoiceRepresentation < Apiwork::Representation::Base
    # Still maps to Invoice model
  end
end
```

Override explicitly when needed:

```ruby
class AuthorRepresentation < Apiwork::Representation::Base
  model User
end
```

Apiwork infers types, nullability, defaults, and enum values from your database and models.

## Connecting to Contract

Use `representation` to connect a contract to its representation:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  representation InvoiceRepresentation
end
```

With `representation`, Apiwork auto-generates request bodies, response shapes, filter types, sort options and includes — all from the representation definition.

At runtime, the [adapter](../adapters/introduction.md) interprets these definitions and handles validation, querying, and serialization automatically.

## Representations as Instructions

Representations are purely declarative — they describe *what* exists, not *how* to process it. The [adapter](../adapters/introduction.md) interprets your representation and handles everything: building contracts, validating requests, querying the database, and serializing responses.

Representation definitions also tell the adapter:

- Which fields are safe to [filter](../adapters/standard-adapter/filtering.md) on
- Which attributes can be [sorted](../adapters/standard-adapter/sorting.md) by
- How results are [paginated](../adapters/standard-adapter/pagination.md)
- Which associations can be [included](../adapters/standard-adapter/includes.md)
- How nested writes should be handled

The adapter uses representation definitions for all API behavior.

## Root Key

Every representation has a root key that the adapter can use to wrap request and response data. By default, Apiwork derives it from the model name:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  # root key: "invoice" / "invoices"
end
```

The built-in adapter wraps single records in the singular form, and collections in the plural:

```json
// Single record uses singular root key
{
  "invoice": {
    "id": 1,
    "number": "INV-001"
  }
}

// Collection uses plural root key
{
  "invoices": [
    { "id": 1, "number": "INV-001" },
    { "id": 2, "number": "INV-002" }
  ]
}
```

Request bodies follow the same pattern — create and update payloads are wrapped in the singular root key. See [Serialization](../adapters/standard-adapter/serialization.md) for details on how the adapter transforms data.

Override when you need a different name:

```ruby
class PostRepresentation < Apiwork::Representation::Base
  root :article  # auto-pluralizes to "articles"
end
```

For irregular plurals, you can use Rails' inflector:

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'cactus', 'cacti'
end
```

This way, `root :cactus` automatically pluralizes to `cacti`.

If configuring inflections isn't an option, or you want to keep it local to the representation, pass both forms:

```ruby
class CactusRepresentation < Apiwork::Representation::Base
  root :cactus, :cacti
end
```

## Representation Metadata

Add documentation to your representation for export generation:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  description "Represents a customer invoice with line items"
  example { id: "inv_123", number: "INV-2024-001", total: "99.00" }
  deprecated  # Mark the entire type as deprecated
end
```

| Method        | Description                                            |
| ------------- | ------------------------------------------------------ |
| `description` | Human-readable description for OpenAPI/TypeScript docs |
| `example`     | Example value shown in generated exports               |
| `deprecated`  | Mark the representation type as deprecated                     |

These appear in the generated `invoice` type definition.

#### See also

- [Representation::Base reference](../../../reference/representation-base.md) — all representation methods and options

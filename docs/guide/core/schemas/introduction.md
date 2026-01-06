---
order: 1
---

# Introduction

A schema is the bridge between your model, your contract, and the behavior of the endpoint.

It describes:

- Which attributes and relations are exposed
- How data is shaped when rendered
- The metadata that powers filtering, sorting, pagination and nested operations

If you've used Active Model Serializers, the DSL will feel familiar. But schemas in Apiwork go further: they don't just describe how to serialize a record — they describe how the API can query and interact with it.

## Why Schemas?

Contracts alone can take you far. But you're still hand-describing structures that already exist in your models.

Schemas change that. They map ActiveRecord models directly into Apiwork's metadata — column types, enums, associations, constraints. Instead of repeating what Rails already knows, Apiwork builds on it.

## Basic Example

```ruby
class InvoiceSchema < Apiwork::Schema::Base
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

Every schema is backed by a model. By default, Apiwork infers the model from the schema's class name:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  # Expects Invoice model
end
```

This works even when namespaced:

```ruby
module Api::V1
  class InvoiceSchema < Apiwork::Schema::Base
    # Still maps to Invoice model
  end
end
```

Override explicitly when needed:

```ruby
class AuthorSchema < Apiwork::Schema::Base
  model User
end
```

[Inference](./inference.md) explains all the detection rules for types, nullability, defaults, and enum values.

## Connecting to Contract

Use `schema!` to connect a contract to its schema:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!  # Connects to InvoiceSchema
end
```

With `schema!`, Apiwork auto-generates request bodies, response shapes, filter types, sort options and includes — all from the schema definition.

At runtime, the [Execution Engine](../execution-engine/introduction.md) interprets these definitions and handles validation, querying, and serialization automatically.

## Schemas as Instructions

Schemas are purely declarative — they describe *what* exists, not *how* to process it. The [Execution Engine](../execution-engine/introduction.md) interprets your schema and handles everything: building contracts, validating requests, querying the database, and serializing responses.

The same schema definitions that say "this field exists" also tell the Execution Engine:

- Which fields are safe to [filter](../execution-engine/filtering.md) on
- Which attributes can be [sorted](../execution-engine/sorting.md) by
- How results are [paginated](../execution-engine/pagination.md)
- Which associations can be [included](../execution-engine/includes.md)
- How nested writes should be handled

You describe your domain once — in a schema aligned with your model — and the Execution Engine uses those instructions for all API behavior.

## Root Key

Every schema has a root key that the adapter can use to wrap request and response data. By default, Apiwork derives it from the model name:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
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

Request bodies follow the same pattern — create and update payloads are wrapped in the singular root key. See [Serialization](../execution-engine/serialization.md) for details on how the adapter transforms data.

Override when you need a different name:

```ruby
class PostSchema < Apiwork::Schema::Base
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

If configuring inflections isn't an option, or you want to keep it local to the schema, pass both forms:

```ruby
class CactusSchema < Apiwork::Schema::Base
  root :cactus, :cacti
end
```

## Schema Metadata

Add documentation to your schema for export generation:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  description "Represents a customer invoice with line items"
  example { id: "inv_123", number: "INV-2024-001", total: "99.00" }
  deprecated  # Mark the entire type as deprecated
end
```

| Method        | Description                                            |
| ------------- | ------------------------------------------------------ |
| `description` | Human-readable description for OpenAPI/TypeScript docs |
| `example`     | Example value shown in generated exports               |
| `deprecated`  | Mark the schema type as deprecated                     |

These appear in the generated `invoice` type definition.

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

## Schemas as Behavior Hints

Beyond describing what to render, schemas act as behavior hints for the API layer. The same definitions that say "this field is exposed" also decide:

- Which fields are safe to filter on
- Which attributes can be sorted by
- Which relations can be eagerly loaded
- How nested writes should be handled

You describe your domain once — in a schema aligned with your model — and Apiwork uses that for both serialization and API behavior.

## Root Key

Override the default root key:

```ruby
class PostSchema < Apiwork::Schema::Base
  root :article, :articles
end
```

Responses use `article` for single objects and `articles` for collections.

## Schema Metadata

Add documentation to your schema for spec generation:

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
| `example`     | Example value shown in generated specs                 |
| `deprecated`  | Mark the schema type as deprecated                     |

These appear in the generated `invoice` type definition.

---
order: 2
---

# Declaration

How to declare associations, what Apiwork detects automatically, and how responses are structured.

## Association Types

| Type         | Cardinality | API Response |
| ------------ | ----------- | ------------ |
| `has_one`    | Single      | Object       |
| `has_many`   | Multiple    | Array        |
| `belongs_to` | Single      | Object       |

## Basic Declaration

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  belongs_to :customer
  has_many :items
  has_one :receipt
end
```

## Options Reference

| Option          | Type            | Default     | Description                              |
| --------------- | --------------- | ----------- | ---------------------------------------- |
| `representation`| Class           | auto        | Associated representation class          |
| `include`       | Symbol          | `:optional` | `:always` or `:optional` ([details](./include-modes.md)) |
| `writable`      | `bool` / `symbol` | `false`   | Allow nested attributes ([details](./writable.md)) |
| `filterable`    | `bool`          | `false`     | Mark as filterable (adapter-dependent)   |
| `sortable`      | `bool`          | `false`     | Mark as sortable (adapter-dependent)     |
| `nullable`      | `bool`          | auto        | Allow null (auto-detected from DB)       |
| `polymorphic`   | Array           | `nil`       | Polymorphic type mapping ([details](./polymorphic.md)) |
| `description`   | `string`        | `nil`       | API documentation                        |
| `example`       | `any`           | `nil`       | Example value                            |
| `deprecated`    | `bool`          | `false`     | Mark as deprecated                       |

`filterable` and `sortable` are declarations — the adapter interprets them at runtime. See your adapter's documentation for query syntax.

::: tip Standard Adapter
The [Standard Adapter](../../adapters/standard-adapter/introduction.md) supports nested [filtering](../../adapters/standard-adapter/filtering.md) and [sorting](../../adapters/standard-adapter/sorting.md) on marked associations.
:::

## Auto-Detection

Representation and nullable are inferred from your model and database.

```ruby
# These are equivalent:
has_many :items
has_many :items, representation: ItemRepresentation
```

For non-standard names, specify explicitly:

```ruby
has_many :recent_invoices, representation: InvoiceRepresentation
```

## Response Structure

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :number
  belongs_to :customer
  has_many :items
end
```

```json
{
  "invoice": {
    "number": "INV-001",
    "customer": {
      "id": "1",
      "name": "Acme Corp"
    },
    "items": [
      {
        "id": "1",
        "description": "Consulting"
      },
      {
        "id": "2",
        "description": "Development"
      }
    ]
  }
}
```

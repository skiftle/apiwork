---
order: 2
---

# Declaration

Associations are declared with type information that Apiwork auto-detects from the model.

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

| Option          | Type            | Default     | Applies to              | Description                              |
| --------------- | --------------- | ----------- | ----------------------- | ---------------------------------------- |
| `representation`| Class           | auto        | all                     | Associated representation class          |
| `include`       | Symbol          | `:optional` | all                     | `:always` or `:optional` ([details](./include-modes.md)) |
| `writable`      | `bool` / `symbol` | `false`   | all                     | Allow nested writes ([details](./writable.md)) |
| `filterable`    | `bool`          | `false`     | all                     | Mark as filterable (adapter-dependent)   |
| `sortable`      | `bool`          | `false`     | all                     | Mark as sortable (adapter-dependent)     |
| `nullable`      | `bool`          | auto        | `belongs_to`, `has_one` | Allow null (auto-detected from DB)       |
| `polymorphic`   | Array           | `nil`       | `belongs_to`            | Polymorphic type mapping ([details](./polymorphic.md)) |
| `description`   | `string`        | `nil`       | all                     | API documentation                        |
| `example`       | `any`           | `nil`       | all                     | Example value                            |
| `deprecated`    | `bool`          | `false`     | all                     | Mark as deprecated                       |

`filterable` and `sortable` are declarations — the adapter interprets them at runtime. See the adapter documentation for query syntax.

::: tip
The [Standard Adapter](../../adapters/standard-adapter/) supports nested [filtering](../../adapters/standard-adapter/filtering.md) and [sorting](../../adapters/standard-adapter/sorting.md) on marked associations.
:::

## Auto-Detection

Representation and nullable are detected from the model and database.

```ruby
# These are equivalent:
has_many :items
has_many :items, representation: ItemRepresentation
```

For non-standard names, specify explicitly:

```ruby
has_many :recent_invoices, representation: InvoiceRepresentation
```

## Response Shape

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

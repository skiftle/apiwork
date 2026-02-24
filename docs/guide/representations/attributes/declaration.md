---
order: 2
---

# Declaration

Attributes are declared with type information that Apiwork auto-detects from the database.

## Basic Declaration

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :number
  attribute :status
  attribute :issued_on
  attribute :total
end
```

## Auto-Detection

Apiwork automatically detects from the database and model:

| Property | Source |
|----------|--------|
| `type` | Column type (string, integer, boolean, datetime, etc.) |
| `nullable` | Column NULL constraint |
| `optional` | Column allows NULL or has default value |
| `enum` | Rails enum definition |

```ruby
# These are equivalent:
attribute :title
attribute :title, type: :string, nullable: false

# Enum auto-detection
attribute :status  # Detects Rails enum values automatically
```

Types, nullability, and enums are detected from the database and models.

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `type` | `symbol` | auto | Data type |
| `nullable` | `bool` | auto | Allow null values |
| `optional` | `bool` | auto | Optional in requests |
| `writable` | `bool` / `symbol` | `false` | Allow in create/update requests ([details](./writable.md)) |
| `filterable` | `bool` | `false` | Mark as filterable (adapter-dependent) |
| `sortable` | `bool` | `false` | Mark as sortable (adapter-dependent) |
| `preload` | `symbol` / `array` / `hash` | `nil` | Associations to eager load ([details](./custom.md#preloading)) |
| `encode` | `callable` | `nil` | Transform on response ([details](./encode-decode.md)) |
| `decode` | `callable` | `nil` | Transform on request ([details](./encode-decode.md)) |
| `enum` | `array` | auto | Enum values ([details](../inference.md#enums)) |
| `empty` | `bool` | `false` | Convert nil to empty string ([details](./encode-decode.md#empty-nullable)) |
| `format` | `symbol` | `nil` | Format hint ([details](./metadata.md#format)) |
| `min` / `max` | `integer` | `nil` | Value/length constraints |
| `description` | `string` | `nil` | API documentation ([details](./metadata.md)) |
| `example` | `any` | `nil` | Example value ([details](./metadata.md)) |
| `deprecated` | `bool` | `false` | Mark as deprecated ([details](./metadata.md)) |

`filterable` and `sortable` are declarations — the adapter interprets them at runtime. See the adapter documentation for query syntax and supported operators.

::: tip
The [Standard Adapter](../../adapters/standard-adapter/) supports [filtering](../../adapters/standard-adapter/filtering.md) and [sorting](../../adapters/standard-adapter/sorting.md) on marked attributes.
:::

## Batch Configuration

`with_options` applies options to multiple attributes:

```ruby
class ScheduleRepresentation < Apiwork::Representation::Base
  with_options filterable: true, sortable: true do
    attribute :id
    attribute :status
    attribute :created_at
    attribute :updated_at

    with_options writable: true do
      attribute :name
      attribute :starts_on
      attribute :ends_on
    end
  end

  attribute :archived_at
end
```

Nested blocks inherit and merge options. In the example above:
- `id`, `status`, `created_at`, `updated_at` are filterable + sortable
- `name`, `starts_on`, `ends_on` are filterable + sortable + writable
- `archived_at` has no options

::: tip
`with_options` is provided by [ActiveSupport](https://api.rubyonrails.org/classes/Object.html#method-i-with_options) and works with any method that accepts keyword arguments.
:::

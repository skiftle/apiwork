---
order: 1
---

# Attributes

Attributes define which model fields are exposed in your API. Each attribute can be configured for reading, writing, filtering, and sorting.

## Basic Declaration

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title
  attribute :body
  attribute :published
  attribute :created_at
end
```

## Auto-Detection

Apiwork automatically detects from your database and model:

| Property | Source |
|----------|--------|
| `type` | Column type (string, integer, boolean, datetime, etc.) |
| `nullable` | Column NULL constraint |
| `required` | Column NOT NULL and no default value |
| `enum` | Rails enum definition |

```ruby
# These are equivalent:
attribute :title
attribute :title, type: :string, nullable: false, required: true

# Enum auto-detection
attribute :status  # Detects Rails enum values automatically
```

See [Inference](../inference.md) for complete details.

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| [`writable`](./writable.md) | `bool` / `hash` | `false` | Allow in create/update requests |
| [`filterable`](./filtering.md) | `bool` | `false` | Enable filtering |
| [`sortable`](./sorting.md) | `bool` | `false` | Enable sorting |
| [`encode`](./encode-decode.md) | `callable` | `nil` | Transform on response |
| [`decode`](./encode-decode.md) | `callable` | `nil` | Transform on request |
| [`empty`](./empty-nullable.md) | `bool` | `false` | Convert nil to empty string |
| [`nullable`](./empty-nullable.md) | `bool` | auto | Allow null values |
| `required` | `bool` | auto | Required in requests |
| `type` | `symbol` | auto | Data type |
| [`format`](./metadata.md#format) | `symbol` | `nil` | Format hint (email, uuid, etc.) |
| `min` / `max` | `integer` | `nil` | Value/length constraints |
| [`description`](./metadata.md) | `string` | `nil` | API documentation |
| [`example`](./metadata.md) | `any` | `nil` | Example value |
| [`deprecated`](./metadata.md) | `bool` | `false` | Mark as deprecated |

## Batch Configuration

Use `with_options` to apply options to multiple attributes:

```ruby
class PostSchema < Apiwork::Schema::Base
  with_options writable: true, filterable: true do
    attribute :title
    attribute :body
    attribute :status
  end

  attribute :created_at, sortable: true
end
```

## Computed Attributes

Attributes don't need to map to model columns. Define a method with the same name:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :full_title, type: :string

  def full_title
    "#{object.status.upcase}: #{object.title}"
  end
end
```

The `object` method returns the current model instance.

## Detailed Guides

- [Writable](./writable.md) - Create and update payloads
- [Filtering](./filtering.md) - Filter operators and types
- [Sorting](./sorting.md) - Sort configuration
- [Encode & Decode](./encode-decode.md) - Value transformers
- [Empty & Nullable](./empty-nullable.md) - Null handling patterns
- [Metadata](./metadata.md) - Documentation options

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

Apiwork automatically detects from your model:

| Property | Source |
|----------|--------|
| `type` | Column type (string, integer, boolean, datetime, etc.) |
| `nullable` | Column allows NULL |
| `required` | Column NOT NULL and no default value |
| `enum` | Rails enum definition |

```ruby
# These are equivalent:
attribute :title
attribute :title, type: :string, nullable: false, required: true

# Enum auto-detection
attribute :status  # Detects Rails enum values automatically
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `writable` | `bool` / `hash` | `false` | Allow in create/update requests |
| `filterable` | `bool` | `false` | Enable filtering |
| `sortable` | `bool` | `false` | Enable sorting |
| `encode` | `callable` | `nil` | Transform on response |
| `decode` | `callable` | `nil` | Transform on request |
| `empty` | `bool` | `false` | Convert nil to empty string |
| `nullable` | `bool` | auto | Allow null values |
| `required` | `bool` | auto | Required in requests |
| `type` | `symbol` | auto | Data type |
| `format` | `symbol` | `nil` | Format hint (email, uuid, etc.) |
| `min` / `max` | `integer` | `nil` | Value/length constraints |
| `description` | `string` | `nil` | API documentation |
| `example` | `any` | `nil` | Example value |
| `deprecated` | `bool` | `false` | Mark as deprecated |

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

- [Writable](./02-writable.md) - Create and update payloads
- [Filtering](./03-filtering.md) - Filter operators and types
- [Sorting](./04-sorting.md) - Sort configuration
- [Encode & Decode](./05-encode-decode.md) - Value transformers
- [Empty & Nullable](./06-empty-nullable.md) - Null handling patterns
- [Metadata](./07-metadata.md) - Documentation options

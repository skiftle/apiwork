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

See [Inference](../07-inference.md) for complete details.

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| [`writable`](./02-writable.md) | `bool` / `hash` | `false` | Allow in create/update requests |
| [`filterable`](./03-filtering.md) | `bool` | `false` | Enable filtering |
| [`sortable`](./04-sorting.md) | `bool` | `false` | Enable sorting |
| [`encode`](./05-encode-decode.md) | `callable` | `nil` | Transform on response |
| [`decode`](./05-encode-decode.md) | `callable` | `nil` | Transform on request |
| [`empty`](./06-empty-nullable.md) | `bool` | `false` | Convert nil to empty string |
| [`nullable`](./06-empty-nullable.md) | `bool` | auto | Allow null values |
| `required` | `bool` | auto | Required in requests |
| `type` | `symbol` | auto | Data type |
| [`format`](./07-metadata.md#format) | `symbol` | `nil` | Format hint (email, uuid, etc.) |
| `min` / `max` | `integer` | `nil` | Value/length constraints |
| [`description`](./07-metadata.md) | `string` | `nil` | API documentation |
| [`example`](./07-metadata.md) | `any` | `nil` | Example value |
| [`deprecated`](./07-metadata.md) | `bool` | `false` | Mark as deprecated |

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

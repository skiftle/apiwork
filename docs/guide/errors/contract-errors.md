---
order: 3
---

# Contract Errors

Contract errors occur when a request violates the declared API contract. The request shape, query parameters, or body doesn't match what the API specifies.

These errors are client-correctable — following the API specification avoids them.

Contract validation happens before controller code runs. The request never reaches models.

## HTTP Status

**400 Bad Request** — The request was malformed. Fix it before retrying.

```ruby
class PostContract < Apiwork::Contract::Base
  action :create do
    request do
      body do
        string :title
        string? :status, enum: %w[draft published]
      end
    end
  end
end
```

## Error Codes

| Code               | Detail            | Meta                              |
| ------------------ | ----------------- | --------------------------------- |
| `field_missing`    | Required          | `field`, `type`                   |
| `field_unknown`    | Unknown field     | `field`, `allowed`                |
| `type_invalid`     | Invalid type      | `field`, `expected`, `actual`     |
| `value_invalid`    | Invalid value     | `field`, `expected`, `actual`     |
| `value_null`       | Cannot be null    | `field`, `type`                   |
| `string_too_short` | Too short         | `field`, `min`, `actual`          |
| `string_too_long`  | Too long          | `field`, `max`, `actual`          |
| `number_too_small` | Too small         | `field`, `min`, `actual`          |
| `number_too_large` | Too large         | `field`, `max`, `actual`          |
| `array_too_small`  | Too few items     | `min`, `actual`                   |
| `array_too_large`  | Too many items    | `max`, `actual`                   |
| `depth_exceeded`   | Too deeply nested | `depth`, `max`                    |

## Examples

### field_missing

```json
{
  "layer": "contract",
  "code": "field_missing",
  "detail": "Required",
  "path": ["post", "title"],
  "pointer": "/post/title",
  "meta": {
    "field": "title",
    "type": "string"
  }
}
```

### type_invalid

```json
{
  "layer": "contract",
  "code": "type_invalid",
  "detail": "Invalid type",
  "path": ["post", "title"],
  "pointer": "/post/title",
  "meta": {
    "field": "title",
    "expected": "string",
    "actual": "integer"
  }
}
```

### string_too_short

```ruby
string :title, min: 5, max: 100
```

```json
{
  "layer": "contract",
  "code": "string_too_short",
  "detail": "Too short",
  "path": ["post", "title"],
  "pointer": "/post/title",
  "meta": {
    "actual": 3,
    "field": "title",
    "min": 5
  }
}
```

## Nested Objects

Contract errors include the full path to the problematic param:

```ruby
action :create do
  request do
    body do
      object :post do
        object :metadata do
          uuid :author_id
        end
      end
    end
  end
end
```

Missing `author_id`:

```json
{
  "layer": "contract",
  "code": "field_missing",
  "detail": "Required",
  "path": ["post", "metadata", "author_id"],
  "pointer": "/post/metadata/author_id",
  "meta": {
    "field": "author_id",
    "type": "uuid"
  }
}
```

## Arrays

Array items include their index in the path:

```ruby
action :create do
  request do
    body do
      array :items do
        object do
          string :sku
          integer :quantity
        end
      end
    end
  end
end
```

If the third item is missing `quantity`:

```json
{
  "layer": "contract",
  "code": "field_missing",
  "detail": "Required",
  "path": ["items", 2, "quantity"],
  "pointer": "/items/2/quantity",
  "meta": {
    "field": "quantity",
    "type": "integer"
  }
}
```

## Union Types

For discriminated unions, errors point to the discriminator or the variant params:

```ruby
union :content, discriminator: :type do
  variant tag: 'text' do
    object do
      string :body
    end
  end
  variant tag: 'image' do
    object do
      string :url
    end
  end
end
```

Invalid discriminator value:

```json
{
  "layer": "contract",
  "code": "value_invalid",
  "detail": "Invalid value",
  "path": ["content", "type"],
  "pointer": "/content/type",
  "meta": {
    "field": "type",
    "expected": ["text", "image"],
    "actual": "video"
  }
}
```

#### See also

- [Issue reference](../../reference/issue.md) — issue object shape

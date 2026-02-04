---
order: 3
---

# Contract Errors

Contract errors occur when a request violates the declared API contract. The request shape, query parameters, or body doesn't match what the API specifies.

These errors are client-correctable — following the API specification avoids them.

Contract validation happens before your controller code runs. The request never reaches your models.

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

### Request Body Errors

| Code               | Detail            | Meta                              |
| ------------------ | ----------------- | --------------------------------- |
| `field_missing`    | Required          | `field`, `type`                   |
| `field_unknown`    | Unknown field     | `field`, `allowed`                |
| `type_invalid`     | Invalid type      | `field`, `expected`, `actual`     |
| `value_invalid`    | Invalid value     | `field`, `expected`, `actual`     |
| `value_null`       | Cannot be null    | `field`, `type`                   |
| `string_too_short` | Too short         | `field`, `min`, `actual`          |
| `string_too_long`  | Too long          | `field`, `max`, `actual`          |
| `array_too_small`  | Too few items     | `min`, `actual`                   |
| `array_too_large`  | Too many items    | `max`, `actual`                   |
| `depth_exceeded`   | Too deeply nested | `depth`, `max`                    |

### Pagination Errors

| Code              | Detail          | Meta     |
| ----------------- | --------------- | -------- |
| `cursor_invalid`  | Invalid cursor  | `cursor` |

## Meta Reference

### Request Body

#### field_missing

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

#### field_unknown

```json
{
  "layer": "contract",
  "code": "field_unknown",
  "detail": "Unknown field",
  "path": ["post", "foo"],
  "pointer": "/post/foo",
  "meta": {
    "field": "foo",
    "allowed": ["title", "body", "status"]
  }
}
```

#### type_invalid

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

#### value_invalid

```json
{
  "layer": "contract",
  "code": "value_invalid",
  "detail": "Invalid value",
  "path": ["post", "status"],
  "pointer": "/post/status",
  "meta": {
    "field": "status",
    "expected": ["draft", "published"],
    "actual": "archived"
  }
}
```

#### value_null

```json
{
  "layer": "contract",
  "code": "value_null",
  "detail": "Cannot be null",
  "path": ["post", "title"],
  "pointer": "/post/title",
  "meta": {
    "field": "title",
    "type": "string"
  }
}
```

#### string_too_short

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
    "field": "title",
    "actual": 3,
    "min": 5
  }
}
```

#### array_too_large

```ruby
array :tags, min: 1, max: 10 do
  string
end
```

```json
{
  "layer": "contract",
  "code": "array_too_large",
  "detail": "Too many items",
  "path": ["post", "tags"],
  "pointer": "/post/tags",
  "meta": {
    "max": 10,
    "actual": 15
  }
}
```

#### depth_exceeded

```json
{
  "layer": "contract",
  "code": "depth_exceeded",
  "detail": "Too deeply nested",
  "path": ["deeply", "nested", "structure"],
  "pointer": "/deeply/nested/structure",
  "meta": {
    "depth": 11,
    "max": 10
  }
}
```

### Pagination

#### cursor_invalid

```json
{
  "layer": "contract",
  "code": "cursor_invalid",
  "detail": "Invalid cursor",
  "path": ["page"],
  "pointer": "/page",
  "meta": {
    "cursor": "invalid-cursor-value"
  }
}
```

## Nested Objects

Contract errors include the full path to the problematic field:

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

For discriminated unions, errors point to the discriminator or the variant fields:

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

## Query Parameter Syntax

### Filter Syntax

Filters use nested object syntax:

```http
GET /posts?filter[status][eq]=published
GET /posts?filter[created_at][gte]=2024-01-01
GET /posts?filter[tags][in][]=ruby&filter[tags][in][]=rails
```

### Sort Syntax

Sort uses bracket notation:

```http
GET /posts?sort[created_at]=asc
GET /posts?sort[created_at]=desc
GET /posts?sort[status]=asc&sort[created_at]=desc
```

## Output Validation

Responses are also validated against the contract in **development mode**. This catches server-side bugs where your controller returns data that doesn't match the contract.

```ruby
class PostContract < Apiwork::Contract::Base
  action :show do
    response do
      body do
        string :status, enum: %w[draft published]
      end
    end
  end
end
```

If your controller returns a post with `status: "archived"` (not in the enum), Apiwork logs a warning:

```text
[Apiwork] Response validation warning: value_invalid at /post/status
  Expected one of: draft, published
  Actual: archived
```

Output validation:
- Only runs in `Rails.env.development?`
- Logs warnings to Rails logger — does not block the response
- Validates the same constraints as request validation (types, enums, required fields)
- Helps catch bugs where schema changes haven't been reflected in the contract

::: tip
If you see output validation warnings, update your contract enum values or fix the data being returned by your controller.
:::

#### See also

- [Issue reference](../../../reference/issue.md) — issue object structure

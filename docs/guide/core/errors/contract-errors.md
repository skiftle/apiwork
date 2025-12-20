---
order: 2
---

# Contract Errors

Contract errors occur when an incoming request doesn't match the contract definition. They're caught before your controller code runs, preventing malformed data from reaching your models.

## When They Happen

A `ContractError` is raised during the `before_action` that validates the request. If the contract defines a required field and it's missing, or a field has the wrong type, the request is rejected immediately.

```ruby
class PostContract < Apiwork::Contract::Base
  action :create do
    request do
      body do
        param :title, type: :string
        param :status, type: :string, enum: %w[draft published], optional: true
      end
    end
  end
end
```

## Error Codes

Contract validation produces these issue codes:

### `field_missing`

A required field is absent or blank:

```json
{
  "code": "field_missing",
  "detail": "Field required",
  "path": ["post", "title"],
  "pointer": "/post/title",
  "meta": { "field": "title" }
}
```

### `field_unknown`

The request contains a field not defined in the contract:

```json
{
  "code": "field_unknown",
  "detail": "Unknown field",
  "path": ["post", "foo"],
  "pointer": "/post/foo",
  "meta": { "field": "foo", "allowed": ["title", "body", "status"] }
}
```

### `invalid_type`

The value doesn't match the expected type:

```json
{
  "code": "invalid_type",
  "detail": "Invalid type",
  "path": ["post", "title"],
  "pointer": "/post/title",
  "meta": { "field": "title", "expected": "string", "actual": "integer" }
}
```

### `invalid_value`

The value doesn't match enum constraints or other value restrictions:

```json
{
  "code": "invalid_value",
  "detail": "Invalid value. Must be one of: draft, published",
  "path": ["post", "status"],
  "pointer": "/post/status",
  "meta": { "field": "status", "expected": ["draft", "published"], "actual": "archived" }
}
```

### `value_null`

A field explicitly marked `nullable: false` received null:

```json
{
  "code": "value_null",
  "detail": "Value cannot be null",
  "path": ["post", "title"],
  "pointer": "/post/title",
  "meta": { "field": "title" }
}
```

### `string_too_short` / `string_too_long`

String length constraints violated:

```ruby
param :title, type: :string, min: 5, max: 100
```

```json
{
  "code": "string_too_short",
  "detail": "String must be at least 5 characters",
  "path": ["post", "title"],
  "pointer": "/post/title",
  "meta": { "field": "title", "actual_length": 3, "min_length": 5 }
}
```

### `array_too_large` / `array_too_small`

Array length constraints violated:

```ruby
param :tags, type: :array, of: :string, min: 1, max: 10
```

```json
{
  "code": "array_too_large",
  "detail": "Array exceeds maximum length",
  "path": ["post", "tags"],
  "pointer": "/post/tags",
  "meta": { "max": 10, "actual": 15 }
}
```

### `max_depth_exceeded`

Nested structures exceed the maximum validation depth (default 10):

```json
{
  "code": "max_depth_exceeded",
  "detail": "Max depth exceeded",
  "path": ["deeply", "nested", "structure"],
  "pointer": "/deeply/nested/structure",
  "meta": { "depth": 11, "max_depth": 10 }
}
```

## Nested Objects

Contract errors include the full path to the problematic field:

```ruby
action :create do
  request do
    body do
      param :post, type: :object do
        param :metadata, type: :object do
          param :author_id, type: :uuid
        end
      end
    end
  end
end
```

Missing `author_id`:

```json
{
  "code": "field_missing",
  "detail": "Field required",
  "path": ["post", "metadata", "author_id"],
  "pointer": "/post/metadata/author_id",
  "meta": { "field": "author_id" }
}
```

## Arrays

Array items include their index in the path:

```ruby
action :create do
  request do
    body do
      param :items, type: :array do
        param :sku, type: :string
        param :quantity, type: :integer
      end
    end
  end
end
```

If the third item is missing `quantity`:

```json
{
  "code": "field_missing",
  "detail": "Field required",
  "path": ["items", 2, "quantity"],
  "pointer": "/items/2/quantity",
  "meta": { "field": "quantity" }
}
```

## Union Types

For discriminated unions, errors point to the discriminator or the variant fields:

```ruby
param :content, type: :union, discriminator: :type do
  variant :text, tag: 'text' do
    param :body, type: :string
  end
  variant :image, tag: 'image' do
    param :url, type: :string
  end
end
```

Invalid discriminator value:

```json
{
  "code": "invalid_value",
  "detail": "Invalid discriminator value. Must be one of: text, image",
  "path": ["content", "type"],
  "pointer": "/content/type",
  "meta": { "field": "type", "expected": ["text", "image"], "actual": "video" }
}
```

## HTTP Status

Contract errors return **400 Bad Request**. This indicates a client error — the request was malformed and should be corrected before retrying.

## Output Validation

Responses are also validated against the contract in **development mode**. This catches server-side bugs where your controller returns data that doesn't match the contract.

```ruby
class PostContract < Apiwork::Contract::Base
  action :show do
    response do
      body do
        param :status, type: :string, enum: %w[draft published]
      end
    end
  end
end
```

If your controller returns a post with `status: "archived"` (not in the enum), Apiwork logs a warning:

```text
[Apiwork] Response validation warning: invalid_value at /post/status
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

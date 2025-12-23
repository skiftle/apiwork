---
order: 3
---

# Contract Errors

Contract errors occur when a request violates the declared API contract. The request shape, query parameters, or body doesn't match what the API specifies.

These errors are **fully client-correctable** — if the client follows the API specification, the error will not occur.

Contract validation happens before your controller code runs. The request never reaches your models.

## HTTP Status

**400 Bad Request** — The request was malformed. Fix it before retrying.

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

### Filter Errors

| Code                        | Detail                   | Meta                          |
| --------------------------- | ------------------------ | ----------------------------- |
| `field_not_filterable`      | Not filterable           | `field`, `available`          |
| `operator_invalid`          | Invalid operator         | `field`, `operator`, `allowed`|
| `filter_value_invalid`      | Invalid filter value     | `field`, `type`, `allowed`    |
| `enum_invalid`              | Invalid enum value       | `field`, `value`, `allowed`   |
| `date_invalid`              | Invalid date             | `field`, `value`              |
| `number_invalid`            | Invalid number           | `field`, `value`              |
| `value_null`                | Cannot be null           | `field`                       |
| `column_unknown`            | Unknown column type      | `field`                       |
| `column_unsupported`        | Unsupported column type  | `field`, `type`               |
| `association_not_found`     | Association not found    | `association`                 |
| `association_schema_missing`| Association schema missing| `association`                |

### Sort Errors

| Code                     | Detail             | Meta                              |
| ------------------------ | ------------------ | --------------------------------- |
| `sort_params_invalid`    | Invalid sort params| `type`                            |
| `field_not_sortable`     | Not sortable       | `field`, `available`              |
| `sort_value_invalid`     | Invalid sort value | `field`, `type`                   |
| `sort_direction_invalid` | Invalid direction  | `field`, `direction`, `allowed`   |
| `association_invalid`    | Invalid association| `field`                           |
| `association_not_sortable`| Not sortable      | `association`                     |

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
param :title, type: :string, min: 5, max: 100
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
param :tags, type: :array, of: :string, min: 1, max: 10
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

### Filters

#### field_not_filterable

```json
{
  "layer": "contract",
  "code": "field_not_filterable",
  "detail": "Not filterable",
  "path": ["filter", "body"],
  "pointer": "/filter/body",
  "meta": {
    "field": "body",
    "available": ["title", "status"]
  }
}
```

#### operator_invalid

```json
{
  "layer": "contract",
  "code": "operator_invalid",
  "detail": "Invalid operator",
  "path": ["filter", "status", "contains"],
  "pointer": "/filter/status/contains",
  "meta": {
    "field": "status",
    "operator": "contains",
    "allowed": ["eq", "in"]
  }
}
```

#### filter_value_invalid

```json
{
  "layer": "contract",
  "code": "filter_value_invalid",
  "detail": "Invalid filter value",
  "path": ["filter", "status", "in"],
  "pointer": "/filter/status/in",
  "meta": {
    "field": "status",
    "type": "String",
    "allowed": ["Array"]
  }
}
```

#### enum_invalid

```json
{
  "layer": "contract",
  "code": "enum_invalid",
  "detail": "Invalid enum value",
  "path": ["filter", "status"],
  "pointer": "/filter/status",
  "meta": {
    "field": "status",
    "value": ["archived"],
    "allowed": ["draft", "published"]
  }
}
```

#### date_invalid

```json
{
  "layer": "contract",
  "code": "date_invalid",
  "detail": "Invalid date",
  "path": ["filter", "created_at"],
  "pointer": "/filter/created_at",
  "meta": {
    "field": "created_at",
    "value": "not-a-date"
  }
}
```

#### number_invalid

```json
{
  "layer": "contract",
  "code": "number_invalid",
  "detail": "Invalid number",
  "path": ["filter", "amount"],
  "pointer": "/filter/amount",
  "meta": {
    "field": "amount",
    "value": "abc"
  }
}
```

#### association_not_found

```json
{
  "layer": "contract",
  "code": "association_not_found",
  "detail": "Association not found",
  "path": ["filter", "author.name"],
  "pointer": "/filter/author.name",
  "meta": {
    "association": "author"
  }
}
```

### Sort

#### field_not_sortable

```json
{
  "layer": "contract",
  "code": "field_not_sortable",
  "detail": "Not sortable",
  "path": ["sort", "body"],
  "pointer": "/sort/body",
  "meta": {
    "field": "body",
    "available": ["title", "created_at"]
  }
}
```

#### sort_direction_invalid

```json
{
  "layer": "contract",
  "code": "sort_direction_invalid",
  "detail": "Invalid direction",
  "path": ["sort", "title"],
  "pointer": "/sort/title",
  "meta": {
    "field": "title",
    "direction": "up",
    "allowed": ["asc", "desc"]
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
        param :status, type: :string, enum: %w[draft published]
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

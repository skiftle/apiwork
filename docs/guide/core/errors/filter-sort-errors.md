---
order: 3
---

# Filter & Sort Errors

Filter and sort errors occur when query parameters for filtering or sorting collections are invalid. These errors are caught during collection loading, before your controller logic executes.

## When They Happen

A `ConstraintError` is raised when:
- A filter references a field that isn't filterable
- A filter uses an invalid operator for the field type
- Sort parameters have an invalid format
- A sort references a field that isn't sortable

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, filterable: true, sortable: true
  attribute :status, filterable: { operators: [:eq, :in] }
  attribute :body  # Not filterable or sortable
end
```

## Filter Error Codes

### `field_not_filterable`

The filter references a field that isn't marked as filterable:

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

### `operator_invalid`

The filter uses an operator not allowed for this field:

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

### `filter_value_invalid`

The filter value doesn't match the expected type:

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

### `enum_invalid`

The filter value isn't in the enum's allowed values:

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

### `date_invalid`

A date/datetime filter value has an invalid format:

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

### `number_invalid`

A numeric filter value can't be parsed:

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

### `value_null`

A filter that doesn't support null received null:

```json
{
  "layer": "contract",
  "code": "value_null",
  "detail": "Cannot be null",
  "path": ["filter", "title"],
  "pointer": "/filter/title",
  "meta": {
    "field": "title"
  }
}
```

### `column_unknown`

The database column type couldn't be determined:

```json
{
  "layer": "contract",
  "code": "column_unknown",
  "detail": "Unknown column type",
  "path": ["filter", "custom_field"],
  "pointer": "/filter/custom_field",
  "meta": {
    "field": "custom_field"
  }
}
```

### `column_unsupported`

The column type doesn't support filtering:

```json
{
  "layer": "contract",
  "code": "column_unsupported",
  "detail": "Unsupported column type",
  "path": ["filter", "data"],
  "pointer": "/filter/data",
  "meta": {
    "field": "data",
    "type": "binary"
  }
}
```

### `association_not_found`

A filter references an association that doesn't exist:

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

### `association_schema_missing`

The association exists but has no schema defined:

```json
{
  "layer": "contract",
  "code": "association_schema_missing",
  "detail": "Association schema missing",
  "path": ["filter", "author.name"],
  "pointer": "/filter/author.name",
  "meta": {
    "association": "author"
  }
}
```

## Sort Error Codes

### `sort_params_invalid`

The sort parameter isn't the expected type:

```json
{
  "layer": "contract",
  "code": "sort_params_invalid",
  "detail": "Invalid sort params",
  "path": ["sort"],
  "pointer": "/sort",
  "meta": {
    "type": "String"
  }
}
```

### `field_not_sortable`

The sort references a field that isn't marked as sortable:

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

### `sort_value_invalid`

A sort item has an invalid format:

```json
{
  "layer": "contract",
  "code": "sort_value_invalid",
  "detail": "Invalid sort value",
  "path": ["sort", "title"],
  "pointer": "/sort/title",
  "meta": {
    "field": "title",
    "type": "Array"
  }
}
```

### `sort_direction_invalid`

The sort direction isn't `asc` or `desc`:

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

### `association_invalid`

A sort references an association that doesn't exist:

```json
{
  "layer": "contract",
  "code": "association_invalid",
  "detail": "Invalid association",
  "path": ["sort", "author"],
  "pointer": "/sort/author",
  "meta": {
    "field": "author"
  }
}
```

### `association_not_sortable`

The association exists but isn't marked as sortable:

```json
{
  "layer": "contract",
  "code": "association_not_sortable",
  "detail": "Not sortable",
  "path": ["sort", "tags"],
  "pointer": "/sort/tags",
  "meta": {
    "association": "tags"
  }
}
```

## Pagination Error Codes

### `cursor_invalid`

The cursor value is malformed or can't be decoded:

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

## HTTP Status

Filter, sort, and pagination errors return **400 Bad Request**. These are client errors — the query parameters are invalid and should be corrected.

## Valid Filter Syntax

Filters use nested object syntax:

```http
GET /posts?filter[status][eq]=published
GET /posts?filter[created_at][gte]=2024-01-01
GET /posts?filter[tags][in][]=ruby&filter[tags][in][]=rails
```

## Valid Sort Syntax

Sort uses bracket notation:

```http
GET /posts?sort[created_at]=asc
GET /posts?sort[created_at]=desc
GET /posts?sort[status]=asc&sort[created_at]=desc
```

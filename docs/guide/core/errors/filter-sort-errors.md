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
  "code": "field_not_filterable",
  "detail": "Field 'body' is not filterable",
  "path": ["filter", "body"],
  "pointer": "/filter/body",
  "meta": {
    "field": "body"
  }
}
```

### `invalid_operator`

The filter uses an operator not allowed for this field:

```json
{
  "code": "invalid_operator",
  "detail": "Operator 'contains' is not allowed for field 'status'",
  "path": ["filter", "status", "contains"],
  "pointer": "/filter/status/contains",
  "meta": {
    "field": "status",
    "operator": "contains",
    "allowed": ["eq", "in"]
  }
}
```

### `invalid_filter_value_type`

The filter value doesn't match the expected type:

```json
{
  "code": "invalid_filter_value_type",
  "detail": "Expected array for 'in' operator",
  "path": ["filter", "status", "in"],
  "pointer": "/filter/status/in",
  "meta": {
    "operator": "in",
    "expected": "array"
  }
}
```

### `invalid_enum_value`

The filter value isn't in the enum's allowed values:

```json
{
  "code": "invalid_enum_value",
  "detail": "Invalid enum value 'archived'. Must be one of: draft, published",
  "path": ["filter", "status", "eq"],
  "pointer": "/filter/status/eq",
  "meta": {
    "value": "archived",
    "allowed": ["draft", "published"]
  }
}
```

### `invalid_date_format`

A date/datetime filter value has an invalid format:

```json
{
  "code": "invalid_date_format",
  "detail": "Invalid date format",
  "path": ["filter", "created_at", "gte"],
  "pointer": "/filter/created_at/gte",
  "meta": {
    "value": "not-a-date"
  }
}
```

### `invalid_numeric_format`

A numeric filter value can't be parsed:

```json
{
  "code": "invalid_numeric_format",
  "detail": "Invalid numeric value",
  "path": ["filter", "amount", "gte"],
  "pointer": "/filter/amount/gte",
  "meta": {
    "value": "abc"
  }
}
```

### `null_not_allowed`

A filter that doesn't support null received null:

```json
{
  "code": "null_not_allowed",
  "detail": "Null values not allowed for this operator",
  "path": ["filter", "title", "contains"],
  "pointer": "/filter/title/contains",
  "meta": {
    "operator": "contains"
  }
}
```

### `unknown_column_type`

The database column type couldn't be determined:

```json
{
  "code": "unknown_column_type",
  "detail": "Unknown column type for field 'custom_field'",
  "path": ["filter", "custom_field"],
  "pointer": "/filter/custom_field",
  "meta": {
    "field": "custom_field"
  }
}
```

### `unsupported_column_type`

The column type doesn't support filtering:

```json
{
  "code": "unsupported_column_type",
  "detail": "Column type 'binary' is not supported for filtering",
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
  "code": "association_not_found",
  "detail": "Association 'author' not found",
  "path": ["filter", "author.name"],
  "pointer": "/filter/author.name",
  "meta": {
    "association": "author"
  }
}
```

### `association_resource_not_found`

The association exists but has no schema defined:

```json
{
  "code": "association_resource_not_found",
  "detail": "No schema found for association 'author'",
  "path": ["filter", "author.name"],
  "pointer": "/filter/author.name",
  "meta": {
    "association": "author"
  }
}
```

## Sort Error Codes

### `invalid_sort_params_type`

The sort parameter isn't the expected type:

```json
{
  "code": "invalid_sort_params_type",
  "detail": "Sort parameter must be a string or array",
  "path": ["sort"],
  "pointer": "/sort",
  "meta": {
    "actual": "object"
  }
}
```

### `field_not_sortable`

The sort references a field that isn't marked as sortable:

```json
{
  "code": "field_not_sortable",
  "detail": "Field 'body' is not sortable",
  "path": ["sort"],
  "pointer": "/sort",
  "meta": {
    "field": "body"
  }
}
```

### `invalid_sort_value_type`

A sort item has an invalid format:

```json
{
  "code": "invalid_sort_value_type",
  "detail": "Sort value must be a string",
  "path": ["sort", 0],
  "pointer": "/sort/0",
  "meta": {}
}
```

### `invalid_sort_direction`

The sort direction isn't `asc` or `desc`:

```json
{
  "code": "invalid_sort_direction",
  "detail": "Invalid sort direction 'up'. Must be 'asc' or 'desc'",
  "path": ["sort"],
  "pointer": "/sort",
  "meta": {
    "field": "title",
    "direction": "up"
  }
}
```

### `invalid_association`

A sort references a malformed association path:

```json
{
  "code": "invalid_association",
  "detail": "Invalid association path",
  "path": ["sort"],
  "pointer": "/sort",
  "meta": {
    "value": "author..name"
  }
}
```

### `association_not_sortable`

The association exists but isn't marked as sortable:

```json
{
  "code": "association_not_sortable",
  "detail": "Association 'tags' is not sortable",
  "path": ["sort"],
  "pointer": "/sort",
  "meta": {
    "association": "tags"
  }
}
```

## Pagination Error Codes

### `invalid_cursor`

The cursor value is malformed or can't be decoded:

```json
{
  "code": "invalid_cursor",
  "detail": "Invalid cursor format",
  "path": ["page"],
  "pointer": "/page",
  "meta": {}
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

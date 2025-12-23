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
  "detail": "body is not a filterable attribute on Post. Available: title, status",
  "path": ["filter", "body"],
  "pointer": "/filter/body",
  "meta": {
    "field": "body",
    "class": "Post",
    "available": ["title", "status"]
  }
}
```

### `invalid_operator`

The filter uses an operator not allowed for this field:

```json
{
  "code": "invalid_operator",
  "detail": "Invalid operator 'contains' for status. Valid: eq, in",
  "path": ["filter", "status", "contains"],
  "pointer": "/filter/status/contains",
  "meta": {
    "field": "status",
    "operator": "contains",
    "valid_operators": ["eq", "in"]
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
  "detail": "Invalid status value(s): archived. Valid values: draft, published",
  "path": ["filter", "status"],
  "pointer": "/filter/status",
  "meta": {
    "field": "status",
    "invalid": ["archived"],
    "valid": ["draft", "published"]
  }
}
```

### `invalid_date_format`

A date/datetime filter value has an invalid format:

```json
{
  "code": "invalid_date_format",
  "detail": "'not-a-date' is not a valid date",
  "path": ["filter", "created_at"],
  "pointer": "/filter/created_at",
  "meta": {
    "field": "created_at",
    "value": "not-a-date"
  }
}
```

### `invalid_numeric_format`

A numeric filter value can't be parsed:

```json
{
  "code": "invalid_numeric_format",
  "detail": "'abc' is not a valid number",
  "path": ["filter", "amount"],
  "pointer": "/filter/amount",
  "meta": {
    "field": "amount",
    "value": "abc"
  }
}
```

### `null_not_allowed`

A filter that doesn't support null received null:

```json
{
  "code": "null_not_allowed",
  "detail": "title cannot be null",
  "path": ["filter", "title"],
  "pointer": "/filter/title",
  "meta": {
    "field": "title"
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
  "detail": "sort must be a Hash or Array of Hashes",
  "path": ["sort"],
  "pointer": "/sort",
  "meta": {
    "params_type": "String"
  }
}
```

### `field_not_sortable`

The sort references a field that isn't marked as sortable:

```json
{
  "code": "field_not_sortable",
  "detail": "body is not sortable on Post. Sortable: title, created_at",
  "path": ["sort", "body"],
  "pointer": "/sort/body",
  "meta": {
    "field": "body",
    "class": "Post",
    "available": ["title", "created_at"]
  }
}
```

### `invalid_sort_value_type`

A sort item has an invalid format:

```json
{
  "code": "invalid_sort_value_type",
  "detail": "Sort value must be 'asc', 'desc', or Hash for associations",
  "path": ["sort", "title"],
  "pointer": "/sort/title",
  "meta": {
    "field": "title",
    "value_type": "Array"
  }
}
```

### `invalid_sort_direction`

The sort direction isn't `asc` or `desc`:

```json
{
  "code": "invalid_sort_direction",
  "detail": "Invalid direction 'up'. Use 'asc' or 'desc'",
  "path": ["sort", "title"],
  "pointer": "/sort/title",
  "meta": {
    "field": "title",
    "direction": "up",
    "valid_directions": ["asc", "desc"]
  }
}
```

### `invalid_association`

A sort references an association that doesn't exist:

```json
{
  "code": "invalid_association",
  "detail": "author is not a valid association on Post",
  "path": ["sort", "author"],
  "pointer": "/sort/author",
  "meta": {
    "field": "author",
    "class": "Post"
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

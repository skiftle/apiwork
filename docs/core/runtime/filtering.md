---
order: 2
---

# Filtering

Filter records using query parameters. The runtime translates filters into ActiveRecord queries.

## Query Format

```
GET /posts?filter[status][eq]=published
```

Structure: `filter[field][operator]=value`

Multiple filters combine with AND:

```
GET /posts?filter[status][eq]=published&filter[views][gt]=100
```

## Operators by Type

### String

| Operator | SQL | Example |
|----------|-----|---------|
| `eq` | `= 'value'` | `filter[title][eq]=Hello` |
| `contains` | `LIKE '%value%'` | `filter[title][contains]=Rails` |
| `starts_with` | `LIKE 'value%'` | `filter[title][starts_with]=How` |
| `ends_with` | `LIKE '%value'` | `filter[title][ends_with]=Guide` |
| `in` | `IN (...)` | `filter[status][in][]=draft&filter[status][in][]=published` |
| `null` | `IS NULL` | `filter[subtitle][null]=true` |

### Numeric

| Operator | SQL | Example |
|----------|-----|---------|
| `eq` | `= value` | `filter[views][eq]=100` |
| `gt` | `> value` | `filter[views][gt]=100` |
| `gte` | `>= value` | `filter[views][gte]=100` |
| `lt` | `< value` | `filter[views][lt]=100` |
| `lte` | `<= value` | `filter[views][lte]=100` |
| `between` | `BETWEEN` | `filter[views][between][from]=10&filter[views][between][to]=100` |
| `in` | `IN (...)` | `filter[views][in][]=10&filter[views][in][]=20` |
| `null` | `IS NULL` | `filter[views][null]=true` |

### Date / DateTime

| Operator | SQL | Example |
|----------|-----|---------|
| `eq` | `= date` | `filter[created_at][eq]=2024-01-15` |
| `gt` | `> date` | `filter[created_at][gt]=2024-01-01` |
| `gte` | `>= date` | `filter[created_at][gte]=2024-01-01` |
| `lt` | `< date` | `filter[created_at][lt]=2024-12-31` |
| `lte` | `<= date` | `filter[created_at][lte]=2024-12-31` |
| `between` | `BETWEEN` | `filter[created_at][between][from]=2024-01-01&filter[created_at][between][to]=2024-12-31` |
| `in` | `IN (...)` | `filter[created_at][in][]=2024-01-01&filter[created_at][in][]=2024-06-15` |
| `null` | `IS NULL` | `filter[published_at][null]=true` |

Date values are parsed and expanded to full day ranges for datetime columns.

### Boolean

| Operator | SQL | Example |
|----------|-----|---------|
| `eq` | `= value` | `filter[published][eq]=true` |
| `null` | `IS NULL` | `filter[archived][null]=true` |

Accepts: `true`, `false`, `1`, `0`, `'true'`, `'false'`

### UUID

| Operator | SQL | Example |
|----------|-----|---------|
| `eq` | `= value` | `filter[id][eq]=550e8400-e29b-41d4-a716-446655440000` |
| `in` | `IN (...)` | `filter[id][in][]=uuid1&filter[id][in][]=uuid2` |
| `null` | `IS NULL` | `filter[external_id][null]=true` |

### Enum

Enum fields use the same operators as strings. Invalid values return an error with valid options:

```json
{
  "issues": [{
    "code": "invalid_enum_value",
    "detail": "Invalid value 'unknown' for status. Valid: draft, published, archived",
    "path": ["filter", "status", "eq"]
  }]
}
```

---

## Logical Operators

Combine filters with `_and`, `_or`, and `_not`.

### OR

Match posts with "Ruby" OR "Rails" in title:

```
GET /posts?filter[_or][0][title][contains]=Ruby&filter[_or][1][title][contains]=Rails
```

### AND

Explicit AND (default behavior):

```
GET /posts?filter[_and][0][status][eq]=published&filter[_and][1][views][gt]=100
```

### NOT

Exclude drafts:

```
GET /posts?filter[_not][status][eq]=draft
```

### Combining

Published posts with "Ruby" or "Rails":

```
GET /posts?filter[status][eq]=published&filter[_or][0][title][contains]=Ruby&filter[_or][1][title][contains]=Rails
```

---

## Association Filtering

Filter by fields on related records. The association must be marked `filterable: true`:

```ruby
class PostSchema < Apiwork::Schema::Base
  belongs_to :author, filterable: true
  has_many :comments, filterable: true
end
```

### Query Format

```
GET /posts?filter[author][name][eq]=Jane
GET /posts?filter[comments][approved][eq]=true
```

Structure: `filter[association][field][operator]=value`

### Nested Associations

```
GET /posts?filter[comments][author][role][eq]=moderator
```

### Auto-Join

The runtime automatically joins required tables. Filtering by an association includes it in the query.

---

## Null Handling

Use the `null` operator to check for NULL values:

```
GET /posts?filter[published_at][null]=true   # WHERE published_at IS NULL
GET /posts?filter[published_at][null]=false  # WHERE published_at IS NOT NULL
```

The `null` operator is only allowed on nullable columns. Non-nullable columns reject it:

```json
{
  "issues": [{
    "code": "null_not_allowed",
    "detail": "title does not allow null values",
    "path": ["filter", "title", "null"]
  }]
}
```

---

## Error Codes

| Code | Cause |
|------|-------|
| `field_not_filterable` | Field not marked `filterable: true` |
| `invalid_operator` | Operator not supported for field type |
| `invalid_date_format` | Date string couldn't be parsed |
| `invalid_numeric_format` | Value isn't a valid number |
| `invalid_enum_value` | Value not in enum list |
| `null_not_allowed` | `null` operator on non-nullable column |
| `association_not_found` | Association doesn't exist |
| `association_resource_not_found` | Association schema not resolvable |

All errors include available options in the response to aid debugging.

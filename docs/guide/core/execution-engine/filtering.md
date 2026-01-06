---
order: 3
---

# Filtering

Filter records using query parameters. The adapter translates filters into ActiveRecord queries.

## Query Format

```http
GET /posts?filter[status][eq]=published
```

Structure: `filter[field][operator]=value`

Multiple filters combine with AND:

```http
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

Date values like `2024-01-15` are expanded to cover the full day (`00:00:00` to `23:59:59`) when filtering datetime columns.

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

Enum fields support `eq` and `in` operators. You can also pass the value directly. Invalid values return an error with valid options:

```json
{
  "errors": [{
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

```http
GET /posts?filter[_or][0][title][contains]=Ruby&filter[_or][1][title][contains]=Rails
```

### AND

Explicit AND (default behavior):

```http
GET /posts?filter[_and][0][status][eq]=published&filter[_and][1][views][gt]=100
```

### NOT

Exclude drafts:

```http
GET /posts?filter[_not][status][eq]=draft
```

### Combining

Published posts with "Ruby" or "Rails":

```http
GET /posts?filter[status][eq]=published&filter[_or][0][title][contains]=Ruby&filter[_or][1][title][contains]=Rails
```

### Nesting

Logical operators can be nested for complex conditions:

```text
# (status = draft OR status = published) AND views > 100
GET /posts?filter[_and][0][_or][0][status][eq]=draft&filter[_and][0][_or][1][status][eq]=published&filter[_and][1][views][gt]=100
```

This generates:

```sql
WHERE (status = 'draft' OR status = 'published') AND views > 100
```

**NOT inside OR:**

```text
# title contains "Ruby" OR (NOT status = archived)
GET /posts?filter[_or][0][title][contains]=Ruby&filter[_or][1][_not][status][eq]=archived
```

**Multiple levels:**

```text
# (category = tech AND (status = draft OR status = review)) OR featured = true
GET /posts?filter[_or][0][_and][0][category][eq]=tech&filter[_or][0][_and][1][_or][0][status][eq]=draft&filter[_or][0][_and][1][_or][1][status][eq]=review&filter[_or][1][featured][eq]=true
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

```http
GET /posts?filter[author][name][eq]=Jane
GET /posts?filter[comments][approved][eq]=true
```

Structure: `filter[association][field][operator]=value`

### Nested Associations

```http
GET /posts?filter[comments][author][role][eq]=moderator
```

### Auto-Join

The adapter automatically joins required tables. Filtering by an association includes it in the query.

---

## Null Handling

Use the `null` operator to check for NULL values:

```http
GET /posts?filter[published_at][null]=true   # WHERE published_at IS NULL
GET /posts?filter[published_at][null]=false  # WHERE published_at IS NOT NULL
```

The `null` operator is only allowed on nullable columns. Non-nullable columns reject it:

```json
{
  "errors": [{
    "code": "null_not_allowed",
    "detail": "title does not allow null values",
    "path": ["filter", "title", "null"]
  }]
}
```

---

## Validation

Apiwork validates filter parameters in two layers:

::: info Contract Validates First
When you use `schema!`, the adapter generates typed filter definitions. The contract validates every request against these types **before the adapter runs**. Unknown fields, invalid operators, and type mismatches are rejected immediately.
:::

### What the Contract Catches

The contract layer handles most validation:

- **Unknown fields** — `filter[unknown_field]` rejected if not in schema
- **Invalid operators** — `filter[title][gt]` rejected (strings don't support `gt`)
- **Type mismatches** — `filter[amount][eq]=hello` rejected for numeric fields
- **Structure errors** — malformed filter objects

These errors return standard contract validation errors with codes like `invalid_type` and `field_unknown`.

### Adapter Validation

The adapter only validates edge cases that pass contract validation:

| Code | When It Fires |
|------|---------------|
| `invalid_date_format` | Date string couldn't be parsed (e.g., `2024-99-99`) |
| `invalid_numeric_format` | Number parsing fails at runtime |
| `invalid_enum_value` | Enum value changed in database after contract was built |
| `null_not_allowed` | `null` operator on non-nullable column |

These are rare — they only occur when values have the right type but fail parsing or business rules.

### Association Errors

These can occur when schema configuration is incomplete:

| Code | Cause |
|------|-------|
| `field_not_filterable` | Field exists but not marked `filterable: true` |
| `association_not_found` | Association doesn't exist on model |
| `association_resource_not_found` | Association schema couldn't be resolved |

All errors include available options in the response to aid debugging.

---

## Examples

See [Advanced Filtering](/examples/advanced-filtering.md) for complex query examples including logical operators and association filtering.

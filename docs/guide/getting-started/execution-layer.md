---
order: 5
---

# Execution Layer

When you call `respond`, Apiwork processes your data before serializing it. This is the execution layer, powered by Apiwork's adapter system.

::: tip
The execution layer only activates when your contract uses `schema!`. Without a schema, data is returned as-is — no filtering, sorting, or pagination.
:::

## How It Works

The adapter sits between your controller and the response. It reads query parameters from `contract.query` and applies them to your data:

```
Controller → respond(data) → Adapter → Schema → Response
```

What the adapter does depends on what you pass to `respond`:

### Collections

For ActiveRecord relations (typically in `index` actions), the full pipeline runs:

```
respond Post.all
    ↓
┌─────────────┐
│ 1. Filter   │  ← ?filter[status][eq]=published
│ 2. Sort     │  ← ?sort[created_at]=desc
│ 3. Paginate │  ← ?page[number]=2
│ 4. Includes │  ← ?include[author]=true + auto
└─────────────┘
    ↓
Schema serializes each record
    ↓
Response with pagination metadata
```

### Single Records

For individual records (typically in `show`, `create`, `update` actions), only includes are applied:

```
respond Post.find(params[:id])
    ↓
┌─────────────┐
│ Includes    │  ← ?include[author]=true
└─────────────┘
    ↓
Schema serializes the record
    ↓
Response
```

::: info
Filtering, sorting, and pagination only apply to collections. But eager loading works for both — you can request `?include[author]=true` on a show action too.
:::

## Filtering

Filter collections using query parameters. Each filterable field supports type-appropriate operators.

```bash
# Exact match
GET /posts?filter[status][eq]=published

# Comparison
GET /posts?filter[views][gt]=100
GET /posts?filter[created_at][gte]=2024-01-01

# String matching
GET /posts?filter[title][contains]=Rails
GET /posts?filter[title][starts_with]=How

# Range
GET /posts?filter[price][between][from]=10&filter[price][between][to]=100

# Multiple values
GET /posts?filter[status][in][]=draft&filter[status][in][]=published

# NULL checks
GET /posts?filter[deleted_at][null]=true
```

### Available Operators

| Operator | Types | Description |
|----------|-------|-------------|
| `eq` | All | Exact match |
| `gt`, `gte`, `lt`, `lte` | Numbers, dates | Comparisons |
| `contains` | Strings | Substring match |
| `starts_with`, `ends_with` | Strings | Prefix/suffix match |
| `in` | All | Match any value in list |
| `between` | Numbers, dates | Range with `from` and `to` |
| `null` | All | Check for NULL (`true`) or NOT NULL (`false`) |

### Logical Operators

Combine filters with `_and`, `_or`, and `_not`:

```bash
# OR: published OR featured
GET /posts?filter[_or][0][published][eq]=true&filter[_or][1][featured][eq]=true

# NOT: exclude drafts
GET /posts?filter[_not][status][eq]=draft
```

::: tip
A field must have `filterable: true` in the schema to be filterable. Non-filterable fields return an error.
:::

## Sorting

Sort by one or more fields:

```bash
# Single field
GET /posts?sort[created_at]=desc

# Multiple fields (applied in order)
GET /posts?sort[published]=desc&sort[created_at]=asc
```

Direction must be `asc` or `desc`.

::: tip
A field must have `sortable: true` in the schema to be sortable.
:::

## Pagination

Apiwork supports two pagination strategies: **offset** (default) and **cursor**.

### Offset Pagination

```bash
GET /posts?page[number]=2&page[size]=20
```

Response includes pagination metadata:

```json
{
  "posts": [...],
  "pagination": {
    "current": 2,
    "next": 3,
    "prev": 1,
    "total": 5,
    "items": 100
  }
}
```

- `current` — current page number
- `next` / `prev` — next/previous page (null if none)
- `total` — total number of pages
- `items` — total number of records

### Cursor Pagination

Better for large datasets. Instead of page numbers, you navigate with cursors:

```bash
# First page
GET /posts?page[size]=20

# Next page (use next_cursor from response)
GET /posts?page[after]=eyJpZCI6MTAwfQ&page[size]=20

# Previous page
GET /posts?page[before]=eyJpZCI6ODF9&page[size]=20
```

Response:

```json
{
  "posts": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTAwfQ",
    "prev_cursor": "eyJpZCI6ODF9"
  }
}
```

::: info
Cursors are opaque strings. Don't try to decode or construct them — just pass them back as-is.
:::

## Eager Loading

Control which associations are included in the response:

```bash
# Include author
GET /posts?include[author]=true

# Include multiple
GET /posts?include[author]=true&include[comments]=true

# Nested includes
GET /posts?include[comments][user]=true
```

### Automatic Eager Loading

Apiwork automatically eager loads associations to prevent N+1 queries:

1. **Always included** — associations marked `include: :always` in the schema
2. **Filter associations** — associations referenced in filter params
3. **Sort associations** — associations referenced in sort params

You don't need to think about N+1s — Apiwork handles it.

## Configuration

Configure the adapter at the API level:

```ruby
Apiwork::API.define '/api/v1' do
  adapter do
    pagination do
      strategy :offset    # or :cursor
      default_size 20
      max_size 100
    end
  end
end
```

Override for specific schemas:

```ruby
class PostSchema < ApplicationSchema
  adapter do
    pagination do
      strategy :cursor
      default_size 50
    end
  end
end
```

Schema settings override API settings.

## Response Metadata

Add custom metadata to any response:

```ruby
def index
  respond Post.all, meta: { generated_at: Time.current }
end
```

```json
{
  "posts": [...],
  "pagination": {...},
  "meta": {
    "generated_at": "2024-01-15T10:30:00Z"
  }
}
```

## The Built-in Adapter

Everything described above is handled by Apiwork's built-in adapter. It's designed around common assumptions in REST API design:

| Assumption | What the adapter does |
|------------|----------------------|
| Index endpoints list resources | Applies filtering, sorting, and pagination automatically |
| Show/create/update return one resource | Applies includes only |
| You're using ActiveRecord | Builds SQL queries directly on your relations |
| Standard query parameter format | `filter[field][op]`, `sort[field]`, `page[number]` |

These defaults work for most Rails APIs. But you have options if they don't fit:

### Override via Configuration

Adjust behavior at the API or schema level:

```ruby
# Change pagination defaults for the entire API
Apiwork::API.define '/api/v1' do
  adapter do
    pagination do
      strategy :cursor
      default_size 50
    end
  end
end

# Override for a specific resource
class PostSchema < ApplicationSchema
  adapter do
    pagination do
      default_size 10
    end
  end
end
```

### Build Your Own Adapter

If you need fundamentally different behavior — a different database, a different query format, or something entirely custom — you can implement your own adapter.

See [Custom Adapters](../advanced/custom-adapters.md) for details.

## Next Steps

- [Contracts](../core/contracts/introduction.md) — define request/response shapes
- [Schemas](../core/schemas/introduction.md) — control what's filterable, sortable, and included

---
order: 4
---

# Sorting

Order results using query parameters. Fields must be marked `sortable: true` in the schema.

## Query Format

```http
GET /posts?sort[created_at]=desc
```

Structure: `sort[field]=direction`

Direction: `asc` or `desc` (case-insensitive)

## Multi-Field Sorting

Sort by multiple fields in priority order:

```http
GET /posts?sort[published]=asc&sort[created_at]=desc
```

Or use array notation for explicit ordering:

```http
GET /posts?sort[0][published]=asc&sort[1][created_at]=desc
```

First sort takes precedence. Results are ordered by `published` first, then by `created_at` within each group.

## Schema Configuration

Mark attributes as sortable:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, sortable: true
  attribute :created_at, sortable: true
  attribute :views, sortable: true
  attribute :body  # Not sortable (default)
end
```

---

## Association Sorting

Sort by fields on related records. The association must be marked `sortable: true`:

```ruby
class PostSchema < Apiwork::Schema::Base
  belongs_to :author, sortable: true
end
```

### Query Format

```http
GET /posts?sort[author][name]=asc
```

Structure: `sort[association][field]=direction`

### Nested Associations

```http
GET /posts?sort[author][company][name]=asc
```

### Auto-Join

The adapter automatically joins required tables and applies `DISTINCT` to prevent duplicate rows from joins.

---

## Default Sorting

The adapter applies no default sort. Results use database order unless explicitly sorted.

To enforce a default in your controller:

```ruby
def index
  posts = Post.order(created_at: :desc)
  expose posts
end
```

---

## Validation

::: info Contract Validates First
Like filtering, sort parameters are validated by the contract before reaching the adapter. The adapter generates typed sort definitions from your schema — unknown fields and invalid directions are rejected immediately.
:::

### What the Contract Catches

- **Unknown fields** — `sort[unknown_field]` rejected if not in schema
- **Invalid directions** — `sort[title]=sideways` rejected (only `asc`/`desc`)
- **Non-sortable fields** — `sort[body]` rejected if not marked `sortable: true`

### Adapter Validation

These errors only occur with incomplete schema configuration:

| Code                             | Cause                                        |
| -------------------------------- | -------------------------------------------- |
| `field_not_sortable`             | Field exists but not marked `sortable: true` |
| `association_not_sortable`       | Association not marked `sortable: true`      |
| `association_resource_not_found` | Association schema couldn't be resolved      |

Example error response:

```json
{
  "errors": [
    {
      "code": "field_not_sortable",
      "detail": "body is not sortable. Available: title, created_at, views",
      "path": ["sort", "body"]
    }
  ]
}
```

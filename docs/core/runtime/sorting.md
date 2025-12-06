---
order: 3
---

# Sorting

Order results using query parameters. Fields must be marked `sortable: true` in the schema.

## Query Format

```
GET /posts?sort[created_at]=desc
```

Structure: `sort[field]=direction`

Direction: `asc` or `desc` (case-insensitive)

## Multi-Field Sorting

Sort by multiple fields in priority order:

```
GET /posts?sort[published][asc]&sort[created_at]=desc
```

Or use array notation for explicit ordering:

```
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

```
GET /posts?sort[author][name]=asc
```

Structure: `sort[association][field]=direction`

### Nested Associations

```
GET /posts?sort[author][company][name]=asc
```

### Auto-Join

The runtime automatically joins required tables and applies `DISTINCT` to prevent duplicate rows from joins.

---

## Default Sorting

The runtime applies no default sort. Results use database order unless explicitly sorted.

To enforce a default in your controller:

```ruby
def index
  posts = Post.order(created_at: :desc)
  respond_with posts
end
```

---

## Error Codes

| Code | Cause |
|------|-------|
| `field_not_sortable` | Field not marked `sortable: true` |
| `invalid_sort_direction` | Direction not `asc` or `desc` |
| `invalid_sort_value_type` | Value isn't a string |
| `association_not_sortable` | Association not marked `sortable: true` |
| `association_resource_not_found` | Association schema not resolvable |

Example error response:

```json
{
  "issues": [{
    "code": "field_not_sortable",
    "detail": "body is not sortable. Available: title, created_at, views",
    "path": ["sort", "body"]
  }]
}
```

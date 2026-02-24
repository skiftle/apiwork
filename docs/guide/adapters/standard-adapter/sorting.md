---
order: 5
---

# Sorting

The standard adapter orders results using query parameters. Attributes must be marked `sortable: true` in the representation.

## Query Format

```http
GET /posts?sort[created_at]=desc
```

Structure: `sort[field]=direction`

Direction: `asc` or `desc` (case-insensitive)

## Multi-Attribute Sorting

Sort by multiple attributes in priority order:

```http
GET /posts?sort[published]=asc&sort[created_at]=desc
```

Or use array notation for explicit ordering:

```http
GET /posts?sort[0][published]=asc&sort[1][created_at]=desc
```

First sort takes precedence. Results are ordered by `published` first, then by `created_at` within each group.

## Representation Configuration

Attributes are marked as sortable in the representation:

```ruby
class PostRepresentation < Apiwork::Representation::Base
  attribute :title, sortable: true
  attribute :created_at, sortable: true
  attribute :views, sortable: true
  attribute :body  # Not sortable (default)
end
```

## Association Sorting

Sort by attributes on related records. The association must be marked `sortable: true`:

```ruby
class PostRepresentation < Apiwork::Representation::Base
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

### Polymorphic Associations

Polymorphic associations cannot be sorted. The target table varies at runtime, so the adapter skips them during sort generation. To sort by a specific type, expose it as a dedicated resource with its own endpoint.

### Auto-Join

The adapter automatically joins required tables and applies `DISTINCT` to prevent duplicate rows from joins.

## Default Sorting

The adapter applies no default sort. Results use database order unless explicitly sorted.

A default can be enforced in the controller:

```ruby
def index
  posts = Post.order(created_at: :desc)
  expose posts
end
```

## Validation

::: info
Sort parameters are validated by the contract before reaching the adapter. The adapter generates typed sort definitions from the representation — unknown attributes and invalid directions are rejected immediately.
:::

### What the Contract Catches

- **Unknown attributes** — `sort[unknown_field]` rejected if not in schema
- **Invalid directions** — `sort[title]=sideways` rejected (only `asc`/`desc`)
- **Non-sortable attributes** — `sort[body]` rejected if not marked `sortable: true`

#### See also

- [Attribute Declaration](../../representations/attributes/declaration.md) — marking attributes as `sortable`
- [Association Declaration](../../representations/associations/declaration.md) — marking associations as `sortable`



---
order: 7
---

# Includes

Control which associations appear in API responses with the `include` query parameter.

For association configuration options like `writable`, `filterable`, and polymorphic support, see [Associations](../../representations/associations/).

## Query Format

```http
GET /posts?include[comments]=true
```

Structure: `include[association]=true`

Multiple associations:

```http
GET /posts?include[comments]=true&include[author]=true
```

## Nested Includes

Include associations on associations:

```http
GET /posts?include[comments][author]=true
```

This includes comments and each comment's author.

## Representation Configuration

Configure default include behavior in your representation:

```ruby
class PostRepresentation < Apiwork::Representation::Base
  has_many :comments
  has_many :tags
  belongs_to :author, include: :always
end
```

| Option | Behavior |
|--------|----------|
| `include: :optional` | Included only when requested (default) |
| `include: :always` | Always included in responses |

### Optional (default)

```ruby
has_many :comments, include: :optional  # Can be omitted — optional is default
```

Associations are optional by default. They only appear when requested:

```http
GET /posts/1                          # No comments
GET /posts/1?include[comments]=true   # With comments
```

### Always Include

```ruby
belongs_to :author, include: :always
```

The author appears in every response.

::: info Type guarantees
Associations with `include: :always` cannot be excluded. This is by design — it guarantees the type in generated exports.
:::

---

## Response Structure

Without includes:

```json
{
  "post": {
    "id": "1",
    "title": "Hello World"
  }
}
```

With `include[comments]=true`:

```json
{
  "post": {
    "id": "1",
    "title": "Hello World",
    "comments": [
      {
        "id": "1",
        "content": "Great post!"
      },
      {
        "id": "2",
        "content": "Thanks!"
      }
    ]
  }
}
```

---

## Depth Limit

Nested includes resolve up to 3 levels deep. Beyond that, the adapter stops generating include parameters for deeper associations.

```http
GET /posts?include[comments][author][company]=true    # 3 levels — OK
```

## Circular References

When an association forms a cycle (e.g., `Post -> Comments -> Post`), the adapter detects it and falls back to a boolean parameter for the circular reference. This prevents infinite recursion while still allowing the include.

## Polymorphic Associations

Polymorphic associations support boolean includes only — no nested structure:

```http
GET /posts?include[commentable]=true    # Boolean — OK
```

Nested includes on polymorphic associations are not supported because the target representation varies at runtime.

## N+1 Prevention

The adapter eager loads associations to prevent N+1 queries. When filtering by an association, the adapter also eager loads it to avoid N+1 in the filter query.


---
order: 6
---

# Includes

Control which associations appear in API responses with the `include` query parameter.

For association configuration options like `writable`, `filterable`, and polymorphic support, see [Associations](../representations/associations.md).

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

## N+1 Prevention

The adapter eager loads associations to prevent N+1 queries.


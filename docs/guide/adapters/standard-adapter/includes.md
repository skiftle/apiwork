---
order: 7
---

# Includes

The `include` query parameter controls which associations appear in API responses.

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

Associations configure their default include behavior in the representation:

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

::: info
Associations with `include: :always` cannot be excluded. This guarantees the type in generated exports.
:::

## Response Shape

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

## Depth Limit

The adapter generates nested include parameters up to 3 levels deep. This prevents infinite type generation from circular associations (e.g., Invoice to Items to Invoice to Items). Beyond 3 levels, deeper associations fall back to boolean parameters.

```http
GET /posts?include[comments][author][company]=true    # 3 levels — OK
```

Within the limit, circular references are detected individually — the adapter falls back to a boolean parameter for the specific association that forms the cycle.

## Polymorphic Associations

Polymorphic associations support boolean includes only — no nested shape:

```http
GET /posts?include[commentable]=true    # Boolean — OK
```

Nested includes on polymorphic associations are not supported because the target representation varies at runtime.

## N+1 Prevention

The adapter eager loads associations to prevent N+1 queries. When filtering by an association, the adapter also eager loads it to avoid N+1 in the filter query.

#### See also

- [Include Modes](../../representations/associations/include-modes.md) — configuring `:optional` and `:always`
- [Association Declaration](../../representations/associations/declaration.md) — association options


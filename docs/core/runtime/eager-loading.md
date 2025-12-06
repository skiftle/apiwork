---
order: 5
---

# Eager Loading

Control which associations are included in responses. The runtime uses ActiveRecord's `includes` to prevent N+1 queries.

## Query Format

```
GET /posts?include[comments]=true
```

Structure: `include[association]=true`

Multiple associations:

```
GET /posts?include[comments]=true&include[author]=true
```

## Nested Includes

Include associations on associations:

```
GET /posts?include[comments][author]=true
```

This includes comments and each comment's author.

## Schema Configuration

Control default include behavior:

```ruby
class PostSchema < Apiwork::Schema::Base
  belongs_to :author, include: :always     # Always included
  has_many :comments, include: :optional   # Client must request
  has_many :tags, include: :optional
end
```

| Option | Behavior |
|--------|----------|
| `include: :optional` | Only included if requested (default) |
| `include: :always` | Always included in responses |

### Always Include

```ruby
belongs_to :author, include: :always
```

The author is included in every response, even without `include[author]=true`.

### Optional Include

```ruby
has_many :comments, include: :optional
```

Comments only appear when requested:

```
GET /posts/1                          # No comments
GET /posts/1?include[comments]=true   # With comments
```

---

## Auto-Includes

The runtime automatically includes associations when needed:

### Filtering

When you filter by an association, it's automatically included:

```
GET /posts?filter[author][name][eq]=Jane
```

The `author` association is joined for the filter query.

### Sorting

When you sort by an association, it's automatically included:

```
GET /posts?sort[author][name]=asc
```

---

## Excluding Always-Include

You cannot exclude an `include: :always` association:

```
GET /posts?include[author]=false  # Ignored, author still included
```

---

## N+1 Prevention

The runtime uses different loading strategies:

**Collections (index):**

```ruby
Post.includes(:comments, :author)
```

**Single records (show, create, update):**

```ruby
ActiveRecord::Associations::Preloader.new(
  records: [post],
  associations: [:comments, :author]
).call
```

Both approaches prevent N+1 queries by loading all associations in batch queries.

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
      { "id": "1", "content": "Great post!" },
      { "id": "2", "content": "Thanks!" }
    ]
  }
}
```

---

## Circular Reference Prevention

The runtime tracks visited associations to prevent infinite loops:

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments
end

class CommentSchema < Apiwork::Schema::Base
  belongs_to :post
end
```

Requesting `include[comments][post][comments]` stops at the circular reference.

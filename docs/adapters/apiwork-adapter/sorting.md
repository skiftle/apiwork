---
order: 4
---

# Sorting

Sort collections by attributes.

## Enabling Sorting

Mark attributes as sortable in the schema:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, sortable: true
  attribute :created_at, sortable: true
end
```

## Basic Sorting

```ruby
# Ascending
{ sort: { title: 'asc' } }

# Descending
{ sort: { created_at: 'desc' } }
```

## Multiple Sort Fields

Sort by multiple fields in priority order:

```ruby
{ sort: [
  { published: 'asc' },
  { created_at: 'desc' }
] }
# Sorts by published first, then by created_at within each group
```

## Association Sorting

Sort by attributes on associated records:

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema, sortable: true
end

class CommentSchema < Apiwork::Schema::Base
  attribute :author, sortable: true
  attribute :created_at, sortable: true
end

# Sort posts by comment author
{ sort: { comments: { author: 'asc' } } }

# Sort posts by comment created_at
{ sort: { comments: { created_at: 'desc' } } }
```

## belongs_to Sorting

```ruby
class CommentSchema < Apiwork::Schema::Base
  belongs_to :post, schema: PostSchema, sortable: true
end

# Sort comments by post title
{ sort: { post: { title: 'asc' } } }
```

## Default Sort

When no sort is specified, records are sorted by `id` ascending.

## Combining with Filters

Sorting and filtering work together:

```ruby
{
  filter: { published: { eq: true } },
  sort: { created_at: 'desc' }
}
```

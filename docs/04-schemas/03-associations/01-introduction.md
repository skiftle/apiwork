# Associations

Associations define relationships between resources. They control how related data is included, filtered, and written.

## Association Types

| Type         | Cardinality | API Response |
| ------------ | ----------- | ------------ |
| `has_one`    | Single      | Object       |
| `has_many`   | Multiple    | Array        |
| `belongs_to` | Single      | Object       |

## Basic Declaration

```ruby
class PostSchema < Apiwork::Schema::Base
  belongs_to :author
  has_many :comments
  has_one :image
end
```

The `schema` option specifies which schema handles the associated resource.

## Options Reference

| Option        | Type            | Default     | Description                     |
| ------------- | --------------- | ----------- | ------------------------------- |
| `schema`      | Class           | auto        | Associated schema class         |
| `include`     | Symbol          | `:optional` | `:always` or `:optional`        |
| `writable`    | `bool` / `hash` | `false`     | Allow nested attributes         |
| `filterable`  | `bool`          | `false`     | Enable filtering by association |
| `sortable`    | `bool`          | `false`     | Enable sorting by association   |
| `nullable`    | `bool`          | auto        | Allow null (belongs_to)         |
| `polymorphic` | Hash            | `nil`       | Polymorphic type mapping        |
| `description` | `string`        | `nil`       | API documentation               |
| `example`     | `any`           | `nil`       | Example value                   |
| `deprecated`  | `bool`          | `false`     | Mark as deprecated              |

## Auto-Detection

The schema is auto-detected from the association name:

```ruby
# These are equivalent:
has_many :comments
has_many :comments, schema: CommentSchema
```

For non-standard names, specify explicitly:

```ruby
has_many :recent_posts, schema: PostSchema
```

## Response Structure

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title
  belongs_to :author
  has_many :comments
end
```

```json
{
  "post": {
    "title": "Hello World",
    "author": {
      "id": "1",
      "name": "Jane"
    },
    "comments": [
      { "id": "1", "content": "Great post!" },
      { "id": "2", "content": "Thanks for sharing" }
    ]
  }
}
```

## Generated Types

```typescript
// TypeScript
interface Post {
  title?: string;
  author?: Author;
  comments?: Comment[];
}

// Zod
const PostSchema = z.object({
  title: z.string().optional(),
  author: AuthorSchema.optional(),
  comments: z.array(CommentSchema).optional(),
});
```

## Detailed Guides

- [Include](./02-include.md) - Control when associations are loaded
- [Writable](./03-writable.md) - Nested attribute handling
- [Filtering & Sorting](./04-filtering-sorting.md) - Query by associations
- [Polymorphic](./05-polymorphic.md) - Polymorphic associations

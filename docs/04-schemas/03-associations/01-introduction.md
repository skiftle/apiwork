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

| Option        | Type            | Default     | Description                              |
| ------------- | --------------- | ----------- | ---------------------------------------- |
| `schema`      | Class           | auto        | Associated schema class                  |
| [`include`](./02-include.md)     | Symbol          | `:optional` | `:always` or `:optional`                 |
| [`writable`](./03-writable.md)    | `bool` / `hash` | `false`     | Allow nested attributes                  |
| [`filterable`](./04-filtering-sorting.md)  | `bool`          | `false`     | Enable filtering by association          |
| [`sortable`](./04-filtering-sorting.md)    | `bool`          | `false`     | Enable sorting by association            |
| [`nullable`](./02-include.md#nullable-vs-optional)    | `bool`          | auto        | Allow null (auto-detected from DB)       |
| [`polymorphic`](./05-polymorphic.md) | Hash            | `nil`       | Polymorphic type mapping                 |
| `description` | `string`        | `nil`       | API documentation                        |
| `example`     | `any`           | `nil`       | Example value                            |
| `deprecated`  | `bool`          | `false`     | Mark as deprecated                       |

### Writable Hash Syntax

The `writable` option supports context-specific writing:

```ruby
has_many :comments, writable: true                          # Create and update
has_many :comments, writable: { on: [:create] }             # Only on create
has_many :comments, writable: { on: [:update] }             # Only on update
has_many :comments, writable: { on: [:create, :update] }    # Same as true
```

### Nullable Auto-Detection

For `belongs_to` associations, `nullable` is auto-detected from the database foreign key constraint. Override explicitly when needed:

```ruby
belongs_to :author                    # nullable: auto-detected from DB
belongs_to :author, nullable: false   # Require author even if DB allows NULL
belongs_to :author, nullable: true    # Allow null even if DB requires it
```

## Auto-Detection

Schema and nullable are auto-detected. See [Auto-Discovery](../07-auto-discovery.md) for details.

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

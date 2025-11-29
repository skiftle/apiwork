# Polymorphic Associations

Handle associations that can belong to multiple model types.

## Definition

Map each type to its schema:

```ruby
class CommentSchema < Apiwork::Schema::Base
  belongs_to :commentable, polymorphic: {
    post: PostSchema,
    video: VideoSchema,
    article: ArticleSchema
  }
end
```

The hash keys (`:post`, `:video`) become variant tags in the generated union type.

## Rails Setup

Your model needs standard Rails polymorphic configuration:

```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end

class Video < ApplicationRecord
  has_many :comments, as: :commentable
end
```

Database columns required: `commentable_id` and `commentable_type`.

## Discriminator

Apiwork auto-detects the discriminator column from Rails (e.g., `commentable_type`). See [Auto-Discovery](../07-auto-discovery.md) for details.

Override if needed:

```ruby
belongs_to :commentable,
  polymorphic: { post: PostSchema, video: VideoSchema },
  discriminator: :custom_type_column
```

## Generated Types

Polymorphic associations generate discriminated unions:

```ruby
belongs_to :commentable, polymorphic: {
  post: PostSchema,
  video: VideoSchema
}
```

### Introspection

```json
{
  "commentable": {
    "type": "union",
    "discriminator": "commentable_type",
    "variants": [
      { "type": "post", "tag": "post" },
      { "type": "video", "tag": "video" }
    ],
    "required": false,
    "nullable": true
  }
}
```

### TypeScript

```typescript
type CommentablePolymorphic =
  | { commentable_type: 'post' } & Post
  | { commentable_type: 'video' } & Video;

interface Comment {
  content?: string;
  commentable?: CommentablePolymorphic;
}
```

### Zod

```typescript
const CommentablePolymorphicSchema = z.discriminatedUnion('commentable_type', [
  z.object({ commentable_type: z.literal('post') }).merge(PostSchema),
  z.object({ commentable_type: z.literal('video') }).merge(VideoSchema)
]);

const CommentSchema = z.object({
  content: z.string().optional(),
  commentable: CommentablePolymorphicSchema.optional()
});
```

## Response Format

```json
{
  "comment": {
    "id": "1",
    "content": "Great content!",
    "commentable": {
      "commentable_type": "post",
      "id": "5",
      "title": "Hello World"
    }
  }
}
```

## Including Polymorphic

By default, polymorphic associations use `include: :optional`. To always include:

```ruby
belongs_to :commentable,
  polymorphic: { post: PostSchema, video: VideoSchema },
  include: :always
```

Request with include:

```
GET /api/v1/comments/1?include[commentable]=true
```

Apiwork resolves the correct schema based on the discriminator value.

## Restrictions

Polymorphic associations have limitations due to type ambiguity:

| Feature | Supported | Reason |
|---------|-----------|--------|
| `include` | Yes | |
| `writable` | No | Rails doesn't support nested attributes for polymorphic |
| `filterable` | No | Cannot filter across multiple tables |
| `sortable` | No | Cannot sort across multiple tables |

```ruby
# These raise ConfigurationError:
belongs_to :commentable, polymorphic: { ... }, writable: true
belongs_to :commentable, polymorphic: { ... }, filterable: true
belongs_to :commentable, polymorphic: { ... }, sortable: true
```

To create or update the polymorphic target, use separate API calls.

## Inverse Polymorphic (has_many :as)

For the inverse side, use a regular `has_many`:

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema
end
```

The polymorphic configuration only applies to the `belongs_to` side.

## See Also

- [STI](../05-sti.md) - Single Table Inheritance (related pattern)

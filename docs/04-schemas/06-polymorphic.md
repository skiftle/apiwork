# Polymorphic Associations

Apiwork supports Rails polymorphic associations with full type safety through discriminated unions.

## Definition

Define a polymorphic association by mapping type keys to their schemas:

```ruby
class CommentSchema < Apiwork::Schema::Base
  model Comment

  attribute :content

  belongs_to :commentable, polymorphic: {
    post: PostSchema,
    article: ArticleSchema
  }
end
```

The hash keys (`:post`, `:article`) become variant tags in the generated union type.

## Rails Model Setup

```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end

class Article < ApplicationRecord
  has_many :comments, as: :commentable
end
```

Database columns required: `commentable_id` and `commentable_type`.

## Type Generation

Apiwork generates a discriminated union type for polymorphic associations.

For `belongs_to :commentable, polymorphic: {...}`:

### TypeScript

```typescript
export type CommentablePolymorphic = Article | Post;

export interface Comment {
  id?: number;
  content?: string;
  commentable?: CommentablePolymorphic;
}
```

### Zod

```typescript
const ArticleSchema = z.object({
  id: z.number(),
  title: z.string(),
  commentableType: z.literal("Article"),
});

const PostSchema = z.object({
  id: z.number(),
  title: z.string(),
  commentableType: z.literal("Post"),
});

const CommentablePolymorphicSchema = z.discriminatedUnion("commentableType", [
  ArticleSchema,
  PostSchema,
]);

const CommentSchema = z.object({
  id: z.number().optional(),
  content: z.string().optional(),
  commentable: CommentablePolymorphicSchema.optional(),
});
```

The discriminator field (`commentable_type`) is auto-detected from the Rails association reflection.

## Introspection

The introspection output represents polymorphic as a union:

```json
{
  "commentable": {
    "type": "union",
    "discriminator": "commentable_type",
    "variants": [
      { "type": "post", "tag": "post" },
      { "type": "article", "tag": "article" }
    ],
    "required": false,
    "nullable": true
  }
}
```

## Including Polymorphic Data

By default, polymorphic associations use `include: :optional`. To always include:

```ruby
belongs_to :commentable,
           polymorphic: { post: PostSchema, article: ArticleSchema },
           include: :always
```

Request with include:

```
GET /api/v1/comments/1?include=commentable
```

Response:

```json
{
  "comment": {
    "id": 1,
    "content": "Great post!",
    "commentable": {
      "id": 42,
      "title": "Hello World"
    }
  }
}
```

The actual object type determines which schema serializes the data.

## Discriminator

The discriminator field (e.g., `commentable_type`) is auto-detected from Rails' association reflection and cannot be renamed. It's used internally for type generation but is not included in the serialized response by default.

## Limitations

Polymorphic associations cannot use:

| Option | Allowed | Reason |
|--------|---------|--------|
| `include: :optional` | Yes | |
| `include: :always` | Yes | |
| `filterable: true` | No | Cannot filter across multiple tables |
| `sortable: true` | No | Cannot sort across multiple tables |
| `writable: true` | No | Rails does not support nested saves |

### No Nested Writes

Rails does not support `accepts_nested_attributes_for` on polymorphic associations. This is a Rails limitation, not an Apiwork limitation. Setting `writable: true` on a polymorphic association has no effect.

To create or update the polymorphic target, use separate API calls.

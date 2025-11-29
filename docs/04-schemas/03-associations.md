# Associations

Associations define relationships between schemas.

## has_many

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema
end
```

## has_one

```ruby
class PostSchema < Apiwork::Schema::Base
  has_one :author, schema: UserSchema
end
```

## belongs_to

```ruby
class CommentSchema < Apiwork::Schema::Base
  belongs_to :post, schema: PostSchema
end
```

## Options

### schema

The schema class for the association (required):

```ruby
has_many :comments, schema: CommentSchema
```

### include

Control when the association is included:

```ruby
# Client must request it (default)
has_many :comments, schema: CommentSchema, include: :optional

# Always included
has_many :comments, schema: CommentSchema, include: :always
```

### writable

Allow nested attributes in create/update:

```ruby
has_many :comments, schema: CommentSchema, writable: true
```

Requires `accepts_nested_attributes_for` on the model:

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments, allow_destroy: true
end
```

Limit to specific actions:

```ruby
has_many :comments, schema: CommentSchema, writable: { on: [:create] }
```

### nullable

Allow the association to be null:

```ruby
belongs_to :author, schema: UserSchema, nullable: true
```

### Metadata Options

Add documentation metadata:

```ruby
has_many :comments,
         schema: CommentSchema,
         description: "All comments on this post",
         example: [{ id: 1, content: "Great post!" }],
         deprecated: true
```

### filterable

Enable filtering on the association:

```ruby
has_many :comments, schema: CommentSchema, filterable: true
```

### sortable

Enable sorting on the association:

```ruby
has_many :comments, schema: CommentSchema, sortable: true
```

## Including Associations

By default, associations with `include: :optional` are not included.

Client requests them via query parameter:

```
GET /api/v1/posts?include=comments
GET /api/v1/posts?include=author,comments
```

See [Serialization](./04-serialization.md).

## Type Generation

Associations generate nested types for spec output.

### Introspection

```json
{
  "author": {
    "type": "has_one",
    "schema": "UserSchema",
    "include": "optional",
    "required": false
  },
  "comments": {
    "type": "has_many",
    "schema": "CommentSchema",
    "include": "optional",
    "required": false
  }
}
```

### TypeScript

```typescript
interface Post {
  id: number;
  title: string;
  author?: User;
  comments?: Comment[];
}
```

### Zod

```typescript
const PostSchema = z.object({
  id: z.number().int(),
  title: z.string(),
  author: UserSchema.optional(),
  comments: z.array(CommentSchema).optional(),
});

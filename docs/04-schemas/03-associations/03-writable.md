# Writable Associations

Create and update associated records through nested attributes.

## Basic Usage

```ruby
has_many :comments, schema: CommentSchema, writable: true
```

## Rails Requirement

Your model must accept nested attributes:

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments, allow_destroy: true
end
```

Apiwork validates this configuration and raises `ConfigurationError` if missing.

## Context-Specific Writing

```ruby
has_many :comments, writable: { on: [:create] }     # Only on create
has_many :comments, writable: { on: [:update] }     # Only on update
has_many :comments, writable: true                   # Both
```

## Request Format

Apiwork transforms association names to Rails' `_attributes` format:

```json
// POST /api/v1/posts
{
  "post": {
    "title": "New Post",
    "comments": [
      { "content": "First comment", "author": "Alice" },
      { "content": "Second comment", "author": "Bob" }
    ]
  }
}
```

Internally becomes:

```ruby
{
  title: "New Post",
  comments_attributes: [
    { content: "First comment", author: "Alice" },
    { content: "Second comment", author: "Bob" }
  ]
}
```

## Updating Existing Records

Include `id` to update existing associated records:

```json
// PATCH /api/v1/posts/1
{
  "post": {
    "comments": [
      { "id": "5", "content": "Updated comment" }
    ]
  }
}
```

## Deleting Records

Use `_destroy: true` to delete associated records:

```json
// PATCH /api/v1/posts/1
{
  "post": {
    "comments": [
      { "id": "5", "_destroy": true }
    ]
  }
}
```

Requires `allow_destroy: true` in Rails model:

```ruby
accepts_nested_attributes_for :comments, allow_destroy: true
```

Apiwork auto-detects this setting.

## Generated Payload Types

Apiwork generates separate payload types for create and update operations. This enables type-safe API clients that know exactly what fields are available in each context.

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, writable: true
  has_many :comments, schema: CommentSchema, writable: true
end

class CommentSchema < Apiwork::Schema::Base
  attribute :content, writable: true
  attribute :author, writable: true
end
```

### Create Payload

```typescript
// TypeScript
interface PostCreatePayload {
  title?: string;
  comments?: CommentCreatePayload[];
}

interface CommentCreatePayload {
  content?: string;
  author?: string;
}

// Zod
const PostCreatePayloadSchema = z.object({
  title: z.string().optional(),
  comments: z.array(CommentCreatePayloadSchema).optional()
});
```

### Update Payload (Always Partial)

Update payloads are always **partial** — all fields are optional. This reflects HTTP PATCH semantics: send only the fields you want to change.

```typescript
// TypeScript - all fields have ?
interface PostUpdatePayload {
  title?: string;
  comments?: CommentUpdatePayload[];
}

interface CommentUpdatePayload {
  id?: string;
  content?: string;
  author?: string;
  _destroy?: boolean;
}

// Zod - all fields have .optional()
const PostUpdatePayloadSchema = z.object({
  title: z.string().optional(),
  comments: z.array(z.object({
    id: z.string().optional(),
    content: z.string().optional(),
    author: z.string().optional(),
    _destroy: z.boolean().optional()
  })).optional()
});
```

**Why always partial?** With PATCH requests, omitting a field means "keep the current value." This is different from PUT where omitting a field typically means "set to null." Apiwork enforces PATCH semantics for updates.

### Nested Payload Union

For writable associations, Apiwork generates a discriminated union that supports both create and update operations in nested payloads. The `_type` field acts as the discriminator:

```typescript
// TypeScript
interface CommentNestedCreatePayload {
  _type: 'create';
  content?: string;
  author?: string;
}

interface CommentNestedUpdatePayload {
  _type: 'update';
  id: string;
  content?: string;
  author?: string;
  _destroy?: boolean;
}

type CommentNestedPayload = CommentNestedCreatePayload | CommentNestedUpdatePayload;

// Zod
const CommentNestedPayloadSchema = z.discriminatedUnion('_type', [
  z.object({
    _type: z.literal('create'),
    content: z.string().optional(),
    author: z.string().optional()
  }),
  z.object({
    _type: z.literal('update'),
    id: z.string(),
    content: z.string().optional(),
    author: z.string().optional(),
    _destroy: z.boolean().optional()
  })
]);
```

This allows mixing create and update operations in a single request:

```json
{
  "post": {
    "comments": [
      { "_type": "create", "content": "New comment" },
      { "_type": "update", "id": "5", "content": "Updated" },
      { "_type": "update", "id": "3", "_destroy": true }
    ]
  }
}
```

### Context-Specific Writable

When using `writable: { on: [:create] }` or `writable: { on: [:update] }`, the payload types reflect this:

```ruby
has_many :tags, writable: { on: [:create] }  # Only writable on create
```

```typescript
// Tags only appear in create payload
interface PostCreatePayload {
  title?: string;
  tags?: TagCreatePayload[];
}

// Tags NOT in update payload
interface PostUpdatePayload {
  title?: string;
  // no tags field
}
```

## Singular Associations

Works the same for `has_one` and `belongs_to`:

```ruby
has_one :profile, schema: ProfileSchema, writable: true
```

```json
{
  "user": {
    "name": "Jane",
    "profile": {
      "bio": "Developer",
      "website": "https://example.com"
    }
  }
}
```

## Nested Writable Associations

Associations can be nested multiple levels:

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema, writable: true
end

class CommentSchema < Apiwork::Schema::Base
  attribute :content, writable: true
  has_many :replies, schema: ReplySchema, writable: true
end
```

```json
{
  "post": {
    "comments": [
      {
        "content": "Great post!",
        "replies": [
          { "content": "Thanks!" }
        ]
      }
    ]
  }
}
```

## Validation

Nested attributes go through the associated schema's contract validation. Invalid nested data returns issues with paths like `["comments", 0, "content"]`.

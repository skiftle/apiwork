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

### Update Payload

Includes `id` and `_destroy`:

```typescript
// TypeScript
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

// Zod
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

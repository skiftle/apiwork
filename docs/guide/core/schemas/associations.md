---
order: 4
---

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

## Options Reference

| Option          | Type            | Default     | Description                              |
| --------------- | --------------- | ----------- | ---------------------------------------- |
| `schema`        | Class           | auto        | Associated schema class                  |
| `include`       | Symbol          | `:optional` | `:always` or `:optional`                 |
| `writable`      | `bool` / `hash` | `false`     | Allow nested attributes                  |
| `allow_destroy` | `bool`          | `false`     | Allow destroying nested records          |
| `filterable`    | `bool`          | `false`     | Enable filtering by association          |
| `sortable`      | `bool`          | `false`     | Enable sorting by association            |
| `nullable`      | `bool`          | auto        | Allow null (auto-detected from DB)       |
| `polymorphic`   | Array / Hash    | `nil`       | Polymorphic type mapping                 |
| `description`   | `string`        | `nil`       | API documentation                        |
| `example`       | `any`           | `nil`       | Example value                            |
| `deprecated`    | `bool`          | `false`     | Mark as deprecated                       |

## Auto-Detection

Schema and nullable are inferred from your model and database. [Inference](./inference.md) explains the detection rules.

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
      {
        "id": "1",
        "content": "Great post!"
      },
      {
        "id": "2",
        "content": "Thanks for sharing"
      }
    ]
  }
}
```

---

## Include Modes

Control when associations are loaded in responses.

| Mode | Behavior |
|------|----------|
| `include: :optional` | Only included if requested (default) |
| `include: :always` | Always included in responses |

### Optional Include (Default)

```ruby
has_many :comments, schema: CommentSchema, include: :optional
```

Clients request inclusion explicitly:

```http
GET /api/v1/posts/1?include[comments]=true
```

Without the parameter, `comments` is omitted from the response.

### Always Include

```ruby
belongs_to :author, schema: AuthorSchema, include: :always
```

The association is included in every response automatically.

### Type Guarantees

The `include` option directly affects generated types:

**Optional:**

```typescript
interface Post {
  title?: string;
  comments?: Comment[];  // May not be present
}
```

**Always:**

```typescript
interface Post {
  title?: string;
  author: Author;  // Always present (no ?)
}
```

### nullable vs optional

`nullable` and `include` are independent:

- **optional** (`?`) — field may not exist in response
- **nullable** (`| null`) — field exists but value can be null

```ruby
# Always present, never null
belongs_to :author, include: :always
# TypeScript: author: Author

# Always present, can be null
belongs_to :reviewer, include: :always, nullable: true
# TypeScript: reviewer: Author | null

# May not be present, if present then not null
has_many :comments, include: :optional
# TypeScript: comments?: Comment[]
```

### Request Format

**Single Association:**

```http
GET /api/v1/posts/1?include[comments]=true
```

**Multiple Associations:**

```http
GET /api/v1/posts/1?include[comments]=true&include[author]=true
```

**Nested Associations:**

```http
GET /api/v1/posts/1?include[comments][author]=true
```

**Depth limit**: Maximum 3 levels of nesting. This prevents circular references and keeps queries efficient.

### N+1 Prevention

Apiwork automatically preloads included associations using `ActiveRecord::Associations::Preloader`.

For more on include query behavior, see [Includes](../execution-engine/includes.md).

---

## Writable Associations

Create and update associated records through nested attributes.

### Basic Usage

```ruby
has_many :comments, schema: CommentSchema, writable: true
```

### Rails Requirement

Your model must accept nested attributes:

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments, allow_destroy: true
end
```

### Context-Specific Writing

```ruby
has_many :comments, writable: { on: [:create] }     # Only on create
has_many :comments, writable: { on: [:update] }     # Only on update
has_many :comments, writable: true                   # Both
```

### Request Format

**Create** new records (no `id`):

```json
{
  "post": {
    "title": "New Post",
    "comments": [
      { "content": "First comment" },
      { "content": "Second comment" }
    ]
  }
}
```

**Update** existing records (include `id`):

```json
{
  "post": {
    "comments": [
      {
        "id": "5",
        "content": "Updated comment"
      }
    ]
  }
}
```

**Delete** records (include `id` and `_destroy: true`):

```json
{
  "post": {
    "comments": [
      {
        "id": "5",
        "_destroy": true
      }
    ]
  }
}
```

Requires `allow_destroy: true` in Rails model.

**Mixed operations:**

```json
{
  "post": {
    "comments": [
      {
        "id": "5",
        "content": "Updated"
      },
      {
        "content": "New comment"
      },
      {
        "id": "3",
        "_destroy": true
      }
    ]
  }
}
```

### Deep Nesting

Nested attributes work at multiple levels. For example, Posts with Comments with Replies:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title
  has_many :comments, writable: true
end

class CommentSchema < Apiwork::Schema::Base
  attribute :content
  has_many :replies, writable: true
end

class ReplySchema < Apiwork::Schema::Base
  attribute :content
end
```

With corresponding Rails models:

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments, allow_destroy: true
end

class Comment < ApplicationRecord
  has_many :replies
  accepts_nested_attributes_for :replies, allow_destroy: true
end
```

**Request:**

```json
{
  "post": {
    "title": "Deep Nesting Example",
    "comments": [
      {
        "content": "Top-level comment",
        "replies": [
          { "content": "Reply to comment" },
          { "content": "Another reply" }
        ]
      }
    ]
  }
}
```

This creates a post with one comment and two replies in a single request. All standard operations (create, update, delete) work at each level.

### Generated Types

The adapter generates a discriminated union for type-safe client code:

```typescript
// Create payload - no id
export interface CommentNestedCreatePayload {
  _type: 'create';
  content?: string;
}

// Update payload - id required
export interface CommentNestedUpdatePayload {
  _type: 'update';
  id: string;
  content?: string;
  _destroy?: boolean;
}

export type CommentNestedPayload =
  | CommentNestedCreatePayload
  | CommentNestedUpdatePayload;
```

The `_type` discriminator lets TypeScript narrow the type based on the operation. At runtime, Rails determines create vs update by presence of `id` — the `_type` field is optional.

---

## Filtering & Sorting on Associations

Query by fields on associated records.

### Filtering

Enable with `filterable: true`:

::: warning ActiveRecord Association Required
Requires an ActiveRecord association on the model. Custom methods cannot be used for filtering.
:::

```ruby
has_many :comments, schema: CommentSchema, filterable: true
belongs_to :author, schema: AuthorSchema, filterable: true
```

**Query Format:**

```text
# Posts where author name is "Jane"
GET /api/v1/posts?filter[author][name][eq]=Jane

# Posts with comments containing "rails"
GET /api/v1/posts?filter[comments][content][contains]=rails

# Posts by author created after 2024
GET /api/v1/posts?filter[author][created_at][gt]=2024-01-01
```

### Sorting

Enable with `sortable: true`:

::: warning ActiveRecord Association Required
Requires an ActiveRecord association on the model. Custom methods cannot be used for sorting.
:::

```ruby
belongs_to :author, schema: AuthorSchema, sortable: true
```

**Query Format:**

```text
# Posts sorted by author name
GET /api/v1/posts?sort[author][name]=asc

# Posts sorted by author creation date
GET /api/v1/posts?sort[author][created_at]=desc
```

### Auto-Include

When filtering or sorting by an association, it's automatically included for the query.

---

## Polymorphic Associations

Handle associations that can belong to multiple model types.

### Definition

Two syntaxes are supported:

**Array shorthand** — infers schema from same namespace:

```ruby
class CommentSchema < Apiwork::Schema::Base
  belongs_to :commentable, polymorphic: [:post, :video, :article]
end
# Infers PostSchema, VideoSchema, ArticleSchema from same namespace
```

**Hash with explicit schemas** — when schema names don't follow convention:

```ruby
class CommentSchema < Apiwork::Schema::Base
  belongs_to :commentable, polymorphic: {
    post: PostSchema,
    video: MediaSchema,  # Custom schema
    article: ArticleSchema
  }
end
```

### Rails Setup

Your model needs standard Rails polymorphic configuration:

```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end
```

Database columns required: `commentable_id` and `commentable_type`.

### Generated Types

Polymorphic associations generate discriminated unions:

```typescript
export type CommentablePolymorphic =
  | { commentable_type: 'post' } & Post
  | { commentable_type: 'video' } & Video;

export interface Comment {
  content?: string;
  commentable?: CommentablePolymorphic;
}
```

### Restrictions

Polymorphic associations have limitations:

| Feature | Supported | Reason |
|---------|-----------|--------|
| `include` | Yes | |
| `writable` | No | Rails doesn't support nested attributes for polymorphic |
| `filterable` | No | Cannot filter across multiple tables |
| `sortable` | No | Cannot sort across multiple tables |

If you need filtering or sorting on polymorphic associations, expose the associated models as their own [resources](/guide/core/api-definitions/resources).

---

## Examples

- [Nested Saves](/examples/nested-saves.md) — Create/update/delete nested records in a single request
- [Polymorphic Associations](/examples/polymorphic-associations.md) — Handle belongs_to associations with multiple types
